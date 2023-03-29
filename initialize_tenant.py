from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import json
import os
import client_secrets

TENANT_BASE_URLS = ['https://a2cps.tapis.io', 'https://a2cps.develop.tapis.io',
                    'https://portals.develop.tapis.io', 'https://portals.tapis.io']

SYSTEMS = ['frontera', 'maverick2', 'ls6',
           'secure.frontera', 'secure.cloud.corral']

APPS = ['hello-world', 'compress', 'extract', 'matlab', 'rstudio']


def load_file_to_json(filepath):
    with open(filepath, 'r') as f:
        raw = f.read()
    loaded = json.loads(raw)
    return loaded


def provision(client):
    profile = load_file_to_json('systems/tacc-singularity.json')
    try:
        client.systems.createSchedulerProfile(**profile)
        print('profile created: {}'.format(profile['name']))
    except BaseTapyException:
        print('profile already exists: {}'.format(profile['name']))
        pass

    for system in SYSTEMS:
        sys_json = load_file_to_json(f'systems/{system}.json')
        try:
            client.systems.createSystem(**sys_json)
            print('system created: {}'.format(system))
        except BaseTapyException:
            client.systems.putSystem(systemId=sys_json['id'], **sys_json)
            print('system updated: {}'.format(system))
        client.systems.shareSystemPublic(systemId=sys_json['id'])
        client.files.sharePathPublic(
            systemId=sys_json['id'], path=sys_json['rootDir'])

    for app_name in APPS:
        app_json = load_file_to_json(f'applications/{app_name}/app.json')
        if os.path.isfile(f'applications/{app_name}/profile.json'):
            profile = load_file_to_json(
                f'applications/{app_name}/profile.json')
            try:
                client.systems.createSchedulerProfile(**profile)
                print('profile created: {}'.format(profile['name']))
            except BaseTapyException:
                print('profile already exists: {}'.format(profile['name']))
                pass

        try:
            client.apps.createAppVersion(**app_json)
            print('app created: {}'.format(app_name))
        except BaseTapyException:
            client.apps.putApp(
                appId=app_json['id'], appVersion=app_json['version'], **app_json)
            print('app updated: {}'.format(app_name))
        client.apps.shareAppPublic(appId=app_json['id'])


def main():
    for tenant_base_url in TENANT_BASE_URLS:
        client = Tapis(base_url=tenant_base_url, username=client_secrets.CLIENT_USERNAME,
                       password=client_secrets.CLIENT_PASSWORD, resource_set="dev", download_latest_specs=True)
        client.get_tokens()
        provision(client)

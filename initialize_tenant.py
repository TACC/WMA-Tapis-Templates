from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import os
from client_secrets import TENANT_NAMES, CLIENT_USERNAME, CLIENT_PASSWORD
from utils.load_file_to_json import load_file_to_json


def provision(client, systems, apps):
    # profile = load_file_to_json('systems/tacc-singularity.json')
    # try:
    #     client.systems.createSchedulerProfile(**profile)
    #     print('profile created: {}'.format(profile['name']))
    # except BaseTapyException:
    #     print('profile already exists: {}'.format(profile['name']))
    #     pass

    for system in systems:
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

    for app_name in apps:
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
            print('app created: {}'.format(app_json['id']))
        except BaseTapyException:
            client.apps.putApp(
                appId=app_json['id'], appVersion=app_json['version'], **app_json)
            print('app updated: {}'.format(app_json['id']))
        client.apps.shareAppPublic(appId=app_json['id'])


def main():
    for tenant_name in TENANT_NAMES:
        match tenant_name:
            case 'A2CPS':
                tenant_base_urls = ['https://a2cps.tapis.io',
                                    'https://a2cps.develop.tapis.io']
                systems = ['secure.frontera', 'secure.cloud.corral']
                apps = ['a2cps/extract-secure', 'a2cps/compress-secure',
                        'a2cps/matlab-secure', 'a2cps/rstudio-desktop-secure']
            case _:
                tenant_base_urls = ['https://portals.develop.tapis.io']
                systems = ['frontera', 'maverick2', 'ls6', 'cloud.data']
                apps = ['compress', 'extract', 'matlab',
                        'rstudio-desktop', 'jupyter-notebook-hpc', 'hello-world']

        for tenant_base_url in tenant_base_urls:
            print(f'provisioning tenant: {tenant_base_url}')
            client = Tapis(base_url=tenant_base_url, username=CLIENT_USERNAME,
                           password=CLIENT_PASSWORD, resource_set="dev", download_latest_specs=True)
            client.get_tokens()
            provision(client, systems, apps)


if __name__ == "__main__":
    main()

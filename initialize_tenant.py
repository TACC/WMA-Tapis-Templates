from tapipy.errors import BaseTapyException
import os
import argparse
from client_secrets import TAPIS_CLIENTS
from utils.load_file_to_json import load_file_to_json
from utils.client import get_client


def get_or_create_system(client, system_def, update=False):
    system_id = system_def['id']
    try:
        client.systems.getSystem(systemId=system_id)
        print('system already exists: {}'.format(system_id))
        if update:
            client.systems.putSystem(systemId=system_id, **system_def)
            print('system updated: {}'.format(system_id))
    except BaseTapyException as e:
        if 'SYSAPI_NOT_FOUND' in e.message:
            client.systems.createSystem(**system_def)
            print('system created: {}'.format(system_id))
        else:
            raise


def provision(client, systems, apps, args):
    profile = load_file_to_json('systems/tacc-apptainer.json')
    try:
        client.systems.createSchedulerProfile(**profile)
        print('profile created: {}'.format(profile['name']))
    except BaseTapyException as e:
        if 'SYSAPI_PRF_EXISTS' in e.message:
            print('profile already exists: {}'.format(profile['name']))

            if args.force:
                print('recreating profile {}'.format(profile['name']))
                client.systems.deleteSchedulerProfile(name=profile['name'])
                client.systems.createSchedulerProfile(**profile)
                print('profile created: {}'.format(profile['name']))
        else:
            raise

    for system in systems:
        sys_json = load_file_to_json(f'systems/{system}.json')
        public = sys_json['effectiveUserId'] == "${apiUserId}"
        get_or_create_system(client, sys_json, update=public)
        if public:
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
            except BaseTapyException as e:
                if 'SYSAPI_PRF_EXISTS' in e.message:
                    print('profile already exists: {}'.format(profile['name']))

                    if args.force:
                        print('recreating profile {}'.format(profile['name']))
                        client.systems.deleteSchedulerProfile(
                            name=profile['name'])
                        client.systems.createSchedulerProfile(**profile)
                        print('profile created: {}'.format(profile['name']))
                else:
                    raise

        try:
            client.apps.createAppVersion(**app_json)
            print('app created: {}'.format(app_json['id']))
        except BaseTapyException as e:
            if 'APPAPI_APP_EXISTS' in e.message:
                client.apps.putApp(
                    appId=app_json['id'], appVersion=app_json['version'], **app_json)
                print('app updated: {}'.format(app_json['id']))
            else:
                raise

        client.apps.shareAppPublic(appId=app_json['id'])


def main():
    parser = argparse.ArgumentParser(
        prog='Initialize Tenant', description='Provision or update a tenant with systems, apps, and scheduler profiles')
    parser.add_argument('-f', '--force', action='store_true',
                        help='Force recreate scheduler profiles')
    parser.add_argument('-t', '--tenants',
                        help='Comma separated list of tenants')
    parser.add_argument('-s', '--systems',
                        help='Comma separated list of systems. Paramater only applies for single tenant case')
    parser.add_argument('-a', '--apps',
                        help='Comma separated list of apps. Paramater only applies for single tenant case')
    args = parser.parse_args()

    if args.tenants:
        tenant_names = args.tenants.split(',')
    else:
        tenant_names = list(TAPIS_CLIENTS.keys())

    for tenant_name in tenant_names:

        if len(tenant_names) == 1:
            apps = args.apps.split(',') if args.apps else None
            systems = args.systems.split(',') if args.systems else None
        else:
            apps = None
            systems = None

        match tenant_name:
            case 'A2CPS':
                systems = systems or ['secure.frontera', 'secure.corral']
                apps = apps or ['a2cps/extract-secure', 'a2cps/compress-secure', 'a2cps/jupyter-lab-hpc-secure', 'a2cps/matlab-secure', 'a2cps/rstudio-secure']
            case _:
                systems = systems or ['frontera', 'ls6', 'cloud.data', 'c4-cloud']
                apps = apps or [
                    'compress',
                    'compress-ls6',
                    'extract',
                    'extract-ls6',
                    'fiji',
                    'jupyter-hpc-mpi',
                    'jupyter-hpc-mpi-ls6',
                    'jupyter-lab-hpc',
                    'jupyter-lab-hpc/gpu',
                    'jupyter-lab-hpc-ls6',
                    'jupyter-lab-hpc-openmpi',
                    'matlab',
                    'matlab-ls6',
                    'namd',
                    'napari-ls6',
                    'opensees-mp/opensees-mp-3.5.0',
                    'opensees-sp/opensees-sp-3.5.0',
                    'paraview',
                    'pyreconstruct',
                    'pyreconstruct-dev',
                    'qgis',
                    'rstudio',
                    'rstudio-ls6'
                ]

        for credentials in TAPIS_CLIENTS.get(tenant_name, []):
            print(f"provisioning tenant: {credentials['base_url']}")
            client = get_client(**credentials)
            provision(client, systems, apps, args)


if __name__ == "__main__":
    main()

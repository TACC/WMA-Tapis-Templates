import os
import argparse
from tapipy.errors import BaseTapyException
from client_secrets import TAPIS_CLIENTS
from utils.load_file_to_json import load_file_to_json
from utils.client import get_client


def get_or_create_system(client, system_def, update=False):
    system_id = system_def["id"]
    try:
        client.systems.getSystem(systemId=system_id)
        print("system already exists: {}".format(system_id))
        if update:
            client.systems.putSystem(systemId=system_id, **system_def)
            print("system updated: {}".format(system_id))
    except BaseTapyException as e:
        if "SYSAPI_NOT_FOUND" in e.message:
            client.systems.createSystem(**system_def)
            print("system created: {}".format(system_id))
        else:
            raise


def provision(client, systems, apps, args):
    profile = load_file_to_json("profiles/tacc-apptainer.json")
    try:
        client.systems.createSchedulerProfile(**profile)
        print("profile created: {}".format(profile["name"]))
    except BaseTapyException as e:
        if "SYSAPI_PRF_EXISTS" in e.message:
            print("profile already exists: {}".format(profile["name"]))

            if args.update_profiles:
                print("recreating profile {}".format(profile["name"]))
                client.systems.deleteSchedulerProfile(name=profile["name"])
                client.systems.createSchedulerProfile(**profile)
                print("profile created: {}".format(profile["name"]))
        else:
            raise

    for system in systems:
        sys_json = load_file_to_json(f"systems/{system}.json")
        public = sys_json["effectiveUserId"] == "${apiUserId}"
        get_or_create_system(client, sys_json, update=args.update_systems)
        if public:
            client.systems.shareSystemPublic(systemId=sys_json["id"])
            client.files.sharePathPublic(
                systemId=sys_json["id"], path=sys_json["rootDir"]
            )

    for app_name in apps:
        app_json = load_file_to_json(f"applications/{app_name}/app.json")
        if os.path.isfile(f"applications/{app_name}/profile.json"):
            profile = load_file_to_json(f"applications/{app_name}/profile.json")
            try:
                client.systems.createSchedulerProfile(**profile)
                print("profile created: {}".format(profile["name"]))
            except BaseTapyException as e:
                if "SYSAPI_PRF_EXISTS" in e.message:
                    print("profile already exists: {}".format(profile["name"]))

                    if args.update_profiles:
                        print("recreating profile {}".format(profile["name"]))
                        client.systems.deleteSchedulerProfile(name=profile["name"])
                        client.systems.createSchedulerProfile(**profile)
                        print("profile created: {}".format(profile["name"]))
                else:
                    raise

        try:
            client.apps.createAppVersion(**app_json)
            print("app created: {}".format(app_json["id"]))
        except BaseTapyException as e:
            if "APPAPI_APP_EXISTS" in e.message:
                print("app already exists: {}".format(app_json["id"]))

                if args.update_apps:
                    client.apps.putApp(
                        appId=app_json["id"], appVersion=app_json["version"], **app_json
                    )
                    print("app updated: {}".format(app_json["id"]))
            else:
                raise

        client.apps.shareAppPublic(appId=app_json["id"])


def main():
    parser = argparse.ArgumentParser(
        prog="Initialize Tenant",
        description="Provision or update a tenant with systems, apps, and scheduler profiles",
    )
    parser.add_argument("-t", "--tenants", help="Comma separated list of tenants")
    parser.add_argument(
        "-up",
        "--update-profiles",
        action="store_true",
        help="Force recreate scheduler profiles",
    )
    parser.add_argument(
        "-s",
        "--systems",
        help="Comma separated list of systems.",
    )
    parser.add_argument(
        "-us",
        "--update-systems",
        action="store_true",
        help="Update systems if they already exist.",
    )
    parser.add_argument(
        "-a",
        "--apps",
        help="Comma separated list of apps.",
    )
    parser.add_argument(
        "-ua",
        "--update-apps",
        action="store_true",
        help="Update apps if they already exist.",
    )
    parser.add_argument(
        "-d",
        "--dev",
        action="store_false",
        default=False,
        help="Uses Dev Specs when enabled",
    )
    args = parser.parse_args()

    if args.tenants:
        tenant_names = args.tenants.split(",")
    else:
        tenant_names = list(TAPIS_CLIENTS.keys())

    all_systems = [
        "c4-cloud",
        "cloud.data",
        "frontera",
        "ls6",
        "maverick2",
        "stampede3",
        "wma-dcv-01",
        "wma-exec-01",
    ]

    for tenant_name in tenant_names:

        apps = args.apps.split(",") if args.apps else []
        systems = args.systems.split(",") if args.systems else []

        match tenant_name:
            case "A2CPS":
                systems = (
                    ["a2cps/secure.frontera", "a2cps/secure.corral"]
                    if systems == ["ALL"]
                    else systems
                )
                apps = (
                    [
                        "a2cps/extract-secure",
                        "a2cps/compress-secure",
                        "a2cps/jupyter-lab-hpc-secure",
                        "a2cps/matlab-secure",
                        "a2cps/rstudio-secure",
                    ]
                    if apps == ["ALL"]
                    else apps
                )
            case "DESIGNSAFE":
                systems = (
                    all_systems
                    + [
                        "designsafe/designsafe.storage.default",
                        "designsafe/designsafe.storage.community",
                        "designsafe/designsafe.storage.frontera.work",
                        "designsafe/designsafe.storage.projects",
                        "designsafe/designsafe.storage.published",
                        "designsafe/designsafe.storage.work",
                        "designsafe/nees.public",
                        "designsafe/ds-stko-dev",
                    ]
                    if systems == ["ALL"]
                    else systems
                )
                apps = (
                    [
                        "compress",
                        "extract",
                        "figuregen/serial",
                        "figuregen/parallel",
                        "GiD",
                        "jupyter-lab-hpc",
                        "jupyter-lab-hpc/gpu",
                        "kalpana",
                        "matlab",
                        "mpm",
                        "openfoam",
                        "opensees-mp/opensees-mp-3.5.0",
                        "opensees-sp/opensees-sp-3.5.0",
                        "paraview",
                        "qgis",
                        "qgis-express",
                        "matlab-express",
                        "visit",
                    ]
                    if apps == ["ALL"]
                    else apps
                )
            case _:
                systems = all_systems if systems == ["ALL"] else systems
                apps = (
                    [
                        "adcirc-frontera",
                        "compress",
                        "compress-ls6",
                        "extract",
                        "extract-ls6",
                        "figuregen/serial",
                        "figuregen/parallel",
                        "fiji",
                        "GiD",
                        "jupyter-hpc-mpi",
                        "jupyter-hpc-mpi-ls6",
                        "jupyter-lab-hpc",
                        "jupyter-lab-hpc/gpu",
                        "jupyter-lab-hpc-ls6",
                        "jupyter-lab-hpc-openmpi",
                        "kalpana",
                        "matlab",
                        "matlab-ls6",
                        "mpm",
                        "namd",
                        "napari-ls6",
                        "openfoam",
                        "opensees-mp/opensees-mp-3.5.0",
                        "opensees-sp/opensees-sp-3.5.0",
                        "padcirc-frontera",
                        "padcirc-swan-frontera",
                        "paraview",
                        "pyreconstruct",
                        "pyreconstruct-dev",
                        "qgis",
                        "rstudio",
                        "rstudio-ls6",
                        "visit",
                    ]
                    if apps == ["ALL"]
                    else apps
                )

        for credentials in TAPIS_CLIENTS.get(tenant_name, []):
            print(f"provisioning tenant: {credentials['base_url']}")
            client = get_client(args.dev, **credentials)
            provision(client, systems, apps, args)


if __name__ == "__main__":
    main()

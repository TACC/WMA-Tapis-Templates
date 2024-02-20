from tapipy.tapis import Tapis


def get_client(use_dev_specs, **credentials):
    return Tapis(**credentials, download_latest_specs=True, resource_set='dev') if use_dev_specs else Tapis(**credentials, download_latest_specs=True)
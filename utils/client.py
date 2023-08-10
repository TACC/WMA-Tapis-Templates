from tapipy.tapis import Tapis


def get_client(**credentials):
    return Tapis(**credentials, download_latest_specs=True)

from tapipy.tapis import Tapis


def get_client(base_url, client_id, client_key, access_token, refresh_token):
    return Tapis(base_url=base_url,
                 client_id=client_id,
                 client_key=client_key,
                 access_token=access_token,
                 refresh_token=refresh_token)

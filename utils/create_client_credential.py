from tapipy.tapis import Tapis
from client_secrets import USER_CREDENTIAL_PRIVATE_KEY, USER_CREDENTIAL_PUBLIC_KEY, CLIENT_USERNAME, CLIENT_PASSWORD


client = Tapis(base_url='https://portals.develop.tapis.io',
               username=CLIENT_USERNAME, password=CLIENT_PASSWORD)
client.get_tokens()

client.systems.createUserCredential(systemId='frontera', userName=CLIENT_USERNAME,
                                    privateKey=USER_CREDENTIAL_PRIVATE_KEY, publicKey=USER_CREDENTIAL_PUBLIC_KEY)

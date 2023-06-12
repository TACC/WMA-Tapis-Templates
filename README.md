# WMA-Tapis-Templates

## Requirements
- [Tapipy](https://github.com/tapis-project/tapipy/tree/main/tapipy)
- (Optional) [pyenv](https://github.com/pyenv/pyenv)

## Provisioning a Tenant
1. Create a `client_secrets.py` file with a `CLIENT_USERNAME` and `CLIENT_PASSWORD` (see client_secrets.example.py)
2. Adjust the tenants, systems, and apps you wish to create in `initialize_tenant.py`
3. Run `python initialize_tenant.py` to create/update the apps and systems in the tenants listed in `TENANT_BASE_URLS`

## Creating a client
1. (Optional) Install Tapipy in a pyenv environemnt
  a. `pyenv install 3.11`
  b. `pyenv virtualenv 3.11 tapipy`
  c. `pyenv local tapipy`
  c. `pip install tapipy`
2. Install ipython
  a. `pip install ipython`
3. Initiate an ipython session
  a. `ipython`
4. Create a client
```
from tapipy.tapis import Tapis
client = Tapis(base_url='https://portals.tapis.io', username='$USER', password='******')
client.get_tokens()
```

## Creating a credential
1. Create a keypair locally
  a. `ssh-keygen -m PEM -t rsa -b 2048 -f ~/.ssh/$USER.frontera`
2. Copy the public key to your `~/.ssh/authorized_keys` file on the frontera host
```
ssh $USER@frontera.tacc.utexas.edu
PUBKEY="PASTE PUBLIC KEY HERE"
echo $PUBKEY >> ~/.ssh/authorized_keys`
```
3. Copy the public and private key to the `USER_CREDENTIAL_PRIVATE_KEY` and `USER_CREDENTIAL_PUBLIC_KEY` values in `client_secrets.py`
4. Adjust the `systemId` and `base_url` values for your desired tenant/system and run the `create_client_credential.py` script
5. Test the keypair works by making a file listing on a system
  a. `client.files.listFiles(systemId='frontera', path='/')`

import os
from dotenv import load_dotenv

load_dotenv("secrets.env")

TAPIS_CLIENTS = {
    "PORTALS": [
        {
            "base_url": "https://portals.develop.tapis.io",
            "access_token": os.getenv("PORTALS_DEV_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://portals.staging.tapis.io",
            "access_token": os.getenv("PORTALS_STAGING_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://portals.tapis.io",
            "access_token": os.getenv("PORTALS_PROD_ACCESS_TOKEN"),
        },
    ],
    "A2CPS": [
        {
            "base_url": "https://a2cps.develop.tapis.io",
            "access_token": os.getenv("A2CPS_DEV_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://a2cps.staging.tapis.io",
            "access_token": os.getenv("A2CPS_STAGING_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://a2cps.tapis.io",
            "access_token": os.getenv("A2CPS_PROD_ACCESS_TOKEN"),
        },
    ],
    "3DEM": [
        {
            "base_url": "https://3dem.develop.tapis.io",
            "access_token": os.getenv("3DEM_DEV_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://3dem.tapis.io",
            "access_token": os.getenv("3DEM_PROD_ACCESS_TOKEN"),
        },
    ],
    "DESIGNSAFE": [
        {
            "base_url": "https://designsafe.develop.tapis.io",
            "access_token": os.getenv("DESIGNSAFE_DEV_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://designsafe.staging.tapis.io",
            "access_token": os.getenv("DESIGNSAFE_STAGING_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://designsafe.tapis.io",
            "access_token": os.getenv("DESIGNSAFE_PROD_ACCESS_TOKEN"),
        },
    ],
    "LCCF": [
        {
            "base_url": "https://lccf.staging.tapis.io",
            "access_token": os.getenv("LCCF_STAGING_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://lccf.tapis.io",
            "access_token": os.getenv("LCCF_PROD_ACCESS_TOKEN"),
        },
    ],
    "CIPP": [
        {
            "base_url": "https://cipp.staging.tapis.io",
            "access_token": os.getenv("CIPP_STAGING_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://cipp.tapis.io",
            "access_token": os.getenv("CIPP_PROD_ACCESS_TOKEN"),
        },
    ],
    "APCD": [
        {
            "base_url": "https://apcd.staging.tapis.io",
            "access_token": os.getenv("APCD_STAGING_ACCESS_TOKEN"),
        },
        {
            "base_url": "https://apcd.tapis.io",
            "access_token": os.getenv("APCD_PROD_ACCESS_TOKEN"),
        },
    ],
    "OIDC": [
        {
            "base_url": "https://oidc.staging.tapis.io",
            "access_token": os.getenv("OIDC_STAGING_ACCESS_TOKEN"),
        },
        # {
        #     "base_url": "https://oidc.tapis.io",
        #     "access_token": os.getenv("OIDC_PROD_ACCESS_TOKEN"),
        # },
    ],
}

USER_CREDENTIAL_PRIVATE_KEY = os.getenv("USER_CREDENTIAL_PRIVATE_KEY")

USER_CREDENTIAL_PUBLIC_KEY = os.getenv("USER_CREDENTIAL_PUBLIC_KEY")

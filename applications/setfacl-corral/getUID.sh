#!/bin/bash
source tas.env
USER=$1
curl -sku $tas_user:$tas_pw https://tas.tacc.utexas.edu/api/v1/users/username/$USER | ./JSON.sh | awk '/^\["result","uid"/{print $NF}'

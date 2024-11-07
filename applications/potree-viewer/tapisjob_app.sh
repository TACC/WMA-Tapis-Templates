#!/bin/bash

set -x

handle_error() {
  local EXITCODE=$1
  echo "Potree Viewer job exited with an error status. $EXITCODE" >&2
  echo "$EXITCODE" > "${_tapisExecSystemOutputDir}/tapisjob.exitcode"
  exit $EXITCODE
}

echo "TACC: job $_tapisJobUUID execution at: `date`"

LOGIN_PORT=$(( ((RANDOM<<15)|RANDOM) % 1000 + 7000 ))
quit=0

while [ "$quit" -ne 1 ]; do
  netstat -an | grep $LOGIN_PORT >> /dev/null
  if [ $? -gt 0 ]; then
    quit=1
  else
    LOGIN_PORT=`expr $LOGIN_PORT + 1`
  fi
done
echo "Using port=$LOGIN_PORT"

POTREE_INSTANCE_NAME="potree-viewer-${_tapisJobUUID}"
export POTREE_USER=$(id -un)
export POTREE_PASSWORD=$(openssl rand -hex 15)
echo "username is $POTREE_USER with password $POTREE_PASSWORD"

apptainer instance run \
    --writable-tmpfs \
    --memory 1G \
    --bind ${_tapisExecSystemInputDir}:/data \
    --bind /opt/potree:/potree \
    --bind /etc/letsencrypt/live/wma-exec-01.tacc.utexas.edu/cert.pem:/etc/nginx/ssl/nginx.crt \
    --bind /etc/letsencrypt/live/wma-exec-01.tacc.utexas.edu/privkey.pem:/etc/nginx/ssl/nginx.key \
    --env LOGIN_PORT=$LOGIN_PORT \
    docker://taccaci/potree-viewer:1.8.2 $POTREE_INSTANCE_NAME \
    /bin/bash -c "cp -r /potree/{build,libs} /data/ && htpasswd -bc /etc/nginx/.htpasswd \"$POTREE_USER\" \"$POTREE_PASSWORD\" && envsubst < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"

# Webhook callback url for job ready notification
# (notifications sent to INTERACTIVE_WEBHOOK_URL (i.e. https://3dem.org/webhooks/interactive/))`
#connect to interactive session on VM
curl -k --data "event_type=interactive_session_ready&address=https://wma-exec-01.tacc.utexas.edu:${LOGIN_PORT}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}&message=Connect to Potree Viewer with username $POTREE_USER and password $POTREE_PASSWORD" "${_INTERACTIVE_WEBHOOK_URL}" &

echo "TACC: Your interactive session is now running!"
echo "TACC: Connect to your session at: https://wma-exec-01.tacc.utexas.edu:${LOGIN_PORT}/"

if [ ! $? ]; then
    handle_error 1
    exit
fi

# Keep container running while session is active

sleep $((_tapisMaxMinutes - 2))m
apptainer instance stop $POTREE_INSTANCE_NAME

# Release port
fuser -k $LOGIN_PORT/tcp

echo "TACC: job $_tapisJobUUID execution finished at: `date`"

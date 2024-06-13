handle_error() {
  local EXITCODE=$1
  echo "Potree Viewer job exited with an error status. $EXITCODE" >&2
  echo "$EXITCODE" > "${_tapisExecSystemOutputDir}/tapisjob.exitcode"
  exit $EXITCODE
}

set -x
echo "TACC: job $_tapisJobUUID execution at: `date`"
cp -r /opt/potree/build ${_tapisExecSystemInputDir}
TARGET_FOLDER=${_tapisExecSystemInputDir}

port=$(( ((RANDOM<<15)|RANDOM) % 100 + 5900 ))
quit=0

while [ "$quit" -ne 1 ]; do
  netstat -a | grep $port >> /dev/null
  if [ $? -gt 0 ]; then
    quit=1
  else
    port=`expr $port + 1`
  fi
done
echo "Using port=$port"

# mkdir data
# mv INPUTFOLDER data

apptainer run \
    --env "FOLDER_TO_VIEW=$TARGET_FOLDER" \
    --memory 1G \
    --net --network-args "portmap=$port:8080" \
    --bind ${_tapisExecSystemInputDir}:/data:ro \
    docker://taccaci/potree-viewer:1.8.2
    /bin/bash -c "envsubst < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"

CONTAINER_PID=$!

# Webhook callback url for job ready notification
# (notifications sent to INTERACTIVE_WEBHOOK_URL (i.e. https://3dem.org/webhooks/interactive/))`
INTERACTIVE_WEBHOOK_URL="${_INTERACTIVE_WEBHOOK_URL}"

#connect to interactive session on VM
curl -k --data "event_type=interactive_session_ready&address=https://wma-exec-01.tacc.utexas.edu:${port}/owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" $INTERACTIVE_WEBHOOK_URL &

echo "TACC: Your interactive session is now running!"
echo "TACC: Connect to your session at: https://wma-exec-01.tacc.utexas.edu:${LOCAL_PORT}/"

if [ ! $? ]; then
    handle_error 1
    exit
fi

# Keep container running while session is active

sleep ${_tapisMaxMinutes}
kill $CONTAINER_PID
kill $$

echo "TACC: job $_tapisJobUUID execution finished at: `date`"

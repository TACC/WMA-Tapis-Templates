set -x

# our vm hostname
VM_HOST=`hostname -f`
echo "running on VM $VM_HOST"

LOGIN_PORT=$(( ((RANDOM<<15)|RANDOM) % 100 + 5900 ))
quit=0

while [ "$quit" -ne 1 ]; do
    netstat -a | grep $LOGIN_PORT >> /dev/null
    if [ $? -gt 0 ]; then
        quit=1
    else
        LOGIN_PORT=`expr $LOGIN_PORT + 1`
    fi
done
echo "Using LOGIN_PORT=$LOGIN_PORT"

INTERACTIVE_WEBHOOK_URL="${_webhook_base_url}"

DOCKER_IMAGE="taccaci/opensees-interactive:3.6.0"

apptainer run \
    --cleanenv \
    --writable-tmpfs \
    --net --network-args "portmap=$LOGIN_PORT:8888/tcp" \
    --env LOGIN_PORT=$LOGIN_PORT \
    --env VM_HOST=$VM_HOST \
    --env _tapisJobOwner="${_tapisJobOwner}" \
    --env _tapisJobUUID="${_tapisJobUUID}" \
    --env _INTERACTIVE_WEBHOOK_URL="${_INTERACTIVE_WEBHOOK_URL}" \
    --bind "/corral/main/projects/NHERI/shared/${_tapisJobOwner}":/home/jovyan/work/MyData \
    --bind /corral/main/projects/NHERI/public/projects:/home/jovyan/work/NEES:ro \
    --bind /corral/main/projects/NHERI/community:/home/jovyan/work/CommunityData:ro \
    --bind /corral/main/projects/NHERI/published:/home/jovyan/work/NHERI-Published:ro \
    --bind /etc/letsencrypt/live/wma-exec-01.tacc.utexas.edu/cert.pem:/etc/nginx/ssl/nginx.crt \
    --bind /etc/letsencrypt/live/wma-exec-01.tacc.utexas.edu/privkey.pem:/etc/nginx/ssl/nginx.key \
    "${DOCKER_IMAGE}"

EXITCODE=$?
if [ $EXITCODE -ne 0 ]; then
    # Command failed
    echo "Apptainer container exited with an error status. $EXITCODE" >&2

    # https://tapis.readthedocs.io/en/latest/technical/jobs.html#monitoring-the-application
    echo $EXITCODE > ${_tapisExecSystemOutputDir}/tapisjob.exitcode
fi



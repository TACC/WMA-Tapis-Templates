#!/bin/bash

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

DOCKER_IMAGE="docker://taccaci/opensees-interactive:3.7.0"

mkdir -p $HOME/work/MyProjects

projects_dir="$HOME/work/MyProjects"
IFS=' ' read -r -a projects <<< "${_UserProjects}"
for project in "${projects[@]}"; do
    IFS=',' read -r uuid projectId <<< "$project"
    target_path="/corral/main/projects/NHERI/projects/$uuid"
    symlink_path="$projects_dir/$projectId"

    if [ -e "$target_path" ]; then
        if [ ! -e "$symlink_path" ]; then
            ln -s "$target_path" "$symlink_path"
            echo "TACC: Project Links: Created symlink: $symlink_path -> $target_path"
        else
            echo "TACC: Project Links: Symlink already exists: $symlink_path"
        fi
    else
        echo "TACC: Project Links: Target path does not exist: $target_path"
    fi
done

apptainer run \
    --cleanenv \
    --writable-tmpfs \
    --containall \
    --env PWD=$HOME/work \
    --env LOGIN_PORT=$LOGIN_PORT \
    --env VM_HOST=$VM_HOST \
    --env _tapisJobOwner="${_tapisJobOwner}" \
    --env _tapisJobUUID="${_tapisJobUUID}" \
    --env _INTERACTIVE_WEBHOOK_URL="${_INTERACTIVE_WEBHOOK_URL}" \
    --bind /corral/main/projects/NHERI/projects:/corral/main/projects/NHERI/projects \
    --bind "/data/designsafe/mydata/${_tapisJobOwner}":$HOME/work/MyData \
    --bind $projects_dir:$HOME/work/MyProjects \
    --bind /corral/main/projects/NHERI/public/projects:$HOME/work/NEES:ro \
    --bind /corral/main/projects/NHERI/community:$HOME/work/CommunityData:ro \
    --bind /corral/main/projects/NHERI/published:$HOME/work/NHERI-Published:ro \
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

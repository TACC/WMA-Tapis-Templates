#!/bin/bash

set -x

# our vm hostname
VM_HOST=`hostname -f`
echo "running on VM $VM_HOST"

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
echo "Using LOGIN_PORT=$LOGIN_PORT"

# create MyProjects directory and symlink user projects
mkdir -p "${_tapisJobWorkingDir}/MyProjects"
PROJECTS_DIR="${_tapisJobWorkingDir}/MyProjects"
IFS=' ' read -r -a projects <<< "${_UserProjects}"
for project in "${projects[@]}"; do
    IFS=',' read -r uuid projectId <<< "$project"
    target_path="/corral/main/projects/NHERI/projects/$uuid"
    symlink_path="${PROJECTS_DIR}/$projectId"

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

# N.B.
#   APPTAINER_HOME allows us to define a $HOME for the user outside of the container.
#   Here, pip installs initiated inside the container are persisted in the $APPTAINER_HOME/.local directory!
#
#   APPTAINER_PWD allows us to define the directory open in a terminal within the container at runtime.
#
#   See: https://apptainer.org/docs/user/main/appendix.html
export APPTAINER_HOME="${HOME}"
export APPTAINER_PWD="${HOME}"
export APPTAINER_TMPDIR="${_tapisJobWorkingDir}/tmp"

# N.B.
#   The tmpfs apptainer creates is only 64MB in size, so we need a new tmp space mapped for pip to be able
#   to install packages at $TMPDIR
mkdir -p -m 700 "${_tapisJobWorkingDir}/tmp"

# Define container binds
USER_MYDATA="/data/designsafe/mydata/${_tapisJobOwner}"
USER_WORK="/work/${_TAS_DIR}"
CONTAINER_HOME="${USER_MYDATA}/.opensees-interactive"
mkdir -p "${CONTAINER_HOME}/MyData" "${CONTAINER_HOME}/MyProjects" "${CONTAINER_HOME}/NEES" "${CONTAINER_HOME}/CommunityData" "${CONTAINER_HOME}/NHERI-Published" "${CONTAINER_HOME}/Work"

apptainer run \
    --cleanenv \
    --writable-tmpfs \
    --containall \
    --env LOGIN_PORT="${LOGIN_PORT}" \
    --env VM_HOST="${VM_HOST}" \
    --env _tapisJobOwner="${_tapisJobOwner}" \
    --env _tapisJobUUID="${_tapisJobUUID}" \
    --env _INTERACTIVE_WEBHOOK_URL="${_INTERACTIVE_WEBHOOK_URL}" \
    --bind ${APPTAINER_TMPDIR}:/tmp \
    --bind "${CONTAINER_HOME}:${HOME}" \
    --bind /corral/main/projects/NHERI/projects \
    --bind "${USER_MYDATA}:${HOME}/MyData" \
    --bind "${PROJECTS_DIR}:${HOME}/MyProjects" \
    --bind "${USER_WORK}:${HOME}/Work" \
    --bind "/corral/main/projects/NHERI/public/projects:${HOME}/NEES:ro" \
    --bind "/corral/main/projects/NHERI/community:${HOME}/CommunityData:ro" \
    --bind "/corral/main/projects/NHERI/published:${HOME}/NHERI-Published:ro" \
    --bind /etc/letsencrypt/live/wma-exec-01.tacc.utexas.edu/cert.pem:/etc/nginx/ssl/nginx.crt \
    --bind /etc/letsencrypt/live/wma-exec-01.tacc.utexas.edu/privkey.pem:/etc/nginx/ssl/nginx.key \
    "${_DOCKER_IMAGE}"

EXITCODE=$?

# Release port
fuser -k $LOGIN_PORT/tcp

if [ $EXITCODE -ne 0 ]; then
    # Command failed
    echo "Apptainer container exited with an error status. $EXITCODE" >&2

    # https://tapis.readthedocs.io/en/latest/technical/jobs.html#monitoring-the-application
    echo $EXITCODE > "${_tapisExecSystemOutputDir}/tapisjob.exitcode"
fi

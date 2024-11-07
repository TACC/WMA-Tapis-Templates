#!/bin/bash

handle_error() {
  local EXITCODE=$1
  echo "Phyiscs-based extractor job exited with an error status. $EXITCODE" >&2
  echo "$EXITCODE" > "${_tapisExecSystemOutputDir}/tapisjob.exitcode"
  exit $EXITCODE
}

set -x

PBESCRIPT="${inputScript##*/}"
echo "PBESCRIPT is $PBESCRIPT"

inputPath="`pwd`/${inputDirectory}"
INPUTDIR=${inputPath}
if [ -z ${inputDirectory} ]; then
    INPUTDIR="/corral/projects/NHERI/shared/${_tapisJobOwner}"
fi

#dataPath="`pwd`/${dataDirectory}"
DATADIR_NAME="${dataDirectory##*/}"
DATADIR=`python3 get_folder_mount_path.py $dataDirectory`

DATADIR_MOUNT="--bind ${DATADIR}:/home/${_tapisJobOwner}/projects/$DATADIR_NAME"
if [ -z ${dataDirectory} || -z ${DATADIR} ]; then
    
    if [ -z ${DATADIR} ]; then
        echo "No valid mount found for Data Directory specified in job request; defaulting to mounting your projects."
    fi
    projects_dir="$HOME/MyProjects"

    mkdir -p "$projects_dir"
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
    DATADIR_MOUNT="--bind ${projects_dir}:/home/${_tapisJobOwner}/projects"
fi

echo "Running $PBESCRIPT"

apptainer run \
    --writable-tmpfs \
    --memory 5G \
    --bind $INPUTDIR:"/data/" \
    --bind "/corral/main/projects/NHERI/shared/${_tapisJobOwner}":"/home/${_tapisJobOwner}/MyData" \
    --bind /corral/main/projects/NHERI/public/projects:/home/NEES:ro \
    --bind /corral/main/projects/NHERI/community:/home/CommunityData:ro \
    --bind /corral/main/projects/NHERI/published:/home/NHERI-Published:ro \
    --bind /corral/main/projects/NHERI/projects \
    $DATADIR_MOUNT \
    docker://taccaci/designsafe-simcenter-vm:0.0.1 /bin/sh -c "cd /data; python3 /data/$PBESCRIPT"

if [ ! $? ]; then
    handle_error 1
    exit
fi

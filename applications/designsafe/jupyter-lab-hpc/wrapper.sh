#!/bin/bash

echo "TACC: job ${SLURM_JOB_ID} execution at: $(date)"
AGAVE_JOB_OWNER=sal
CURRENT_WORKING_DIR="$PWD"
USER_MY_DATA=$CURRENT_WORKING_DIR/MyData
JUPYTERLAB_SETTINGS_DIR=$USER_MY_DATA/.jupyter/lab/user-settings/
JUPYTERLAB_WORKSPACES_DIR=$USER_MY_DATA/.jupyter/lab/workspaces/

mkdir MyData CommunityData NEES NHERI-Published
mkdir -p $JUPYTERLAB_SETTINGS_DIR $JUPYTERLAB_WORKSPACES_DIR

singularity run --env AGAVE_JOB_OWNER=$AGAVE_JOB_OWNER,AGAVE_JOB_ID=$AGAVE_JOB_ID,INTERACTIVE_WEBHOOK_URL=$INTERACTIVE_WEBHOOK_URL,JUPYTERLAB_SETTINGS_DIR=$JUPYTERLAB_SETTINGS_DIR,JUPYTERLAB_WORKSPACES_DIR=$JUPYTERLAB_WORKSPACES_DIR,CURRENT_WORKING_DIR=$CURRENT_WORKING_DIR,USER_MY_DATA=$USER_MY_DATA --contain -B $HOME,$PWD,/tmp,/share,/corral-repl/projects/NHERI/shared/$AGAVE_JOB_OWNER:$PWD/MyData:rw,/corral-repl/projects/NHERI/community:$PWD/CommunityData:ro,/corral-repl/projects/NHERI/public/projects:$PWD/NEES:ro,/corral-repl/projects/NHERI/published:$PWD/NHERI-Published:ro docker://taccaci/jupyter-lab-hpc:designsafe

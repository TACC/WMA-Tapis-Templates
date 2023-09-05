#!/bin/bash

echo "TACC: job ${SLURM_JOB_ID} execution at: $(date)"

mkdir CommunityData NEES NHERI-Published .tap .ssh

echo "singularity run --env USER=$USER,AGAVE_JOB_OWNER="${AGAVE_JOB_OWNER}",AGAVE_JOB_ID="${AGAVE_JOB_ID}",INTERACTIVE_WEBHOOK_URL="${_webhook_base_url}",SLURM_JOB_ID="${SLURM_JOB_ID}" --containall --bind "${PWD}":"${HOME}","${HOME}/.tap":"${HOME}/.tap":ro,"${HOME}/.ssh":"${HOME}/.ssh":ro,/tmp:/tmp:rw,/share/doc/slurm/tap_functions:/share/doc/slurm/tap_functions:ro,/corral-repl/projects/NHERI/community:"${HOME}/CommunityData":ro,/corral-repl/projects/NHERI/public/projects:"${HOME}/NEES":ro,/corral-repl/projects/NHERI/published:"${HOME}/NHERI-Published":ro docker://taccaci/jupyter-lab-hpc:designsafe"

singularity run --env USER=$USER,AGAVE_JOB_OWNER="${AGAVE_JOB_OWNER}",AGAVE_JOB_ID="${AGAVE_JOB_ID}",INTERACTIVE_WEBHOOK_URL="${_webhook_base_url}",SLURM_JOB_ID="${SLURM_JOB_ID}" --containall --bind "${PWD}":"${HOME}","${HOME}/.tap":"${HOME}/.tap":ro,"${HOME}/.ssh":"${HOME}/.ssh":rw,/tmp:/tmp:rw,/share/doc/slurm/tap_functions:/share/doc/slurm/tap_functions:ro,/corral-repl/projects/NHERI/community:"${HOME}/CommunityData":ro,/corral-repl/projects/NHERI/public/projects:"${HOME}/NEES":ro,/corral-repl/projects/NHERI/published:"${HOME}/NHERI-Published":ro docker://taccaci/jupyter-lab-hpc:designsafe

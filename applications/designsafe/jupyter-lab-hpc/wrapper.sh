#!/bin/bash

echo "TACC: job ${SLURM_JOB_ID} execution at: $(date)"

mkdir MyData CommunityData NEES NHERI-Published

singularity run --env AGAVE_JOB_OWNER=$AGAVE_JOB_OWNER,AGAVE_JOB_ID=$AGAVE_JOB_ID,INTERACTIVE_WEBHOOK_URL=$INTERACTIVE_WEBHOOK_URL --contain -B $HOME/.tap,$PWD,/tmp,/share,/corral-repl/projects/NHERI/shared/$AGAVE_JOB_OWNER:$PWD/MyData:rw,/corral-repl/projects/NHERI/community:$PWD/CommunityData:ro,/corral-repl/projects/NHERI/public/projects:$PWD/NEES:ro,/corral-repl/projects/NHERI/published:$PWD/NHERI-Published:ro docker://taccaci/jupyter-lab-hpc:designsafe

set -x
inputfile=$1

ibrun /work/projects/wma_apps/stampede3/mpm/mpm -f ${_tapisJobWorkingDir}/${inputDirectory}/ -i ${inputfile}

# Finish the job
echo "Job execution finished at: $(date)"
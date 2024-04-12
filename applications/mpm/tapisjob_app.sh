set -x
inputfile=$1

export LD_LIBRARY_PATH=$TACC_SWR_LIB:$LD_LIBRARY_PATH
ibrun /work/projects/wma_apps/frontera/mpm/build/mpm -f ${_tapisJobWorkingDir}/${inputDirectory}/ -i ${inputfile}
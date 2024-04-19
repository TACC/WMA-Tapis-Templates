#!/bin/bash
set -x
WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )
cd inputDirectory

# Parameters

inputFile=$1
precision=$pre
nodes=$_tapisNodes
ppn=$_tapisCoresPerNode

v1="S"
v2="D"

export LSTC_LICENSE=network
export LSTC_LICENSE_SERVER=31010@license03.tacc.utexas.edu
# Choose the appropriate binary based on the precision

if [ "$precision" == "$v1" ]; then
    lsdyna_bin="/home1/apps/ANSYS/2023R2/v232/ansys/bin/linx64/lsdyna_sp_mpp.e"
elif [ "$precision" == "$v2" ]; then
    lsdyna_bin="/home1/apps/ANSYS/2023R2/v232/ansys/bin/linx64/lsdyna_dp_mpp.e"
else
    echo "Invalid precision selection. Choose S for single or D for double."
    exit 1
fi

# Calculate total number of processors
total_procs=$((nodes*ppn))

echo "Running LS-DYNA for input file: $k_file with $total_procs total processors using binary $lsdyna_bin."

if [[ -f "$inputFile" ]]; then
    echo "Running LS-DYNA for input file: $inputFile with $total_procs total processors using binary $lsdyna_bin."
    ibrun -N=$nodes -n=$total_procs ${lsdyna_bin} i="${inputFile}" > "log_${inputFile%.k}.txt" 2>&1

    # Check if LS-DYNA finished successfully
    if [ $? -ne 0 ]; then
        echo "LS-DYNA simulation for input file: $inputFile exited with an error status. $?" >&2
        exit 1
    else
        echo "LS-DYNA simulation for input file: $inputFile completed successfully."
    fi
else
    echo "Input file $inputFile does not exist."
fi

# Finish the job
echo "Job ${_SLURM_JOB_ID} execution finished at: $(date)"
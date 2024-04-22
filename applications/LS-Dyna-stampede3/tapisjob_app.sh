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
    lsdyna_bin="/home1/apps/ANSYS/2024R1/v241/ansys/bin/linx64/lsdyna_sp_mpp.e"
elif [ "$precision" == "$v2" ]; then
    lsdyna_bin="/home1/apps/ANSYS/2024R1/v241/ansys/bin/linx64/lsdyna_dp_mpp.e"
else
    echo "Invalid precision selection. Choose S for single or D for double."
    exit 1
fi

# Calculate total number of processors
total_procs=$((nodes*ppn))

while IFS= read -u 9 k_file; do
    if [[ -f "$k_file" ]]; then
        k_file_path=$(realpath "$k_file")
        sim_dir="simulation_${k_file%.k}"
        mkdir -p "${sim_dir}"
        cd "${sim_dir}"

        echo "Running LS-DYNA for input file: $k_file with $total_procs total processors using binary $lsdyna_bin."
        ibrun ${lsdyna_bin} i=${k_file_path} > "log_${k_file%.k}.txt" 2>&1

        if [ $? -ne 0 ]; then
            echo "LS-DYNA simulation for input file: $k_file exited with an error status $status." >&2
            exit 1
        else
            echo "LS-DYNA simulation for input file: $k_file completed successfully."
        fi

	cd -
    else
        echo "Input file $k_file does not exist."
    fi

done 9< "$inputFile"

# Finish the job
echo "Job ${_SLURM_JOB_ID} execution finished at: $(date)"
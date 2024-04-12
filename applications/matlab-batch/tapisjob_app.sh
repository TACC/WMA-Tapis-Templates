# Matlab wrapper version R2023a for DesignSafe on Stampede3 - updated March 2023
set -x

cd ${workingDirectory}


matlab -nosplash -nodesktop < ${matlabScriptName} >> matlab_output.eo.txt 2>&1

# job is done!

echo job $_SLURM_JOB_ID execution finished at: `date`

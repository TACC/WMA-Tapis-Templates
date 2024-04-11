# SWbatch v0.2.1
# Written by: Joseph Vantassel (jvantassel@utexas.edu)
# Written on: 5 March 2019
# This code performs batch inversions that consider multiple paramaterizations

# Change log
# Last edit: 24 June 2019
# Update to loop over 2 targets, allow for more than 9 seeds, move extraction inside the loop.
# Last edit: 14 February 2020
# Bug fix with Np.
# Last edit: 17 May 2020
# Major refactoring.

# Setup
set -x
WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )
cd ${workingDirectory}

# Debug information
echo "workingDirectory  = ${workingDirectory}"
echo "name              = ${name}"
echo "ntrial            = ${ntrial}"
echo "It                = ${It}"
echo "Ns0               = ${Ns0}"
echo "Nr                = ${Nr}"
echo "Ns                = ${Ns}"
echo "nprofile          = ${nprofile}"
echo "fnum              = ${fnum}"
echo "fmin              = ${fmin}"
echo "fmax              = ${fmax}"

# Setpath to Geopsy Install
PATH=$PATH:/work/01698/rauta/geopsy/install/bin/

# List of .target files in 0_targets directory
tlist='0_targets/*.target'

# List of .param files in 1_parameters directory
plist='1_parameters/*.param'

# If 2_reports directory does not exist, create it
if [ ! -d "2_reports" ]; then
    mkdir 2_reports
fi

# If 3_text directory does not exist, create it
if [ ! -d "3_text" ]; then
    mkdir 3_text
fi

# Setup the meta-inversion loop
tarcount=0
for ctar in $tlist ; do
  if [ $tarcount -lt 2 ]; then
    tarname=${ctar##*/}
    tarroot=${tarname%%.*}
    for cpar in $plist ; do
      for trial in $(seq 0 $((${ntrial}-1))); do
        parname=${cpar##*/}
        parroot=${parname%%.*}
        rep=${name}_${tarroot}_${parroot}_Tr${trial}
              echo "${rep} Start">>3_text/transfer.log
        dinver -i DispersionCurve -optimization -itmax ${It} -ns0 ${Ns0} -ns ${Ns} -nr ${Nr} -target ${ctar} -param ${cpar} -o 2_reports/${rep}.report 2>> 2_reports/${rep}.log
        gpdcreport -best ${nprofile} 2_reports/${rep}.report | gpdc -R 1 -n ${fnum} -min ${fmin} -max ${fmax} > 3_text/${rep}_DC.txt 2>>3_text/transfer.log
        gpdcreport -best ${nprofile} 2_reports/${rep}.report > 3_text/${rep}_GM.txt 2>>3_text/transfer.log
              echo "${rep} Complete">>3_text/transfer.log
      done
    done
  fi
  tarcount=$((tarcount+1))
done
echo "Job Complete">>3_text/transfer.log

# Callback failure
if [ ! $? ]; then
        echo "SWbatch exited with an error status. $?" >&2
        ${AGAVE_JOB_CALLBACK_FAILURE}
        exit
fi
set -x
${AGAVE_JOB_CALLBACK_RUNNING}
echo "confFile is ${confFile}"
echo "namdCommandLineOptions is ${namdCommandLineOptions}"
echo "namd"
cd "${inputDirectory}"
ibrun namd2 ${namdCommandLineOptions} ${confFile}
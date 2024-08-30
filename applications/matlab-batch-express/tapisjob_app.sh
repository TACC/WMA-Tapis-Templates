# Matlab batch wrapper version R2022a for DesignSafe on VM ds-exec-01 - updated Jul 2022
handle_error() {
  local EXITCODE=$1
  echo "Matlab job exited with an error status. $EXITCODE" >&2
  echo "$EXITCODE" > "${_tapisExecSystemOutputDir}/tapisjob.exitcode"
  exit $EXITCODE
}

set -x
echo "TACC: job $_tapisJobUUID execution at: `date`"

# set up license file
cat << EOT >> .matlab_license
${_license}
USE_SERVER
EOT

cat .matlab_license
export LM_LICENSE_FILE=`pwd`/.matlab_license
echo "LM_LICENSE_FILE is : $LM_LICENSE_FILE"

cd ${workingDirectory}

echo "Directory is `pwd`"
echo "File is ${matlabScriptName}"
formattedInputFile="$( basename ${inputfile} .m )"

apptainer run \
  --writable-tmpfs \
  --memory 1G \
	--bind "`pwd`":"/data/" \
	--bind ${LM_LICENSE_FILE}:/licenses/matlab.lic \
	--env MLM_LICENSE_FILE=/licenses/matlab.lic \
	docker://mathworks/matlab:latest /bin/sh -c "cd /data; matlab -batch ${formattedInputFile}"


if [ ! $? ]; then
    handle_error 1

# job is done!

echo job $_tapisJobUUID execution finished at: `date`

cd ..
rm -rf .matlab_license
rm -rf vncp.txt

#sleep to let the files get cleaned up
sleep 2

exit 0
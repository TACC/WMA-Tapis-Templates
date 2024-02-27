set -x
WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )

echo "inputScript is ${inputScript}"
INPUTSCRIPT='${inputScript}'
echo "INPUTSCRIPT is $INPUTSCRIPT"
TCLSCRIPT="${INPUTSCRIPT##*/}"

echo "TCLSCRIPT is $TCLSCRIPT"

docker run -i --user 458981:816877 --sig-proxy=true --rm \
			-m 1G --name "opensees_${AGAVE_JOB_OWNER}_${AGAVE_JOB_ID}"\
			-v "`pwd`/${inputDirectory}":"/data/" \
			wangyinz/opensees-container /bin/sh -c "cd /data ; OpenSees < /data/$TCLSCRIPT"

if [ ! $? ]; then
	echo "Docker container exited with an error status. $?" >&2
	${AGAVE_JOB_CALLBACK_FAILURE}
	exit
fi

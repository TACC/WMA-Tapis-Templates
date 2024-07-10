set -x
# Run the script with the runtime values passed in from the job request

echo "Potree Converter 2.1.1"

/opt/PotreeConverter/build/PotreeConverter ${converterInput} -o ${_tapisExecSystemOutputDir} --generate-page index ${addArgs}

if [ ! $? ]; then
    EXITCODE=$1
    echo "PotreeConverter exited with an error status. $EXITCODE" >&2
    echo "$EXITCODE" > "${_tapisExecSystemOutputDir}/tapisjob.exitcode"
    exit $EXITCODE
fi

exit 0

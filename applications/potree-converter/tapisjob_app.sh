set -x
# Run the script with the runtime values passed in from the job request

echo "Potree Converter 2.1.1"

/opt/PotreeConverter/build/PotreeConverter ${converterInput} -o ${_tapisExecSystemOutputDir} -m ${samplingMethod}

if [ ! $? ]; then
      echo "PotreeConverter exited with an error status. $?" >&2
      exit
fi

exit 0
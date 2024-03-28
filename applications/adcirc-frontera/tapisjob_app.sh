set -x
# Run the script with the runtime values passed in from the job request

echo "ADCIRC NETCDF v55.01"
cd ${inputDirectory}

adcirc >> ${_tapisStdoutFilename} 2>&1

cd ..

if [ ! $? ]; then
      echo "ADCIRC exited with an error status. $?" >&2
      exit
fi

exit 0

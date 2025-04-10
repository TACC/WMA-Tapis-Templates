set -x

# Run the script with the runtime values passed in from the job request

cd ${inputDirectory}

# generate the two prep files
CORES=$((${_tapisNodes}*${_tapisCoresPerNode}))
echo "The cores for this run are $CORES"

SCORES=$(( $CORES-2 ))

rm -rf in.prep1 in.prep2 &>/dev/null

cat << EOT >> in.prep1
$SCORES
1
fort.14
EOT

cat << EOT >> in.prep2
$SCORES
2
EOT

ADCPREP=/work2/06307/clos21/shared/adcirc/s3/v56.0.2/adcprep
PADCIRC=/work2/06307/clos21/shared/adcirc/s3/v56.0.2/padcirc

# run adcprep pre-processing
$ADCPREP < ./in.prep1
$ADCPREP < ./in.prep2

# run padcirc binary
ibrun $PADCIRC -W 2 >> output.eo.txt 2>&1

cd ..

if [ ! $? ]; then
	echo "PADCIRC exited with an error status. $?" >&2
	exit
fi

exit 0

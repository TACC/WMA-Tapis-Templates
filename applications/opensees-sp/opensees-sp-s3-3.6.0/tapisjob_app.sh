set -x

BINARYNAME=$1
INPUTSCRIPT=$2
echo "INPUTSCRIPT is $INPUTSCRIPT"

TCLSCRIPT="${INPUTSCRIPT##*/}"
echo "TCLSCRIPT is $TCLSCRIPT"

cd "${inputDirectory}"

echo "Running $BINARYNAME"

ibrun $BINARYNAME $TCLSCRIPT
if [ ! $? ]; then
      echo "OpenSees exited with an error status. $?" >&2
      exit
fi

cd ..
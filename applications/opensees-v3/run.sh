set -x

INPUTSCRIPT='${inputScript}'

echo "INPUTSCRIPT is $INPUTSCRIPT"

TCLSCRIPT="${INPUTSCRIPT##*/}"

echo "TCLSCRIPT is $TCLSCRIPT"

cd "${inputDirectory}"

echo "Running OpenSeesSP"

ibrun OpenSeesSP $TCLSCRIPT

if [ ! $? ]; then

    echo "OpenSees exited with an error status. $?" >&2

    exit 1

fi

cd ..
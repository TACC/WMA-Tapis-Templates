set -x

echo "TACC: unloading xalt"
module unload xalt

# Change to input directory
cd inputDirectory
inputfile=$1

apptainer exec library://georgiastuart/figuregen/figuregen-serial figuregen -I ${inputfile}
cd ..

if [ ! $? ]; then
        echo "figuregen exited with an error status. $?" >&2
        exit 1
fi

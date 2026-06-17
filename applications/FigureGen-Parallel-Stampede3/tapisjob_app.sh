set -x
WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )

export FI_PROVIDER=tcp

 #Change to input directory
cd inputDirectory
inputfile=$1

ibrun apptainer run docker://clos21/figuregen-tacc-ubuntu18-impi19.0.7-common:latest figuregen -I ${inputfile}
cd ..

if [ ! $? ]; then
        echo "figuregen exited with an error status. $?" >&2
        exit 1
fi
set -x
WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )

 #Change to input directory
cd inputDirectory
inputfile=$1

# Do not set GMT and GhostScript paths, they are available via the container
sed -e "4s/.*/                                                   ! Path where GMT executables are located./" -i ${inputfile}
sed -e "5s/.*/                                                   ! Path where GhostScript executable is located./" -i ${inputfile}


apptainer exec library://georgiastuart/figuregen/figuregen-serial figuregen -I ${inputfile}
cd ..

if [ ! $? ]; then
        echo "figuregen exited with an error status. $?" >&2
        exit 1
fi
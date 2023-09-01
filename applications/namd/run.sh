#!/bin/bash
#SBATCH --ntasks-per-node=$2

echo "confFile is $1"
echo "namdCommandLineOptions is $2"
cd dataDir

if [ $2 = 4 ]; then
    echo "namdCommandLineOptions is $2"
	/opt/apps/intel19/impi19_0/namd/2.14/bin/namd2 +ppn 13 +pemap 2-26:2,30-54:2,3-27:2,31-55:2 +commap 0,28,1,29 $1
fi

if [ $2 = 8 ]; then
    echo "namdCommandLineOptions is $2"
	/opt/apps/intel19/impi19_0/namd/2.14/bin/namd2 +ppn 6 +pemap 2-12:2,16-26:2,30-40:2,44-54:2,3-13:2,17-27:2,31-41:2,45-55:2 +commap 0,14,28,42,1,15,29,43 $1
fi

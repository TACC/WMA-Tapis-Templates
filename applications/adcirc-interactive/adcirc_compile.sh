#!/usr/bin/bash

################################################################################
# Script: adcirc_compile.sh
#
# Description:
#   This script is used to compile the ADCIRC suite on Ubuntu.
#
# Example usage:
# ./adcirc_compile.sh v55.02 https://github.com/adcirc/adcirc 1
#
# Will build 
#
# Note: Make sure you have the necessary dependencies installed before running
#       this script. 
################################################################################

helpFunction()
{
	echo ""
	echo "Usage: $0 name [git] [tag] [targetDir]"
	echo -e "\tname - of adcirc to version/tag to build. Must be valid github version/tag at https://github.com/adcirc/adcirc, or at the git url provided"
	echo -e "\tgit - URL. Default at https://github.com/adcirc/adcirc)"
	echo -e "\ttag - 1 if is tagged version, 0 if not. Default is 0."
	echo -e "\ttargetDir - Directory to store the executables. Default is the current working directory."
	exit 1 # Exit script after printing help
}

log () {
  echo "$(date) | ADCIRC_COMPILE | ${1} | ${2}"
}

# Print helpFunction in case parameters are empty
name=$1
if [ -z "$name" ]
then
	echo "Must specify version/tag name.";
	helpFunction
fi

gitURL=$2
if [ -z "$gitURL" ]
then
	gitURL="https://github.com/adcirc/adcirc-cg"
fi

tag=$3

targetDir=$4
if [ -z "$targetDir" ]
then
	targetDir=$(pwd)
fi

# Make ExeDir if it doesn't exist
mkdir -p $targetDir
cd $targetDir

# Make directory for particular version
binDir="$targetDir/bin/$name"
mkdir -p $binDir	

# Checkout adcirc repository in work directory if does not exist
if [ -d "repo" ]
then
	rm -rf repo
fi

log INFO "Cloning ADCIRC repo at $gitURL"
git clone $gitURL repo

# Move into git repo
cd repo

# Fetch all remote tags/branches
git config pull.rebase true
log INFO "Updating repo"
git fetch --all --tags
git pull

# Checkout version branch or tagged version
if [[ "$tag" -eq "1" ]]
then
	log INFO "Checking out tag $name"
	git checkout tags/$name -B  $name-branch
else
	log INFO "Checking out branch $name"
	git checkout remotes/origin/$name -B  $name-build
fi

if [ $? -eq 0 ]; then
	log INFO "Checked out $name successfully"
else
	log ERROR "Error checking out $name"
	exit 1
fi

# Make new cmake build dir
mkdir -p build
cd build

cmake .. \
	-DCMAKE_C_COMPILER=mpicc \
	-DCMAKE_CXX_COMPILER=mpicxx \
	-DCMAKE_Fortran_COMPILER=gfortran \
	-DENABLE_GRIB2=ON \
	-DENABLE_DATETIME=ON \
	-DENABLE_OUTPUT_NETCDF=ON \
	-DBUILD_ADCPREP=ON \
	-DBUILD_ADCIRC=ON \
	-DBUILD_PADCIRC=ON \
	-DBUILD_ADCSWAN=ON \
	-DBUILD_PADCSWAN=ON \

if [ $? -eq 0 ]; then
	log INFO "cmake configuration complete"
else
	log ERROR "cmmake configuration error"
	exit 1
fi

make -j6

if [ $? -eq 0 ]; then
	log INFO "make complete"
else
	log ERROR "make error"
	exit 1
fi

# Copy executables to binDir
cp adcprep adcirc padcirc padcswan adcswan /usr/local/bin/

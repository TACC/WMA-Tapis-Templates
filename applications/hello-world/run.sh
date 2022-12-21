#!/bin/bash
echo "Your command line args (appArgs) are: $@"

Greeting=$1
Target=$2
SleepTime=$3

echo "Sleeping for ${SleepTime} seconds"
sleep $SleepTime

FULL_GREETING="${Greeting} ${Target}. My name is ${_tapisJobOwner}"
echo "$FULL_GREETING"
echo `pwd`

fileToModify=$_tapisExecSystemInputDir/in.txt

if [ -e "$fileToModify" ]
then
    echo $FULL_GREETING >> $fileToModify
    cp $fileToModify $_tapisExecSystemOutputDir
else
    echo $FULL_GREETING > $_tapisExecSystemOutputDir/out.txt
fi

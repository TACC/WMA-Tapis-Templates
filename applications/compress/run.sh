#!/bin/bash

CTYPE=$1
echo "Compression Type is ${CTYPE}"

ARCHIVE_FILE_NAME=$2

cd $_tapisExecSystemInputDir

if [ "$CTYPE" = "tgz" ]; then
  echo 'tarring'
  tar czvf "${_tapisExecSystemOutputDir}/$ARCHIVE_FILE_NAME.tar.gz" .
else
  echo 'zipping'
  zip "${_tapisExecSystemOutputDir}/$ARCHIVE_FILE_NAME.zip" ./*
fi

if [ ! $? ]; then
	echo "Compress exited with an error status. $?" >&2
	exit
fi

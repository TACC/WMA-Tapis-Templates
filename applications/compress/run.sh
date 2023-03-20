#!/bin/bash

CTYPE=$1
echo "Compression Type is ${CTYPE}"

ARCHIVE_FILE_NAME=$2

if [ "$CTYPE" = "tgz" ]; then
  echo 'tarring'
  tar czvf "${_tapisExecSystemOutputDir}/$ARCHIVE_FILE_NAME.tar.gz" "${_tapisExecSystemInputDir}/*";
else
  echo 'zipping'
  zip -r "${_tapisExecSystemOutputDir}/$ARCHIVE_FILE_NAME.zip" "${_tapisExecSystemInputDir}"
fi

if [ ! $? ]; then
	echo "Compress exited with an error status. $?" >&2
	exit
fi

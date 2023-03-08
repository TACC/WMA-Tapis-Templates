#!/bin/bash

CTYPE=$1
echo "Compression Type is ${CTYPE}"

if [ "$CTYPE" = "tgz" ]; then
  echo 'tarring'
  tar czvf "${_tapisExecSystemOutputDir}/Archive.tar.gz" "${_tapisExecSystemInputDir}/*";
else
  echo 'zipping'
  zip -j -r "${_tapisExecSystemOutputDir}/Archive.zip" "${_tapisExecSystemInputDir}"
fi

if [ ! $? ]; then
	echo "Compress exited with an error status. $?" >&2
	exit
fi

#!/bin/bash

for EXTRACTFILE in $_tapisExecSystemInputDir/*; do
  if [[ "${EXTRACTFILE}" =~ \.t?gz$ ]]; then
    tar xzf "${EXTRACTFILE}" -C ${_tapisExecSystemOutputDir}
  elif [[ "${EXTRACTFILE}" =~ \.tar\.gz$ ]]; then
    tar xzf "${EXTRACTFILE}" -C ${_tapisExecSystemOutputDir}
  elif [[ "${EXTRACTFILE}" =~ \.tar$ ]]; then
    tar xf "${EXTRACTFILE}" -C ${_tapisExecSystemOutputDir}
  elif [[ "${EXTRACTFILE}" =~ \.gz$ ]]; then
    gunzip "${EXTRACTFILE}"
    cp -r ./* ${_tapisExecSystemOutputDir}
  elif [[ "${EXTRACTFILE}" =~ \.zip$ ]]; then
    unzip "${EXTRACTFILE}" -d ${_tapisExecSystemOutputDir}
  else
    echo 'unrecoginized file extension'
    echo $EXTRACTFILE
    exit 1
  fi
done

if [ ! $? ]; then
	echo "Extract exited with an error status. $?" >&2
	exit
fi

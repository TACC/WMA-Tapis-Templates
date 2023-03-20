#!/bin/bash

for EXTRACTFILE in $_tapisExecSystemInputDir/*; do
  # Use the unar command line utility to unarchive any archive type.
  # -r flag will avoid overwriting files, and -d will extract the archive into a directory of the same name of the archive file
  unar "${EXTRACTFILE}" -o ${_tapisExecSystemOutputDir} -r -d
done

if [ ! $? ]; then
	echo "Extract exited with an error status. $?" >&2
	exit
fi

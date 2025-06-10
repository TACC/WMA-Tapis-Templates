#!/bin/bash

for EXTRACTFILE in $_tapisExecSystemInputDir/*; do
  # Use tar or unzip based on archive file extension.
  # tar -k prevents overwrite, --one-top-level stores extracted files in folder with same base name as archive file
  # unzip -n prevents overwrite, does not natively support retaining archive base name for storing extracted files
  FILENAME=$(basename -- "$EXTRACTFILE");
  FILEEXT="${FILENAME#*.}";
  case "$FILEEXT" in 
    'tar'|'tar.gz'|'tgz'|'gz')
      tar -zkxvf "${EXTRACTFILE}" -C ${_tapisExecSystemOutputDir} --one-top-level
      ;;
    'zip')
      unzip -n "${EXTRACTFILE}" -d ${_tapisExecSystemOutputDir}
      ;;
  esac
done

if [ ! $? ]; then
	echo "Extract exited with an error status. $?" >&2
	exit
fi

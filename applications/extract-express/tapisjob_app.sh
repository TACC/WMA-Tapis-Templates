#!/bin/bash

for EXTRACTFILE in $_tapisExecSystemInputDir/*; do
  # Use tar or unzip based on archive file extension, will output all contents to folder with same basename as input archive
  # tar -k prevents overwrite
  # unzip -n prevents overwrite
  FILENAME=$(basename -- "$EXTRACTFILE");
  FILENAME_NO_EXT="${FILENAME%%.*}";  # for naming output folder
  FILEEXT="${FILENAME##*.}";
  case "$FILEEXT" in 
    'tar'|'tar.gz'|'tgz'|'gz')
      mkdir -p "${_tapisExecSystemOutputDir}/${FILENAME_NO_EXT}" && 
        tar -zkxvf "${EXTRACTFILE}" -C "${_tapisExecSystemOutputDir}/${FILENAME_NO_EXT}"
      ;;
    'zip')
      unzip -n "${EXTRACTFILE}" -d "${_tapisExecSystemOutputDir}/${FILENAME_NO_EXT}"
      ;;
    *)
      echo "Extracting archive file containing .${FILEEXT} not supported."
      ;;
  esac
done

if [ ! $? ]; then
	echo "Extract exited with an error status. $?" >&2
	exit
fi

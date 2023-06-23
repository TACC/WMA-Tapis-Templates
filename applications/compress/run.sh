#!/bin/bash

CTYPE=$1
echo "Compression Type is ${CTYPE}"

ARCHIVE_FILE_NAME="$2"

replace_special_chars() {
  local string="$1"
  local pattern='[!@# $%^&*(),.?":{}|<>]'

  if [[ $string =~ $pattern ]]; then
    local replacement="_"
    local sanitized_string=$(echo "$string" | sed 's/[!@# $%^&*(),.?":{}|<>]/'"$replacement"'/g')
    echo "$sanitized_string"
  else
    local sanitized_string=$string
    echo "$sanitized_string"
  fi
}

cd $_tapisExecSystemInputDir

modified_archive_file_name=$(replace_special_chars "$ARCHIVE_FILE_NAME")

echo $modified_archive_file_name

if [ "$CTYPE" = "tgz" ]; then
  echo 'tarring'
  tar -czvf "${_tapisExecSystemOutputDir}/$modified_archive_file_name.tar.gz" .
else
  echo 'zipping'
  zip "${_tapisExecSystemOutputDir}/$modified_archive_file_name.zip" ./*
fi

if [ ! $? ]; then
	echo "Compress exited with an error status. $?" >&2
	exit
fi

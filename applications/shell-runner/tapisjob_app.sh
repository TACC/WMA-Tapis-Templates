#!/bin/bash

SHELL_COMMAND="$@"

echo "SHELL_COMMAND is $SHELL_COMMAND"

if [ -d "${inputDirectory}" ]; then
    echo "Changing directory to input directory..."
    cd "${inputDirectory}"
fi

echo "Running $SHELL_COMMAND"

$SHELL_COMMAND

if [ ! $? ]; then
    echo "Job exited with an error status. $?" >&2
    exit
fi

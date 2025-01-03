#!/bin/bash

SHELL_COMMAND=$1

echo "SHELL_COMMAND is $SHELL_COMMAND"

cd "${inputDirectory}"

echo "Running $SHELL_COMMAND"

$SHELL_COMMAND

if [ ! $? ]; then
    echo "Job exited with an error status. $?" >&2
    exit
fi

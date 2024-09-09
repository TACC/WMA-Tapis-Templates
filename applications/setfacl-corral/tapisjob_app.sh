#!/bin/bash

set -x

# username is either an individual username or comma-separated list
IFS=',' read -ra USERNAMES <<< ${username}

ACL_ADD_COMMANDS=()
ACL_REMOVE_COMMANDS=()
for delimitedUser in $USERNAMES;
    do
        USER_ID=$(id -u ${delimitedUser})
        echo "user id: $USER_ID"
        ACL_ADD_COMMANDS+=("d:u:${USER_ID}:rwX,u:${USER_ID}:rwX")
        ACL_REMOVE_COMMANDS+=("d:u:${USER_ID},u:${USER_ID}")
    done

ACL_ADD_STRING=$(IFS=","; echo "${ACL_ADD_COMMANDS[*]}")
ACL_REMOVE_STRING=$(IFS=","; echo "${ACL_REMOVE_COMMANDS[*]}")


if [ "${action}" == "add" ];
then
    echo "Running: setfacl -R -m ${ACL_ADD_STRING} ${directory}"
    setfacl -R -m ${ACL_ADD_STRING} ${directory}
fi

if [ "${action}" == "remove" ];
then
    echo "Running: setfacl -R -x ${ACL_REMOVE_STRING} ${directory}"
    setfacl -R -x ${ACL_REMOVE_STRING} ${directory}
fi

if [ "${action}" == "dryrun" ];
then
    echo "ACL add command: setfacl -R -m ${ACL_ADD_STRING} ${directory}"
    echo "ACL remove command: setfacl -R -x ${ACL_REMOVE_STRING} ${directory}"
fi

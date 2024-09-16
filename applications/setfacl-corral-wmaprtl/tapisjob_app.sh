#!/bin/bash

set -x
chmod +x ./getUID.sh
chmod +x ./JSON.sh

# usernames is either an individual username or comma-separated list
IFS=',' read -ra USERNAMES <<< ${usernames}

ACL_COMMANDS=()
for delimitedUser in ${USERNAMES[@]};
    do
        USER_ID=$(./getUID.sh ${delimitedUser})
        echo "user id: $USER_ID"
        
        case ${role} in
            reader)
                ACL_COMMANDS+=("d:u:${USER_ID}:rX,u:${USER_ID}:rX")
                ;;
            writer)
                ACL_COMMANDS+=("d:u:${USER_ID}:rwX,u:${USER_ID}:rwX")
                ;;
            none)
                ACL_COMMANDS+=("d:u:${USER_ID},u:${USER_ID}")
                ;;
            *)
                echo "Invalid role: ${role}. Must be one of: reader, writer, none."
                exit 1
                ;;
        esac
    done

ACL_STRING=$(IFS=","; echo "${ACL_COMMANDS[*]}")

if [ "${action}" == "add" ];
then
    echo "Running: setfacl -R -m ${ACL_STRING} ${directory}"
    setfacl -R -m ${ACL_STRING} ${directory}
fi

if [ "${action}" == "remove" ];
then
    echo "Running: setfacl -R -x ${ACL_STRING} ${directory}"
    setfacl -R -x ${ACL_STRING} ${directory}
fi

if [ "${action}" == "dryrun" ];
then
    echo "ACL add command: setfacl -R -m ${ACL_STRING} ${directory}"
    echo "ACL remove command: setfacl -R -x ${ACL_STRING} ${directory}"
fi

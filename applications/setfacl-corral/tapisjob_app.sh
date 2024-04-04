set -x

USER_ID=$(id -u ${username})
echo "user id: $USER_ID"

if [ "${action}" == "add" ];
then
    echo "Running: setfacl -R -m d:u:${USER_ID}:rwX,u:${USER_ID}:rwX ${directory}"
    setfacl -R -m d:u:${USER_ID}:rwX,u:${USER_ID}:rwX ${directory}
else
    if [ "${action}" == "remove" ];
    then
        echo "Running: setfacl -R -x d:u:${USER_ID},u:${USER_ID} ${directory}"
        setfacl -R -x d:u:${USER_ID},u:${USER_ID} ${directory}
    fi
fi

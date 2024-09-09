#!/bin/bash

echo "TACC: job ${_tapisJobUUID} execution at: $(date)"

# copy default jupyter .bashrc and .profile to $HOME if it doesn't exist
if [ ! -f $HOME/.bashrc ]; then
    cp /home/jovyan/.bashrc $HOME
    source $HOME/.bashrc
fi
if [ ! -f $HOME/.profile ]; then
    cp /home/jovyan/.profile $HOME
fi

function session_get_token()
{
    local TAP_TOKEN=$(python -c "from secrets import token_hex; print(token_hex())" 2> /dev/null)
    echo ${TAP_TOKEN}
}

# create jupyter session token
SESSION_TOKEN=$(session_get_token)
if [ -z "${SESSION_TOKEN}" ]; then
    echo "TACC: ERROR - could not generate token for jupyter session"
    exit 1
fi
echo "TACC: using token ${SESSION_TOKEN}"


# define jupyter config file
JUPYTER_CONFIG="/tmp/jupyter_config.py"

cat <<- EOF > ${JUPYTER_CONFIG}
# Configuration file for jupyter session
import ssl
c = get_config()
c.IPKernelApp.pylab = "inline"  # if you want plotting support always
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = ${LOGIN_PORT}
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = u"*"
c.ServerApp.ssl_options = {"ssl_version": ssl.PROTOCOL_TLSv1_2}
c.ServerApp.root_dir = "${HOME}"
c.ServerApp.preferred_dir = "${HOME}"
c.ServerApp.token = "${SESSION_TOKEN}"
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash', '--login', '-i']}
EOF

JUPYTER_URL="https://${VM_HOST}:${LOGIN_PORT}/?token=${SESSION_TOKEN}"
echo "TACC:     JUPYTER_URL is $JUPYTER_URL"

# Wait a few seconds for jupyter to boot up and send webhook callback url for job ready notification.
# Notification is sent to _INTERACTIVE_WEBHOOK_URL, e.g. https://3dem.org/webhooks/interactive/
(
    sleep 5 &&
    curl -k --data "event_type=interactive_session_ready&address=${JUPYTER_URL}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &
) &

# launch jupyter
JUPYTER_ARGS="--certfile=/etc/nginx/ssl/nginx.crt --keyfile=/etc/nginx/ssl/nginx.key --config=${JUPYTER_CONFIG}"
echo "TACC: using jupyter command: jupyter-lab ${JUPYTER_ARGS}"

export PATH=$HOME/.local/bin:$PATH

jupyter-lab ${JUPYTER_ARGS}

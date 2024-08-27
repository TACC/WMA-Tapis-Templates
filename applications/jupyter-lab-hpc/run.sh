#!/bin/bash

JUPYTER_URL="https://${NODE_HOSTNAME_DOMAIN}:${LOGIN_PORT}/?token=${TAP_TOKEN}"
echo "TACC:     JUPYTER_URL is $JUPYTER_URL"

# Wait a few seconds for jupyter to boot up and send webhook callback url for job ready notification.
# Notification is sent to _INTERACTIVE_WEBHOOK_URL, e.g. https://3dem.org/webhooks/interactive/
(
    sleep 5 &&
    curl -k --data "event_type=interactive_session_ready&address=${JUPYTER_URL}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &
) &

# create the tap jupyter config if needed
JUPYTER_CONFIG="${_tapisJobWorkingDir}/jupyter_config.py"

cat <<- EOF > ${JUPYTER_CONFIG}
# Configuration file for TAP jupyter session
import ssl
c = get_config()
c.IPKernelApp.pylab = "inline"  # if you want plotting support always
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = $LOCAL_PORT
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = u"*"
c.ServerApp.ssl_options = {"ssl_version": ssl.PROTOCOL_TLSv1_2}
c.ServerApp.root_dir = "${HOME}"
c.ServerApp.preferred_dir = "${HOME}"
c.IdentityProvider.token = "${TAP_TOKEN}"
EOF

JUPYTER_ARGS="--certfile=${TAP_CERTFILE} --config=${JUPYTER_CONFIG}"

echo "TACC: using jupyter command: jupyter-lab ${JUPYTER_ARGS}"

export PATH=$HOME/.local/bin:$PATH

# copy default jupyter .bashrc and .profile to $HOME if it doesn't exist
if [ ! -f $HOME/.bashrc ]; then
    cp /home/jovyan/.bashrc $HOME
fi
if [ ! -f $HOME/.profile ]; then
    cp /home/jovyan/.profile $HOME
fi

source $HOME/.bashrc

jupyter-lab ${JUPYTER_ARGS}

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT} 2> /dev/null)"

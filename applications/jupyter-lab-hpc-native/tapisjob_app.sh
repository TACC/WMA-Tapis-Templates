#!/bin/bash

# Home Dir for Jupyter Notebook HPC Native for persistent storage between sessions
JUPYTER_HOME=$HOME/.jupyter-notebook-hpc-native
mkdir -p $JUPYTER_HOME

# Make symlinks for work, home and scratch
if [ ! -L $JUPYTER_HOME/Work ];
then
    ln -s $STOCKYARD $JUPYTER_HOME/Work
fi

if [ ! -L $JUPYTER_HOME/Home ];
then
    ln -s $HOME $JUPYTER_HOME/Home
fi

if [ ! -L $JUPYTER_HOME/Scratch ];
then
    ln -s $SCRATCH $JUPYTER_HOME/Scratch
fi

if [ ! -L $JUPYTER_HOME/MyData ];
then
    ln -s /data/designsafe/mydata/${_tapisJobOwner} $JUPYTER_HOME/MyData
fi

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
c.NotebookApp.ip = "0.0.0.0"
c.NotebookApp.port = $LOCAL_PORT
c.NotebookApp.open_browser = False
c.NotebookApp.allow_origin = u"*"
c.NotebookApp.ssl_options = {"ssl_version": ssl.PROTOCOL_TLSv1_2,}
c.NotebookApp.notebook_dir = "${JUPYTER_HOME}"
c.NotebookApp.token = "${TAP_TOKEN}"
EOF

JUPYTER_ARGS="--certfile=${TAP_CERTFILE} --config=${JUPYTER_CONFIG}"

echo "TACC: using jupyter command: jupyter-notebook ${JUPYTER_ARGS}"

jupyter-notebook ${JUPYTER_ARGS}

# clean up symlinks
rm $JUPYTER_HOME/Work $JUPYTER_HOME/Home $JUPYTER_HOME/Scratch $JUPYTER_HOME/MyData

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT} 2> /dev/null)"

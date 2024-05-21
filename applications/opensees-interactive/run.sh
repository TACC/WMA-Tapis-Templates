#!/bin/bash

echo "TACC: job ${_tapisJobUUID} execution at: $(date)"

# This file will be located in the directory mounted by the job.
SESSION_FILE=delete_me_to_end_session
touch $SESSION_FILE


NODE_HOSTNAME_PREFIX=$(hostname -s)   # Short Host Name  -->  name of compute node: c###-###
NODE_HOSTNAME_LONG=$(hostname -f)     # Fully Qualified Domain Name  -->  c###-###.stampede2.tacc.utexas.edu

JUPYTER_BIN="jupyter-lab"

NB_SERVERDIR=$HOME/work/MyData/.jupyter

# make .jupyter dir for logs
mkdir -p ${NB_SERVERDIR}

# create the jupyter config
JUPYTER_CONFIG="$NB_SERVERDIR/jupyter_config.py"

function session_get_token()
{
    local TAP_TOKEN=$(python -c "from secrets import token_hex; print(token_hex())" 2> /dev/null)
    echo ${TAP_TOKEN}
}

# bail if we cannot create a token for the session
SESSION_TOKEN=$(session_get_token)
if [ -z "${SESSION_TOKEN}" ]; then
    echo "TACC: ERROR - could not generate token for jupyter session"
    exit 1
fi
echo "TACC: using token ${SESSION_TOKEN}"

cat <<- EOF > ${JUPYTER_CONFIG}
# Configuration file for jupyter session
import ssl
c = get_config()
c.IPKernelApp.pylab = "inline"  # if you want plotting support always
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = u"*"
c.ServerApp.ssl_options = {"ssl_version": ssl.PROTOCOL_TLSv1_2}
c.ServerApp.root_dir = "$HOME"
c.ServerApp.preferred_dir = "$HOME/work"
c.ServerApp.token = "${SESSION_TOKEN}"
EOF

# launch jupyter
JUPYTER_LOGFILE=${NB_SERVERDIR}/${NODE_HOSTNAME_PREFIX}.log
touch $JUPYTER_LOGFILE

JUPYTER_ARGS="--certfile=/etc/nginx/ssl/nginx.crt --keyfile=/etc/nginx/ssl/nginx.key --config=${JUPYTER_CONFIG}"
echo "TACC: using jupyter command: ${JUPYTER_BIN} ${JUPYTER_ARGS} &> ${JUPYTER_LOGFILE} &"
nohup ${JUPYTER_BIN} ${JUPYTER_ARGS} &> ${JUPYTER_LOGFILE} &

JUPYTER_PID=$!

JUPYTER_URL="https://${VM_HOST}:${LOGIN_PORT}/?token=${SESSION_TOKEN}"

echo "JUPYTER_URL is $JUPYTER_URL"


# Webhook callback url for job ready notification.
# Notification is sent to _INTERACTIVE_WEBHOOK_URL, e.g. https://3dem.org/webhooks/interactive/
curl -k --data "event_type=interactive_session_ready&address=${JUPYTER_URL}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &

# Delete the session file to kill the job.
echo $NODE_HOSTNAME_LONG $IPYTHON_PID > $SESSION_FILE

# While the session file remains undeleted, keep Jupyter session running.
while [ -f $SESSION_FILE ] ; do
    sleep 10
done

#!/bin/bash

echo "TACC: job ${SLURM_JOB_ID} execution at: $(date)"

NODE_HOSTNAME_PREFIX=$(hostname -s)
NODE_HOSTNAME_DOMAIN=$(hostname -d)

echo "TACC: running on node $NODE_HOSTNAME_PREFIX on $NODE_HOSTNAME_DOMAIN"

TAP_FUNCTIONS="/share/doc/slurm/tap_functions"
if [ -f ${TAP_FUNCTIONS} ]; then
    . ${TAP_FUNCTIONS}
else
    echo "TACC:"
    echo "TACC: ERROR - could not find TAP functions file: ${TAP_FUNCTIONS}"
    echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
    echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
    echo "TACC:"
    echo "TACC: job $SLURM_JOB_ID execution finished at: $(date)"
    exit 1
fi

# bail if we cannot create a secure session
mkdir -p ${HOME}/.tap
TAP_CERTFILE=$(cat ${HOME}/.tap/.${SLURM_JOB_ID})
if [ ! -f ${TAP_CERTFILE} ]; then
    echo "TACC: ERROR - could not find TLS cert for secure session"
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi

# bail if we cannot create a token for the session
TAP_TOKEN=$(tap_get_token)
if [ -z "${TAP_TOKEN}" ]; then
    echo "TACC: ERROR - could not generate token for jupyter session"
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi
echo "TACC: using token ${TAP_TOKEN}"

# App Port
LOCAL_PORT=8888

# TAP Port
LOGIN_PORT=$(tap_get_port)
echo "TACC: got login node jupyter port ${LOGIN_PORT}"

# Port forwarding is set up for up to four login nodes. Frontera has 4, LS6 has 3.
#
#   f: Requests ssh to go to background just before command execution.
#      Used if ssh asks for passwords but the user wants it in the background. Implies -n too.
#   g: Allows remote hosts to connect to local forwarded ports
#   N: Do not execute a remote command. Useful for just forwarding ports.
#   R: Connections to given TCP port/Unix socket on remote (server) host forwarded to local side.
#
# Create a reverse tunnel port from the compute node to the login nodes.
# Make one tunnel for each login node so the user can just connect to $NODE_HOSTNAME_DOMAIN
for i in `seq 4`; do
  ssh -o StrictHostKeyChecking=no -f -g -N -R ${LOGIN_PORT}:${NODE_HOSTNAME_PREFIX}:${LOCAL_PORT} login${i}
done

JUPYTER_URL="https://${NODE_HOSTNAME_DOMAIN}:${LOGIN_PORT}/?token=${TAP_TOKEN}"
echo "TACC:     JUPYTER_URL is $JUPYTER_URL"

INTERACTIVE_WEBHOOK_URL="${_webhook_base_url}"

# Wait a few seconds for jupyter to boot up and send webhook callback url for job ready notification.
# Notification is sent to _INTERACTIVE_WEBHOOK_URL, e.g. https://3dem.org/webhooks/interactive/
(
    sleep 5 &&
    curl -k --data "event_type=interactive_session_ready&address=${JUPYTER_URL}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &
) &

# Note: NotebookApp needs some work.
JUPYTER_SERVER_APP="ServerApp"
if [ ${JUPYTER_SERVER_APP} == "ServerApp" ]; then
    JUPYTER_BIN="jupyter-lab"
elif [ ${JUPYTER_SERVER_APP} == "NotebookApp" ]; then
    JUPYTER_BIN="jupyter-notebook"
fi

# create the tap jupyter config if needed
TAP_JUPYTER_CONFIG="${HOME}/.tap/jupyter_config.py"

cat <<- EOF > ${TAP_JUPYTER_CONFIG}
# Configuration file for TAP jupyter session
import ssl
c = get_config()
c.IPKernelApp.pylab = "inline"  # if you want plotting support always
c.${JUPYTER_SERVER_APP}.ip = "0.0.0.0"
c.${JUPYTER_SERVER_APP}.port = $LOCAL_PORT
c.${JUPYTER_SERVER_APP}.open_browser = False
c.${JUPYTER_SERVER_APP}.allow_origin = u"*"
c.${JUPYTER_SERVER_APP}.ssl_options = {"ssl_version": ssl.PROTOCOL_TLSv1_2}
c.IdentityProvider.token = "${TAP_TOKEN}"
EOF

JUPYTER_ARGS="--certfile=${TAP_CERTFILE} --config=${TAP_JUPYTER_CONFIG}"

echo "TACC: using jupyter command: ${JUPYTER_BIN} ${JUPYTER_ARGS}"

${JUPYTER_BIN} ${JUPYTER_ARGS}

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT} 2> /dev/null)"

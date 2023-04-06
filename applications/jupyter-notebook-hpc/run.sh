#!/bin/bash

echo "TACC: job ${SLURM_JOB_ID} execution at: $(date)"

# This file will be located in the directory mounted by the job.
SESSION_FILE="delete_me_to_end_session"
touch $SESSION_FILE

# RUN NOTEBOOK IN BACKGROUND  -->  CAN STAY THE SAME
LOCAL_IPY_PORT=8888

NODE_HOSTNAME_PREFIX=$(hostname -s)   # Short Host Name  -->  name of compute node: c###-###
NODE_HOSTNAME_DOMAIN=$(hostname -d)   # DNS Name  -->  stampede2.tacc.utexas.edu
NODE_HOSTNAME_LONG=$(hostname -f)     # Fully Qualified Domain Name  -->  c###-###.stampede2.tacc.utexas.edu

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

JUPYTER_SERVER_APP="ServerApp"

NB_SERVERDIR=${HOME}/.jupyter
IP_CONFIG=${NB_SERVERDIR}/jupyter_notebook_config.py

# make .jupyter dir for logs
mkdir -p ${NB_SERVERDIR}

mkdir -p ${HOME}/.tap # this should exist at this point, but just in case...
TAP_CERTFILE=${HOME}/.tap/.${SLURM_JOB_ID}

# bail if we cannot create a secure session
if [ ! -f ${TAP_CERTFILE} ]; then
    echo "TACC: ERROR - could not find TLS cert for secure session"
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi

# bail if we cannot create a token for the session
TAP_TOKEN=$(tap_get_token)
if [ -z "${TAP_TOKEN}" ]; then
    echo "TACC: ERROR - could not generate token for notebook"
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi
echo "TACC: using token ${TAP_TOKEN}"

# create the tap jupyter config if needed
TAP_JUPYTER_CONFIG="${HOME}/.tap/jupyter_config.py"
if [ ${JUPYTER_SERVER_APP} == "NotebookApp" ]; then
cat <<- EOF > ${TAP_JUPYTER_CONFIG}
# Configuration file for TAP jupyter-notebook
import ssl
c = get_config()
c.IPKernelApp.pylab = "inline"  # if you want plotting support always
c.NotebookApp.ip = "0.0.0.0"
c.NotebookApp.port = 5902
c.NotebookApp.open_browser = False
c.NotebookApp.allow_origin = u"*"
c.NotebookApp.ssl_options={"ssl_version": ssl.PROTOCOL_TLSv1_2}
c.NotebookApp.mathjax_url = u"https://cdn.mathjax.org/mathjax/latest/MathJax.js"
EOF
else
cat <<- EOF > ${TAP_JUPYTER_CONFIG}
# Configuration file for TAP jupyter-notebook
import ssl
c = get_config()
c.IPKernelApp.pylab = "inline"  # if you want plotting support always
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 5902
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = u"*"
c.ServerApp.ssl_options={"ssl_version": ssl.PROTOCOL_TLSv1_2}
c.NotebookApp.mathjax_url = u"https://cdn.mathjax.org/mathjax/latest/MathJax.js"
EOF
fi

# launch jupyter
JUPYTER_LOGFILE=${NB_SERVERDIR}/${NODE_HOSTNAME}.log
JUPYTER_BIN="/opt/conda/bin/jupyter-lab"
JUPYTER_ARGS="--certfile=$(cat ${TAP_CERTFILE}) --config=${TAP_JUPYTER_CONFIG} --${JUPYTER_SERVER_APP}.token=${TAP_TOKEN}"
echo "TACC: using jupyter command: ${JUPYTER_BIN} ${JUPYTER_ARGS}"
nohup ${JUPYTER_BIN} ${JUPYTER_ARGS} &> ${JUPYTER_LOGFILE} &

JUPYTER_PID=$!

LOGIN_PORT=$(tap_get_port)
echo "TACC: got login node jupyter port ${LOGIN_PORT}"

JUPYTER_URL="https://${NODE_HOSTNAME_DOMAIN}:${LOGIN_PORT}/?token=${TAP_TOKEN}"

# verify jupyter is up. if not, give one more try, then bail
if ! $(ps -fu ${USER} | grep ${JUPYTER_BIN} | grep -qv grep) ; then
    # sometimes jupyter has a bad day. give it another chance to be awesome.
    echo "TACC: first jupyter launch failed. Retrying..."
    nohup ${JUPYTER_BIN} ${JUPYTER_ARGS} &> ${JUPYTER_LOGFILE} &
fi
if ! $(ps -fu ${USER} | grep ${JUPYTER_BIN} | grep -qv grep) ; then
    # jupyter will not be working today. sadness.
    echo "TACC: ERROR - jupyter failed to launch"
    echo "TACC: ERROR - this is often due to an issue in your python or conda environment"
    echo "TACC: ERROR - jupyter logfile contents:"
    cat ${JUPYTER_LOGFILE}
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi

LOCAL_PORT=5902

# Port forwarding is set up for the four login nodes.
#
#   f: Requests ssh to go to background just before command execution.
#      Used if ssh asks for passwords but the user wants it in the background. Implies -n too.
#   g: Allows remote hosts to connect to local forwarded ports
#   N: Do not execute a remote command. Useful for just forwarding ports.
#   R: Connections to given TCP port/Unix socket on remote (server) host forwarded to local side.
#
# Create a reverse tunnel port from the compute node to the login nodes.
# Make one tunnel for each login so the user can just connect to stampede.tacc.utexas.edu.
for i in $(seq 4); do
    ssh -q -f -g -N -R ${LOGIN_PORT}:${NODE_HOSTNAME_PREFIX}:${LOCAL_PORT} login${i}
done
if [ $(ps -fu ${USER} | grep ssh | grep login | grep -vc grep) != 4 ]; then
    # jupyter will not be working today. sadness.
    echo "TACC: ERROR - ssh tunnels failed to launch"
    echo "TACC: ERROR - this is often due to an issue with your ssh keys"
    echo "TACC: ERROR - undo any recent mods in ${HOME}/.ssh"
    echo "TACC: ERROR - or submit a TACC consulting ticket with this error"
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi

# Webhook callback url for job ready notification.
# Notification is sent to _INTERACTIVE_WEBHOOK_URL, e.g. https://3dem.org/webhooks/interactive/
curl -k --data "event_type=interactive_session_ready&address=${JUPYTER_URL}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &

# Delete the session file to kill the job.
echo $NODE_HOSTNAME_LONG $IPYTHON_PID > $SESSION_FILE

# While the session file remains undeleted, keep Jupyter Notebook running.
while [ -f $SESSION_FILE ] ; do
    sleep 10
done

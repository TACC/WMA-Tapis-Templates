#!/bin/bash

echo "TACC: job ${SLURM_JOB_ID} execution at: $(date)"

# TAP Port
LOCAL_PORT=5902

mkdir -p $PWD/Jupyter
cd Jupyter

# This file will be located in the directory mounted by the job.
SESSION_FILE="delete_me_to_end_session"
touch $SESSION_FILE

# Make symlinks for work, home and scratch
mkdir -p $PWD/Work $PWD/Home $PWD/Scratch
if [ ! -L $PWD/Work ]; then
    ln -s $STOCKYARD $PWD/Work
fi
if [ ! -L $PWD/Home ]; then
    ln -s $HOME $PWD/Home
fi
if [ ! -L $PWD/Scratch ]; then
    ln -s $SCRATCH $PWD/Scratch
fi

TAP_FUNCTIONS="/share/doc/slurm/tap_functions"
if [ -f ${TAP_FUNCTIONS} ]; then
    . ${TAP_FUNCTIONS}
else
    echo "TACC:"
    echo "TACC: ERROR - could not find TAP functions file: ${TAP_FUNCTIONS}"
    echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
    echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
    echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
    exit 1
fi

# our node name
NODE_HOSTNAME_PREFIX=$(hostname -s)
NODE_HOSTNAME_DOMAIN=$(hostname -d)
NODE_HOSTNAME_LONG=$(hostname -f)

echo "TACC: running on node $NODE_HOSTNAME_PREFIX on $NODE_HOSTNAME_DOMAIN"

echo "TACC: unloading xalt"
module unload xalt

# Use jupyter-lab, exit if it's not found
JUPYTER_BIN=$(which jupyter-lab 2> /dev/null)
if [ -z "${JUPYTER_BIN}" ]; then
    echo "TACC: ERROR - could not find jupyter-lab install"
    echo "TACC: loaded modules below"
    module list
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
else
    JUPYTER_SERVER_APP="ServerApp"
fi
echo "TACC: using jupyter binary ${JUPYTER_BIN}"

NB_SERVERDIR=${HOME}/.jupyter
IP_CONFIG=${NB_SERVERDIR}/jupyter_notebook_config.py

# make .jupyter dir for logs
mkdir -p ${NB_SERVERDIR}
mkdir -p ${HOME}/.tap

TAP_LOCKFILE=${HOME}/.tap/.${SLURM_JOB_ID}.lock
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
cat <<- EOF > ${TAP_JUPYTER_CONFIG}
# Configuration file for TAP jupyter-lab
import ssl
c = get_config()
c.IPKernelApp.pylab = "inline"
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 5902
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = u"*"
c.ServerApp.ssl_options={"ssl_version": ssl.PROTOCOL_TLSv1_2}
c.ServerApp.mathjax_url = u"https://cdn.mathjax.org/mathjax/latest/MathJax.js"
EOF

# Set Jupyter Lab settings directory
export JUPYTERLAB_SETTINGS_DIR="${HOME}/.jupyterlab"

# launch jupyter-lab
JUPYTER_LOGFILE=${NB_SERVERDIR}/${NODE_HOSTNAME_PREFIX}.log
JUPYTER_ARGS="--certfile=$(cat ${TAP_CERTFILE}) --config=${TAP_JUPYTER_CONFIG} --${JUPYTER_SERVER_APP}.token=${TAP_TOKEN}"
echo "TACC: using jupyter command: ${JUPYTER_BIN} ${JUPYTER_ARGS}"
nohup ${JUPYTER_BIN} ${JUPYTER_ARGS} &> ${JUPYTER_LOGFILE} && rm ${TAP_LOCKFILE} &
JUPYTER_PID=$!
LOCAL_PORT=5902

LOGIN_PORT=$(tap_get_port)
echo "TACC: got login node jupyter port ${LOGIN_PORT}"

JUPYTER_URL="https://${NODE_HOSTNAME_DOMAIN}:${LOGIN_PORT}/?token=${TAP_TOKEN}"

# verify jupyter is up. if not, give one more try, then bail
if ! $(ps -fu ${USER} | grep ${JUPYTER_BIN} | grep -qv grep) ; then
    echo "TACC: first jupyter launch failed. Retrying..."
    nohup ${JUPYTER_BIN} ${JUPYTER_ARGS} &> ${JUPYTER_LOGFILE} && rm ${TAP_LOCKFILE} &
fi
if ! $(ps -fu ${USER} | grep ${JUPYTER_BIN} | grep -qv grep) ; then
    echo "TACC: ERROR - jupyter failed to launch"
    echo "TACC: ERROR - this is often due to an issue in your python or conda environment"
    echo "TACC: ERROR - jupyter logfile contents:"
    cat ${JUPYTER_LOGFILE}
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi

# create reverse tunnel port to login nodes.
NUM_LOGINS=4
for i in $(seq ${NUM_LOGINS}); do
    ssh -o StrictHostKeyChecking=no -q -f -g -N -R ${LOGIN_PORT}:${NODE_HOSTNAME_PREFIX}:${LOCAL_PORT} login${i}
done
if [ $(ps -fu ${USER} | grep ssh | grep login | grep -vc grep) != ${NUM_LOGINS} ]; then
    echo "TACC: ERROR - ssh tunnels failed to launch"
    exit 1
fi
echo "TACC: created reverse ports on Frontera logins"

echo "Sourcing tapisjob.env..."
source "${_tapisJobWorkingDir}/tapisjob.env"

echo "TACC: Your jupyter-lab server is now running at ${JUPYTER_URL}"
curl -k --data "event_type=interactive_session_ready&address=${JUPYTER_URL}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}"

echo $NODE_HOSTNAME_LONG $JUPYTER_PID > $SESSION_FILE

# Keep Jupyter session running while session file exists
while [ -f $SESSION_FILE ]; do
    sleep 10
done

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT})"
sleep 1

#!/bin/bash

echo "TACC: job ${SLURM_JOB_ID} execution at: $(date)"

# TAP Port
LOCAL_PORT=5902

mkdir -p $PWD/Jupyter
cd Jupyter

# This file will be located in the directory mounted by the job.
SESSION_FILE="delete_me_to_end_session"
touch $SESSION_FILE

# Make symlinks for work, home, and scratch
mkdir -p $PWD/Work $PWD/Home $PWD/Scratch;
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
    echo "TACC: ERROR - could not find TAP functions file: ${TAP_FUNCTIONS}"
    exit 1
fi

# our node name
NODE_HOSTNAME_PREFIX=$(hostname -s)   # Short Host Name
NODE_HOSTNAME_DOMAIN=$(hostname -d)   # DNS Name
NODE_HOSTNAME_LONG=$(hostname -f)     # Fully Qualified Domain Name

echo "TACC: running on node $NODE_HOSTNAME_PREFIX on $NODE_HOSTNAME_DOMAIN"

echo "TACC: unloading xalt"
module unload xalt

# Load modules if necessary (e.g., Python, MPI, Jupyter)
module load python3    # Example module load; user can customize
module load jupyter-lab

# Check if jupyter-lab is available
JUPYTER_BIN=$(which jupyter-lab 2> /dev/null)
if [ -z "${JUPYTER_BIN}" ]; then
    echo "TACC: ERROR - could not find jupyter-lab install. Ensure the module is loaded."
    module list  # Show loaded modules for debugging
    exit 1
fi
echo "TACC: using jupyter binary ${JUPYTER_BIN}"

# Create Jupyter server configuration
NB_SERVERDIR=${HOME}/.jupyter
IP_CONFIG=${NB_SERVERDIR}/jupyter_notebook_config.py
mkdir -p ${NB_SERVERDIR}

TAP_JUPYTER_CONFIG="${HOME}/.tap/jupyter_config.py"
cat <<- EOF > ${TAP_JUPYTER_CONFIG}
import ssl
c = get_config()
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 5902
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = u"*"
c.ServerApp.ssl_options={"ssl_version": ssl.PROTOCOL_TLSv1_2}
EOF

# Launch Jupyter Lab
JUPYTER_LOGFILE=${NB_SERVERDIR}/${NODE_HOSTNAME_PREFIX}.log
JUPYTER_ARGS="--certfile=$(cat ${TAP_CERTFILE}) --config=${TAP_JUPYTER_CONFIG} --ServerApp.token=$(tap_get_token)"
echo "TACC: using jupyter command: ${JUPYTER_BIN} ${JUPYTER_ARGS}"

nohup ${JUPYTER_BIN} ${JUPYTER_ARGS} &> ${JUPYTER_LOGFILE} &
JUPYTER_PID=$!
LOCAL_PORT=5902

LOGIN_PORT=$(tap_get_port)
echo "TACC: got login node jupyter port ${LOGIN_PORT}"
JUPYTER_URL="https://${NODE_HOSTNAME_DOMAIN}:${LOGIN_PORT}/?token=$(tap_get_token)"

# Check if Jupyter is running
if ! $(ps -fu ${USER} | grep ${JUPYTER_BIN} | grep -qv grep); then
    echo "TACC: ERROR - Jupyter failed to launch"
    cat ${JUPYTER_LOGFILE}
    exit 1
fi

# Create reverse tunnel for SSH
NUM_LOGINS=4
for i in $(seq ${NUM_LOGINS}); do
    ssh -o StrictHostKeyChecking=no -q -f -g -N -R ${LOGIN_PORT}:${NODE_HOSTNAME_PREFIX}:${LOCAL_PORT} login${i}
done

if [ $(ps -fu ${USER} | grep ssh | grep login | grep -vc grep) != ${NUM_LOGINS} ]; then
    echo "TACC: ERROR - ssh tunnels failed to launch"
    exit 1
fi
echo "TACC: created reverse ports on Frontera logins"

echo "TACC: Your Jupyter Lab server is running at ${JUPYTER_URL}"

# Notify TACC via webhook
curl -k --data "event_type=interactive_session_ready&address=${JUPYTER_URL}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &

# Keep Jupyter session running until the session file is deleted
while [ -f $SESSION_FILE ]; do
    sleep 10
done

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT})"

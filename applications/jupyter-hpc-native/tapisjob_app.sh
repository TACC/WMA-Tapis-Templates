#!/bin/bash

# Check if conda exists, if so deactivate any active conda env
if command -v conda > /dev/null 2>&1; then
    echo "TACC: deactivating conda environment"
    conda deactivate
fi

# use jupyter-lab if it exists, otherwise jupyter-notebook
JUPYTER_BIN=$(which jupyter-lab 2> /dev/null)
if [ -z "${JUPYTER_BIN}" ]; then
    JUPYTER_BIN=$(which jupyter-notebook 2> /dev/null)
    if [ -z "${JUPYTER_BIN}" ]; then
        echo "TACC: ERROR - could not find jupyter install"
        echo "TACC: loaded modules below"
        module list
        echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
        exit 1
    else
        JUPYTER_SERVER_APP="NotebookApp"
    fi
else
    JUPYTER_SERVER_VERSION=$(${JUPYTER_BIN} --version)
    if [ ${JUPYTER_SERVER_VERSION%%.*} -lt 3 ]; then
        JUPYTER_SERVER_APP="NotebookApp"
    else
        JUPYTER_SERVER_APP="ServerApp"
    fi
fi
echo "TACC: using jupyter binary ${JUPYTER_BIN}"

if $(echo ${JUPYTER_BIN} | grep -qve '^/opt') ; then
    echo "TACC: WARNING - non-system python detected. Script may not behave as expected"
fi

# Home Dir for Jupyter Notebook HPC Native for persistent storage between sessions
JUPYTER_HOME=$HOME/.jupyter-hpc-native
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

# Make symlink for MyData if it exists
if [ -d /data/designsafe/mydata/${_tapisJobOwner} ];
then
    ln -sf /data/designsafe/mydata/${_tapisJobOwner} $JUPYTER_HOME/MyData
fi

# Load custom kernelspec if defined
if [[ ! -z "${CUSTOM_KERNELSPEC}" ]]; then
    echo "TACC: using custom kernelspec ${CUSTOM_KERNELSPEC}"
    jupyter kernelspec install ${CUSTOM_KERNELSPEC} --user
fi

# create the tap jupyter config if needed
JUPYTER_CONFIG="${_tapisJobWorkingDir}/jupyter_config.py"

if [ ${JUPYTER_SERVER_APP} == "NotebookApp" ]; then
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
c.FileContentsManager.delete_to_trash = False
EOF
elif [ ${JUPYTER_SERVER_APP} == "ServerApp" ]; then
cat <<- EOF > ${JUPYTER_CONFIG}
# Configuration file for TAP jupyter session
import ssl
c = get_config()
c.IPKernelApp.pylab = "inline"  # if you want plotting support always
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = $LOCAL_PORT
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = u"*"
c.ServerApp.ssl_options = {"ssl_version": ssl.PROTOCOL_TLSv1_2,}
c.ServerApp.root_dir = "${JUPYTER_HOME}"
c.IdentityProvider.token = "${TAP_TOKEN}"
c.FileContentsManager.delete_to_trash = False
EOF
else
    echo "TACC: ERROR - could not determine jupyter server app"
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi

JUPYTER_URL="https://${NODE_HOSTNAME_DOMAIN}:${LOGIN_PORT}/?token=${TAP_TOKEN}"
echo "TACC:     JUPYTER_URL is $JUPYTER_URL"

# Wait a few seconds for jupyter to boot up and send webhook callback url for job ready notification.
# Notification is sent to _INTERACTIVE_WEBHOOK_URL, e.g. https://3dem.org/webhooks/interactive/
(
    sleep 5 &&
    curl -k --data "event_type=interactive_session_ready&address=${JUPYTER_URL}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &
) &

JUPYTER_ARGS="--certfile=${TAP_CERTFILE} --config=${JUPYTER_CONFIG}"

echo "TACC: using jupyter command: ${JUPYTER_BIN} ${JUPYTER_ARGS}"

${JUPYTER_BIN} ${JUPYTER_ARGS}

# clean up symlinks
rm $JUPYTER_HOME/Work $JUPYTER_HOME/Home $JUPYTER_HOME/Scratch $JUPYTER_HOME/MyData

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT} 2> /dev/null)"

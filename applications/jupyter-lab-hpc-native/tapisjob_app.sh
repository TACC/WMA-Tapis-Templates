#!/bin/bash

echo "TACC: job ${SLURM_JOB_ID} execution at: $(date)"

# TAP Port
LOCAL_PORT=5902

module load python3/3.9.2
module load jupyterlab

# Ensure TAP functions are available
TAP_FUNCTIONS="/share/doc/slurm/tap_functions"
if [ -f ${TAP_FUNCTIONS} ]; then
    . ${TAP_FUNCTIONS}
else
    echo "TACC: ERROR - could not find TAP functions file: ${TAP_FUNCTIONS}"
    exit 1
fi

# Set LOGIN_PORT using tap_get_port and verify it succeeds
LOGIN_PORT=$(tap_get_port)
if [ -z "${LOGIN_PORT}" ]; then
    echo "TACC: ERROR - could not retrieve login port."
    exit 1
fi

# Retrieve node domain for Jupyter URL
NODE_HOSTNAME_DOMAIN=$(hostname -d)

# Generate or retrieve TAP_TOKEN
TAP_CERTFILE="${HOME}/.tap/.${SLURM_JOB_ID}"
TAP_TOKEN=$(tap_get_token)
if [ -z "${TAP_TOKEN}" ]; then
    echo "TACC: ERROR - could not generate token for notebook"
    exit 1
fi
echo "TACC: using token ${TAP_TOKEN}"

# Define Jupyter Arguments
JUPYTER_ARGS="--port=${LOCAL_PORT} --certfile=$(cat ${TAP_CERTFILE}) --ServerApp.allow_remote_access=True --ServerApp.token=${TAP_TOKEN}"

# Set up Jupyter configuration
TAP_JUPYTER_CONFIG="${HOME}/.tap/jupyter_config.py"
mkdir -p $(dirname ${TAP_JUPYTER_CONFIG})
cat <<- EOF > ${TAP_JUPYTER_CONFIG}
import ssl
c = get_config()
c.IPKernelApp.pylab = "inline"
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = ${LOCAL_PORT}
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = u"*"
c.ServerApp.ssl_options={"ssl_version": ssl.PROTOCOL_TLSv1_2}
c.ServerApp.mathjax_url = u"https://cdn.mathjax.org/mathjax/latest/MathJax.js"
EOF

echo "Jupyter configuration file contents:"
cat ${TAP_JUPYTER_CONFIG}

# Create reverse SSH tunnel for each login node
NUM_LOGINS=4
for i in $(seq ${NUM_LOGINS}); do
    ssh -o StrictHostKeyChecking=no -q -f -g -N -R ${LOGIN_PORT}:127.0.0.1:${LOCAL_PORT} login${i}
done

if [ $(ps -fu ${USER} | grep ssh | grep login | grep -vc grep) != ${NUM_LOGINS} ]; then
    echo "TACC: ERROR - SSH tunnels failed to establish."
    exit 1
fi
echo "TACC: created reverse ports on system logins"

# Prepare the final URL for the JupyterLab server
JUPYTER_URL="https://${NODE_HOSTNAME_DOMAIN}:${LOGIN_PORT}/?token=${TAP_TOKEN}"

# Schedule webhook notification to allow Jupyter to start
(
    sleep 5 &&
    curl -k --data "event_type=interactive_session_ready&address=${JUPYTER_URL}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &
) &

module list  # Show loaded modules for debugging
# Use Jupyter binary, exit if not found
JUPYTER_BIN=$(which jupyter-lab 2> /dev/null)
if [ -z "${JUPYTER_BIN}" ]; then
    echo "TACC: ERROR - could not find jupyter-lab install"
    exit 1
fi
echo "TACC: using jupyter binary ${JUPYTER_BIN}"

# Launch JupyterLab in the foreground
${JUPYTER_BIN} ${JUPYTER_ARGS} 

# Release TAP port
tap_release_port ${LOGIN_PORT}

echo "TACC: Your JupyterLab server is now running at ${JUPYTER_URL}"
echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
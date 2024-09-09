#!/bin/bash

echo "TACC: job ${SLURM_JOB_ID} execution at: $(date)"

NODE_HOSTNAME_PREFIX=$(hostname -s)
export NODE_HOSTNAME_DOMAIN=$(hostname -d)

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

# get certfile from tap
mkdir -p ${HOME}/.tap
export TAP_CERTFILE=$(cat ${HOME}/.tap/.${SLURM_JOB_ID})
if [ ! -f ${TAP_CERTFILE} ]; then
    echo "TACC: ERROR - could not find TLS cert for secure session"
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi

# create session token
export TAP_TOKEN=$(tap_get_token)
if [ -z "${TAP_TOKEN}" ]; then
    echo "TACC: ERROR - could not generate token for app session"
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
fi
echo "TACC: using token ${TAP_TOKEN}"

# Local App Port
export LOCAL_PORT=8888

# TAP Login Port
export LOGIN_PORT=$(tap_get_port)
echo "TACC: got login node app port ${LOGIN_PORT}"

# Port forwarding is set up for up to four login nodes. Frontera and Stampede3 have 4, LS6 has 3.
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

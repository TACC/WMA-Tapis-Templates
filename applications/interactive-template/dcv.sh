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

# confirm DCV server is alive
DCV_SERVER_UP=`systemctl is-active dcvserver`
if [ $DCV_SERVER_UP == "active" ]; then
  SERVER_TYPE="DCV"
else
    echo "TACC:"
    echo "TACC: ERROR - could not confirm dcvserver active, systemctl returned '$DCV_SERVER_UP'"
    exit 1
fi

# if X0 socket exists, then DCV will use a higher X display number and ruin our day
# therefore, cowardly bail out and appeal to an admin to fix the problem
if [ -f /tmp/.X11-unix/X0 ]; then
    echo "TACC:"
    echo "TACC: ERROR - X0 socket already exists. DCV script will fail."
    echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
    echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
    echo "TACC:"
    exit 1
fi

# create an X startup file in /tmp
# source xinitrc-common to ensure xterms can be made
# then source the user's xstartup if it exists
XSTARTUP="/tmp/dcv-startup-$USER"
cat <<- EOF > $XSTARTUP
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
. /etc/X11/xinit/xinitrc-common
exec startxfce4
EOF

chmod a+rx $XSTARTUP

# create DCV session for this job
export DCV_HANDLE="${_tapisJobUUID}-session"
dcv create-session --owner ${_tapisJobOwner} --init=$XSTARTUP $DCV_HANDLE

# Wait a few seconds for dcvserver to spin up
sleep 5;

if ! `dcv list-sessions 2>&1 | grep -q ${DCV_HANDLE}`; then
    echo "TACC:"
    echo "TACC: WARNING - could not find a DCV session for this job"
    echo "TACC: WARNING - This could be because all DCV licenses are in use."
    echo "TACC: WARNING - Failing over to VNC session."
    echo "TACC: "
    echo "TACC: If you rarely receive a DCV session using this script, "
    echo "TACC: please submit a consulting ticket at the TACC user portal:"
    echo "TACC: https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
    echo "TACC: "

    exit 1
else
    export LOCAL_PORT=8443  # default DCV port
    export DISPLAY=":0"
fi

echo "TACC: local (compute node) ${SERVER_TYPE} port is $LOCAL_PORT"

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
  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -q -f -g -N -R ${LOGIN_PORT}:${NODE_HOSTNAME_PREFIX}:${LOCAL_PORT} login${i}
done

export INTERACTIVE_SESSION_ADDRESS="https://${NODE_HOSTNAME_DOMAIN}:${LOGIN_PORT}"
echo "TACC: Created reverse ports on ${NODE_HOSTNAME_DOMAIN} logins"
echo "TACC: Interactive Session URL is ${INTERACTIVE_SESSION_ADDRESS}"

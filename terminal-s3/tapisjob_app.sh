set -x

echo "TACC: job $SLURM_JOB_ID execution at: `date`"

# our node name
NODE_HOSTNAME=`hostname -s`

# HPC system target. Used as DCV host
HPC_HOST=`hostname -d`

echo "TACC: running on node $NODE_HOSTNAME on $HPC_HOST"

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


LOGIN_PORT=$(tap_get_port)
echo "TACC: got login node ${SERVER_TYPE} port $LOGIN_PORT"

# create reverse tunnel port to login nodes.  Make one tunnel for each login so the user can just connect to $HPC_HOST
LOCAL_PORT=7681
for i in `seq 4`; do
  ssh -o StrictHostKeyChecking=no -q -f -g -N -R $LOGIN_PORT:$NODE_HOSTNAME:$LOCAL_PORT login$i
done

echo "TACC: Created reverse ports on $HPC_HOST logins"
echo "TACC:          https://$HPC_HOST:$LOGIN_PORT"


TAP_CERTFILE=${HOME}/.tap/.${SLURM_JOB_ID}
# bail if we cannot create a secure session
if [ ! -f ${TAP_CERTFILE} ]; then
  echo "TACC: ERROR - could not find TLS cert for secure session"
  echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
  exit 1
fi

# Split certfile into key and cert components to make ttyd happy
# Produces 2 files, cert ${TAP_CERTFILE}
csplit  -f ${TAP_CERTFILE} $(cat ${TAP_CERTFILE}) /-----BEGIN\ PRIVATE\ KEY-----/
CERT_PATH=${TAP_CERTFILE}00
KEY_PATH=${TAP_CERTFILE}01


TERMINAL_USER=$(whoami)
SESSION_KEY=$(openssl rand -hex 12)


INTERACTIVE_SESSION_ADDRESS="https://${TERMINAL_USER}:${SESSION_KEY}@${HPC_HOST}:${LOGIN_PORT}"
echo ${INTERACTIVE_SESSION_ADDRESS}


# Webhook callback url for job ready notification.
# Notification is sent to _INTERACTIVE_WEBHOOK_URL, e.g. https://3dem.org/webhooks/interactive/
curl -k --data "event_type=interactive_session_ready&address=${INTERACTIVE_SESSION_ADDRESS}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &

# Run an xterm and launch $_XTERM_CMD for the user; execution will hold here.
# -p sets ttyd port to LOCAL_PORT
# -W makes terminal writable from client
# -o causes ttyd to exit when the process exits (needed so that we can perform cleanup)
chmod +x ./ttyd.x86_64
./ttyd.x86_64 -p ${LOCAL_PORT} -W -w ${HOME} -o --ssl --ssl-cert=${CERT_PATH} --ssl-key=${KEY_PATH} -c ${TERMINAL_USER}:${SESSION_KEY} bash

echo "TACC: closing ttyd session"

# wait a brief moment so vncserver can clean up after itself
sleep 1

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT} 2> /dev/null)"

# remove X11 sockets so DCV will find :0 next time

echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"

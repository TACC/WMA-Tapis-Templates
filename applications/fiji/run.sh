#!/bin/bash
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

# confirm DCV server is alive
DCV_SERVER_UP=`systemctl is-active dcvserver`
if [ $DCV_SERVER_UP == "active" ]; then
  SERVER_TYPE="DCV"
else
  echo "TACC:"
  echo "TACC: ERROR - could not confirm dcvserver active, systemctl returned '$DCV_SERVER_UP'"
  SERVER_TYPE="VNC"
fi

# if X0 socket exists, then DCV will use a higher X display number and ruin our day
# therefore, cowardly bail out and appeal to an admin to fix the problem
if [ -f /tmp/.X11-unix/X0 ]; then
  echo "TACC:"
  echo "TACC: ERROR - X0 socket already exists. DCV script will fail."
  echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
  echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC:"
  SERVER_TYPE="VNC"
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

### NOTE: an ampersand after "exec startxfce4" can break DCV.
### This ampersand was found in sal's $HOME/.vnc/xstartup for some reason, so disable for all just in case
# if [ -x $HOME/.vnc/xstartup ]; then
#   cat $HOME/.vnc/xstartup >> $XSTARTUP
# else
#   echo "exec startxfce4" >> $XSTARTUP
# fi
chmod a+rx $XSTARTUP

if [ "x${SERVER_TYPE}" == "xDCV" ]; then
  # create DCV session for this job
  DCV_HANDLE="${_tapisJobUUID}-session"
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

    SERVER_TYPE="VNC"
  else
    LOCAL_PORT=8443  # default DCV port
    DISPLAY=":0"
  fi
fi

if [ "x${SERVER_TYPE}" == "xVNC" ]; then

  VNCSERVER_BIN=`which vncserver`
  echo "TACC: using default VNC server $VNCSERVER_BIN"

  TAPIS_PASS=`which vncpasswd`
  echo -n ${_tapisJobUUID} > tapis_uuid
  ${TAPIS_PASS} -f < tapis_uuid > vncp.txt

  # launch VNC session
  VNC_DISPLAY=`$VNCSERVER_BIN -rfbauth vncp.txt $@ 2>&1 | grep desktop | awk -F: '{print $3}'`
  echo "TACC: got VNC display :$VNC_DISPLAY"

  if [ x$VNC_DISPLAY == "x" ]; then
    echo "TACC: "
    echo "TACC: ERROR - could not find display created by vncserver: $VNCSERVER"
    echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal:"
    echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
    echo "TACC: "
    echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
    exit 1
  fi

  VNC_PORT=`expr 5900 + $VNC_DISPLAY`
  LOCAL_PORT=5902
  DISPLAY=":${VNC_DISPLAY}"
fi

echo "TACC: local (compute node) ${SERVER_TYPE} port is $LOCAL_PORT"

LOGIN_PORT=$(tap_get_port)
echo "TACC: got login node ${SERVER_TYPE} port $LOGIN_PORT"

# Wait a few seconds for good measure for the job status to update
sleep 3;

# create reverse tunnel port to login nodes.  Make one tunnel for each login so the user can just connect to $HPC_HOST
for i in `seq 4`; do
  ssh -o StrictHostKeyChecking=no -f -g -N -R $LOGIN_PORT:$NODE_HOSTNAME:$LOCAL_PORT login$i
done

echo "TACC: Created reverse ports on $HPC_HOST logins"
echo "TACC:          https://$HPC_HOST:$LOGIN_PORT"

if [ "x${SERVER_TYPE}" == "xDCV" ]; then
  INTERACTIVE_SESSION_ADDRESS="https://${HPC_HOST}:${LOGIN_PORT}"
elif [ "x${SERVER_TYPE}" == "xVNC" ]; then

  TAP_CERTFILE=${HOME}/.tap/.${SLURM_JOB_ID}
  # bail if we cannot create a secure session
  if [ ! -f ${TAP_CERTFILE} ]; then
    echo "TACC: ERROR - could not find TLS cert for secure session"
    echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
    exit 1
  fi

  # fire up websockify to turn the vnc session connection into a websocket connection
  WEBSOCKIFY_CMD="/home1/00832/envision/websockify/run"
  WEBSOCKIFY_PORT=5902
  WEBSOCKIFY_ARGS="--cert=$(cat ${TAP_CERTFILE}) --ssl-only --ssl-version=tlsv1_2 -D ${WEBSOCKIFY_PORT} localhost:${VNC_PORT}"
  ${WEBSOCKIFY_CMD} ${WEBSOCKIFY_ARGS} # websockify will daemonize

  INTERACTIVE_SESSION_ADDRESS="https://tap.tacc.utexas.edu/noVNC/?host=${HPC_HOST}&port=${LOGIN_PORT}&password=${_tapisJobUUID}&autoconnect=true&encrypt=true&resize=scale"
else
  # we should never get this message since we just checked this at LOCAL_PORT
  echo "TACC: "
  echo "TACC: ERROR - unknown server type '${SERVER_TYPE}'"
  echo "TACC: Please submit a consulting ticket at the TACC user portal"
  echo "TACC: https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC:"
  echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
  exit 1
fi

echo "INTERACTIVE_SESSION_ADDRESS is $INTERACTIVE_SESSION_ADDRESS"

# Webhook callback url for job ready notification.
# Notification is sent to _INTERACTIVE_WEBHOOK_URL, e.g. https://3dem.org/webhooks/interactive/
curl -k --data "event_type=interactive_session_ready&address=${INTERACTIVE_SESSION_ADDRESS}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &

# Set values for ImageJ config file based on job parameters
TOTAL_PROCS=$(($_tapisCoresPerNode * $_tapisNodes))
MEM_CMD="$_tapisMemoryMB * $_tapisNodes * .75 / 1"
TOTAL_MEM="$(bc <<< $MEM_CMD)"

cat > /tmp/ImageJ.cfg <<EOF
.

-XX:ActiveProcessorCount=${TOTAL_PROCS} -Xmx${TOTAL_MEM}m -cp ij.jar ij.ImageJ
EOF

# Run an xterm and launch $_XTERM_CMD for the user; execution will hold here.
export DISPLAY
xterm -r -ls -geometry 80x24+10+10 -title '*** Exit this window to kill your interactive session ***' -e "${_XTERM_CMD}"

# Job is done!

echo "TACC: closing ${SERVER_TYPE} session"
if [ "x${SERVER_TYPE}" == "xDCV" ]; then
  dcv close-session ${DCV_HANDLE}
elif [ "x${SERVER_TYPE}" == "xVNC" ]; then
  vncserver -kill ${DISPLAY}
else
  # we should never get this message since we just checked this at LOCAL_PORT
  echo "TACC: "
  echo "TACC: ERROR - unknown server type '${SERVER_TYPE}'"
  echo "TACC: Please submit a consulting ticket at the TACC user portal"
  echo "TACC: https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC:"
  echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
  exit 1
fi

# wait a brief moment so vncserver can clean up after itself
sleep 1

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT} 2> /dev/null)"

# remove X11 sockets so DCV will find :0 next time
find /tmp/.X11-unix -user $USER -exec rm -f '{}' \;

echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
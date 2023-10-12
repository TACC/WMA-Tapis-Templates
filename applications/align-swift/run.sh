#!/bin/bash
set -x

echo "TACC: job $SLURM_JOB_ID execution at: `date`"

# our node name
NODE_HOSTNAME=`hostname -s`

# HPC system target. Used as DCV host
HPC_HOST=`hostname -d`

echo "TACC: running on node $NODE_HOSTNAME on $HPC_HOST"

# Make symlinks for work, home and scratch
mkdir -p $PWD/AlignEM
cd AlignEM
mkdir -p $PWD/Work $PWD/Home $PWD/Scratch;
if [ ! -L $PWD/Work ];
then
    ln -s $STOCKYARD $PWD/Work
fi

if [ ! -L $PWD/Home ];
then
    ln -s $HOME $PWD/Home
fi

if [ ! -L $PWD/Scratch ];
then
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

# TODO: Should this move after setup of AlignSwiftEM
# Webhook callback url for job ready notification.
# Notification is sent to _INTERACTIVE_WEBHOOK_URL, e.g. https://3dem.org/webhooks/interactive/
curl -k --data "event_type=interactive_session_ready&address=${INTERACTIVE_SESSION_ADDRESS}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &


# AlignEM Swift specific code.
# silence xalt errors
module unload xalt
echo "Setting things up..."
echo "Changing directory to WORK directory..."
cd $WORK

echo "Checking if miniconda3 is installed..."
if [ ! -d "$WORK/miniconda3" ]; then
  echo "Miniconda not found in $WORK..."
  echo "Installing..."
  mkdir -p $WORK/miniconda3
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $WORK/miniconda3/miniconda.sh
  bash $WORK/miniconda3/miniconda.sh -b -u -p $WORK/miniconda3
  rm -rf $WORK/miniconda3/miniconda.sh

  echo "Ensuring conda base environment is OFF..."
  conda config --set auto_activate_base false
fi

echo "Initializing conda..."
$WORK/miniconda3/bin/conda init bash

echo "Sourcing .bashrc..."
source ~/.bashrc

echo "Updating conda..."
conda update conda -y

#echo "Checking if AlignEM-SWiFT exists in $WORK..."
if [ ! -d "$WORK/swift-ir" ]; then
  echo "AlignEM-SWiFT not found in $WORK..."
  git clone https://github.com/mcellteam/swift-ir.git
fi

echo "Changing directory to swift-ir..."
cd $WORK/swift-ir

echo "Checking out 0.5.441 branch..."
git checkout development_ng
git pull

echo "Purging modules..."
module purge

echo "cd'ing to swift-ir and pulling changes..."
cd $WORK/swift-ir
git stash
git pull --ff-only

echo "Activating conda environment..."
conda activate /work/08507/joely/ls6/miniconda3/envs/alignTACC1024

echo "Unsetting MESA_DEBUG..."
unset MESA_DEBUG
echo "Unsetting QT_API..."
unset QT_API
echo "Setting QT API environment flag QT_API=pyqt5..."
export QT_API=pyqt5

export BLOSC_NTHREADS=1

echo "Loading swr and fftw3 modules..."
ml intel/19.1.1 swr/21.2.5 impi/19.0.9 fftw3/3.3.10
#ml intel/19.1.1 swr/21.2.5 impi/19.0.9 fftw3/3.3.10

swr glxinfo -B

node=$(hostname --alias)
echo "Node     : $node"

echo ""
echo "You should now be in the environment 'alignTACC1024'."
echo "To relaunch AlignEM-SWiFT on Lonestar6 @ TACC:"
echo ""
echo "    cd $WORK/swift-ir"
echo "    python3 alignEM.py"
echo ""
echo "Launching AlignEM-SWiFT..."


# run an xterm for the user; execution will hold here
mkdir -p $HOME/.tap
TAP_LOCKFILE=${HOME}/.tap/${SLURM_JOB_ID}.lock
sleep 1
DISPLAY=:0 xterm -fg white -bg red3 +sb -geometry 55x2+0+0 -T 'END SESSION HERE' -e "echo 'TACC: Press <enter> in this window to end your session' && read && rm ${TAP_LOCKFILE}" &
sleep 1
DISPLAY=:0 xterm -ls -geometry 80x24+100+50 -e 'python3 alignEM.py' &


# Job is done!
echo $(date) > ${TAP_LOCKFILE}
while [ -f ${TAP_LOCKFILE} ]; do
    sleep 1
done

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
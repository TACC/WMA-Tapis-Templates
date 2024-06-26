handle_error() {
  local EXITCODE=$1
  echo "STKO job exited with an error status. $EXITCODE" >&2
  echo "$EXITCODE" > "${_tapisExecSystemOutputDir}/tapisjob.exitcode"
  exit $EXITCODE
}

set -x

echo "TACC: job $_tapisJobUUID execution at: `date`"

ln -sfn "/corral/main/projects/NHERI" "$HOME/NHERI"

# confirm DCV server is alive
DCV_SERVER_UP=`systemctl is-active dcvserver`
if [ $DCV_SERVER_UP != "active" ]; then
  echo "TACC:"
  echo "TACC: ERROR - could not confirm dcvserver active, systemctl returned '$DCV_SERVER_UP'"
  echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
  echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC:"
  echo "TACC: job $_tapisJobUUID execution finished at: `date`"
  handle_error 1
fi

# Invoke DCV on session startup
DCV_STARTUP="/tmp/dcv-startup-${_tapisJobUUID}"
DCV_HANDLE="${_tapisJobUUID}-session"
cat <<- EOF > $DCV_STARTUP
#!/bin/sh
pip install PySide2 matplotlib scipy
/snap/stko/current/STKORun.sh || exit 1

dcv close-session ${DCV_HANDLE}
EOF
chmod a+rx $DCV_STARTUP

# create DCV session for this job
dcv create-session --owner ${_tapisJobOwner} --init ${DCV_STARTUP} $DCV_HANDLE
if ! `dcv list-sessions | grep -q ${_tapisJobUUID}`; then
  echo "TACC:"
  echo "TACC: WARNING - could not find a DCV session for this job"
  echo "TACC: WARNING - This could be because all DCV licenses are in use."
  echo "TACC: WARNING - Failing over to VNC session."
  echo "TACC: "
  echo "TACC: If you rarely receive a DCV session using this script, "
  echo "TACC: please submit a consulting ticket at the TACC user portal:"
  echo "TACC: https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC: "
  echo "TACC: job $_tapisJobUUID execution finished at: `date`"
  handle_error 1
fi

LOCAL_PORT="8443"  # default DCV port

# Webhook callback url for job ready notification
# (notifications sent to _INTERACTIVE_WEBHOOK_URL (i.e. https://3dem.org/webhooks/interactive/))`

#connect to DCV session on VM
curl -k --data "event_type=interactive_session_ready&address=https://ds-stko-dev.tacc.utexas.edu:${LOCAL_PORT}/#${DCV_HANDLE}&owner=${_tapisJobOwner}&job_uuid=${_tapisJobUUID}" "${_INTERACTIVE_WEBHOOK_URL}" &

echo "TACC: Your DCV session is now running!"
echo "TACC: Connect to your session at: https://ds-stko-dev.tacc.utexas.edu:${LOCAL_PORT}/#${DCV_HANDLE}"

# Keep script running while dcv session is active
while dcv list-sessions | grep -q ${DCV_HANDLE}; do
  sleep 5;
done
echo "TACC: DCV session has been closed."

# remove X11 sockets
find /tmp/.X11-unix -user $USER -exec rm -f '{}' \;

echo "TACC: job $_tapisJobUUID execution finished at: `date`"

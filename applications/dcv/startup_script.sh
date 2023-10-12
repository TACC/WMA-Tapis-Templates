#!/bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

exec &>> /var/log/startup_script.log

set -xe
# ps -ef > /tmp/ps.ef

# Check if we have a well configured xorg.conf and create one in case
if [ ! -f /etc/X11/xorg.conf -o "`grep BusID /etc/X11/xorg.conf | grep PCI`" == "" ] ; then
    sleep 5
    echo "Updating the X server configuration ... "
    sudo systemctl isolate multi-user.target
    sleep 1
    # dcvgladmin disable
    nvidia-xconfig --preserve-busid --enable-all-gpus --connected-monitor=DFP-0,DFP-1,DFP-2,DFP-3
    # add  Option         "HardDPMS" "false"
    sed '/^Section "Device"/a \ \ \ \ Option         "HardDPMS" "false"'  /etc/X11/xorg.conf > /tmp/xorg.conf
    mv /tmp/xorg.conf /etc/X11/xorg.conf
    # sed '/^Section "Device"/a \ \ \ \ Option         "UseDisplayDevice" "none"'  /etc/X11/xorg.conf > /tmp/xorg.conf
    # mv /tmp/xorg.conf /etc/X11/xorg.conf
    sleep 1
    # dcvgladmin enable
    sudo systemctl isolate graphical.target
    sleep 1
    sudo systemctl enable dcvserver 2>&1
    sudo systemctl restart dcvserver
fi


firewall-cmd --zone=public --permanent --add-port=22/tcp  # ssh standard TCP port 
firewall-cmd --zone=public --permanent --add-port=8443/tcp  # DCV standard TCP port 
firewall-cmd --zone=public --permanent --add-port=8443/udp  # in addition for UDP/QUIC
firewall-cmd --reload

# set -ex

# AWS="1"

if [ "$AWS" == "1" ] ; then
    /usr/local/bin/send_dcvsessionready_notification.sh >/dev/null 2>&1 &
    export AWS_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
    export AWS_DEFAULT_REGION=${AWS_REGION}
    _username="$(aws secretsmanager get-secret-value --secret-id \
                   dcv-cred-user --query SecretString  --output text)"
    _passwd="$(aws secretsmanager get-secret-value --secret-id \
                   dcv-cred-passwd --query SecretString  --output text)"
else
    _username="user"
    _passwd="dcv"
fi
adduser "${_username}" -G wheel 
echo "${_username}:${_passwd}" |chpasswd
/usr/bin/dcv create-session --type=virtual --storage-root=%home% --owner "${_username}" --user "${_username}" "${_username}session"

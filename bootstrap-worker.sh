#!/bin/bash

set -e

TARGET_HOST=$1
if [ "x$TARGET_HOST" = "x" ]; then
    echo "Please specify the host you are trying to bootstrap"
    exit 1 
fi

ssh $TARGET_HOST "sudo yum install -y salt-minion && \
                  sudo mkdir -p /etc/salt/minion.d && \
                  hostname -f | sudo tee /etc/salt/minion_id && \
                  echo 'master: $HOSTNAME' | sudo tee /etc/salt/minion.d/master.conf && \
                  sudo salt-call state.highstate >/dev/null 2>&1 || true"


# get the minion id so we can authorized the node
MINION_ID=`ssh $TARGET_HOST "cat /etc/salt/minion_id"`
if [ -e /etc/salt/pki/master/minions_pre/$MINION_ID ]; then
    mv /etc/salt/pki/master/minions_pre/$MINION_ID /etc/salt/pki/master/minions/$MINION_ID
fi

ssh $TARGET_HOST "sudo salt-call state.highstate && \
                  sudo systemctl restart salt-minion"


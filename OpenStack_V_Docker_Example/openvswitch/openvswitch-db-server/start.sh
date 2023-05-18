#!/bin/bash

set -x

source /etc/environment_config.conf

function start_service() {
    mkdir -p /var/log/cpcloud/openvswitch
    chmod -R 777 /var/log/cpcloud
    chown -R .cpcloud /var/log/cpcloud/openvswitch
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
    modprobe openvswitch
   /bin/bash /usr/local/bin/start-ovsdb-server.sh 127.0.0.1
}

function main() {
    start_service
}

main
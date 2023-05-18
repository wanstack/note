#!/bin/bash

set -x
source /etc/environment_conf.conf

function start_service() {
    mkdir -p /var/log/cpcloud/openvswitch
    chmod -R 777 /var/log/cpcloud
    chown -R .cpcloud /var/log/cpcloud/openvswitch
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
    modprobe openvswitch
    LOG_FILE=/var/log/cpcloud/openvswitch/ovs-vswitchd.log
    /usr/sbin/ovs-vswitchd unix:/run/openvswitch/db.sock -vconsole:emer -vsyslog:err -vfile:info --mlockall --log-file=$LOG_FILE --pidfile

}

function main() {
    start_service
}

main
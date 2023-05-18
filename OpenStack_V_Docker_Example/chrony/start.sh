#!/bin/bash

set -x

function change_config() {
    ENVIRONMENT_CONFIG=/etc/environment_config.conf
    source $ENVIRONMENT_CONFIG
    
    chmod -R 777 /var/log/cpcloud
    sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/chrony/chrony.conf
    sed -ri "s@ALLOW_CHRONY_NETWORKS@$ALLOW_CHRONY_NETWORKS@g" /etc/chrony/chrony.conf
    sed -ri "s/LOCAL_IP/$LOCAL_IP/g" /etc/chrony/chrony.conf

    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf

}

function start_service() {

    /usr/sbin/chronyd -d -f /etc/chrony/chrony.conf

}

function main() {
    change_config
    start_service
}

main






#!/bin/bash

set -x

function start_service() {
    ENVIRONMENT_CONFIG=/etc/environment_config.conf
    source $ENVIRONMENT_CONFIG

    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf

    /usr/bin/memcached -v -l $LOCAL_IP -p 11211 -c 5000 -U 0 -m 256
}

function main() {
    start_service
}

main
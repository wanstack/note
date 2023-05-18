#!/bin/bash

set -x

ENVIRONMENT_CONFIG=/etc/environment_config.conf
source $ENVIRONMENT_CONFIG

function change_config() {

    test -d /var/log/cpcloud/libvirt/ || mkdir -p /var/log/cpcloud/libvirt/
    chmod -R 777 /var/log/cpcloud/libvirt/
    chown -R nova.nova /var/log/cpcloud/libvirt/

    sed -ri "s@LOCAL_IP@$LOCAL_IP@g" /etc/libvirt/libvirtd.conf

    echo admin | saslpasswd2 -a libvirt admin
}


function start_service() {
    /usr/sbin/libvirtd --listen
}

function main() {
    change_config
    start_service
}

main
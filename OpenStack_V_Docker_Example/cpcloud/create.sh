#!/bin/bash

set -x

source /etc/environment_config.conf



function add_vyos() {
    if [[ ${CURRENT_NODE_TYPE} = "controller" ]];then
        source /etc/admin.openrc
        mkdir -p "/tmp/Core Router"
        tar xvf /tmp/Core_Router.tar.gz -C /tmp/Core\ Router
        if [ $(openstack volume snapshot list |grep -ic 'Core Router') -lt 1 ] ;then
            bash /opt/cpcloud_project/cpcloud/apps/device/import_snapshots.sh "/tmp/Core Router"
        fi
        rm -rf "/tmp/Core Router"

    fi
}

function main() {
    add_vyos
}

main
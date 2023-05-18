#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf

function install() {
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
            install_modules=(nova-api nova-conductor nova-scheduler nova-novncproxy nova-serialproxy nova-libvirt)
        else
            install_modules=(nova-libvirt nova-compute)
        fi
    else
        install_modules=(nova-api nova-conductor nova-scheduler nova-novncproxy nova-serialproxy nova-libvirt nova-compute)
    fi
    for module in "${install_modules[@]}"; do
        echo "Installing $WORKDIR/$module"
        test -f $WORKDIR/$module/install.log && rm -rf $WORKDIR/$module/install.log
        bash $WORKDIR/$module/install.sh >> $WORKDIR/$module/install.log 2>&1
    done
}

function main() {
    install
}

main
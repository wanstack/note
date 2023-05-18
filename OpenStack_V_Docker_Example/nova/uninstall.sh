#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf


function uninstall() {
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
            uninstall_modules=(nova-api nova-conductor nova-scheduler nova-novncproxy nova-serialproxy)
        else
            uninstall_modules=(nova-compute nova-libvirt)
        fi
    else
        uninstall_modules=(nova-api nova-conductor nova-scheduler nova-novncproxy nova-serialproxy nova-compute nova-libvirt)
    fi
    for module in "${uninstall_modules[@]}"; do
        echo "Uninstalling $WORKDIR/$module"
        test -f $WORKDIR/$module/uninstall.log && rm -rf $WORKDIR/$module/uninstall.log
        bash $WORKDIR/$module/uninstall.sh >> $WORKDIR/$module/uninstall.log 2>&1
    done
}

function main() {
    uninstall
}

main
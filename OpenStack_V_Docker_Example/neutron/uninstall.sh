#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf


function uninstall() {
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
            uninstall_modules=(neutron-server neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent neutron-openvswitch-agent dnsmasq)
        else
            uninstall_modules=(neutron-openvswitch-agent)
        fi
    else
        uninstall_modules=(neutron-server neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent neutron-openvswitch-agent dnsmasq)
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
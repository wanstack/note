#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf
TAG=$1

function build() {
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
            unbuild_modules=(neutron-server neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent neutron-openvswitch-agent dnsmasq)
        else
            unbuild_modules=(neutron-openvswitch-agent)
        fi
    else
        unbuild_modules=(neutron-server neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent neutron-openvswitch-agent dnsmasq)
    fi
    for module in "${unbuild_modules[@]}"; do
        echo "Unbuilding $WORKDIR/$module"
        test -f $WORKDIR/$module/unbuild.log && rm -rf $WORKDIR/$module/unbuild.log
        bash $WORKDIR/$module/unbuild.sh $TAG >> $WORKDIR/$module/unbuild.log 2>&1
    done
}

function main() {
    build
}

main
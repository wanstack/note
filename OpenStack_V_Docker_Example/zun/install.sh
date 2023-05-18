#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf


function install() {
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
            install_modules=(kuryr zun-api zun-wsproxy)
        else
            install_modules=(kuryr zun-cni-daemon zun-compute)
        fi
    else
        install_modules=(kuryr zun-api zun-wsproxy zun-cni-daemon zun-compute)
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
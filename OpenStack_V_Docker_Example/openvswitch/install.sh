#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf


function install() {
    install_modules=(openvswitch-db-server openvswitch-vswitchd)

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
#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf
TAG=$1

function build() {
    unbuild_modules=(openvswitch-db-server openvswitch-vswitchd)

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
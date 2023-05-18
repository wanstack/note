#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf
TAG=$1

function build() {
#    if [[ ${ALL_IN_ONE} != True ]]; then
#        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
#            build_modules=(nova-api nova-conductor nova-scheduler nova-novncproxy nova-serialproxy)
#        else
#            build_modules=(nova-compute nova-libvirt)
#        fi
#    else
#        build_modules=(nova-api nova-conductor nova-scheduler nova-novncproxy nova-serialproxy nova-compute nova-libvirt)
#    fi
    build_modules=(nova-api nova-conductor nova-scheduler nova-novncproxy nova-serialproxy nova-compute nova-libvirt)
    for module in "${build_modules[@]}"; do
        echo "Building $WORKDIR/$module"
        test -f $WORKDIR/$module/build.log && rm -rf $WORKDIR/$module/build.log
        bash $WORKDIR/$module/build.sh $TAG >> $WORKDIR/$module/build.log 2>&1
    done

}

function main() {
    build
}

main
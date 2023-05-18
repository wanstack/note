#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
ENVIRONMENT_CONFIG=$WORKDIR/environment_config.conf
source $ENVIRONMENT_CONFIG

TAG=$1

function unbuild() {
     unbuild_modules=(cpcloud svcloud cron vsftpd nginx tools zun cinder neutron horizon openvswitch placement nova glance \
     nfs etcd keystone rabbitmq mariadb memcached etcd chrony yum pypi)
    for module in "${unbuild_modules[@]}"; do
        echo "Unbuilding $WORKDIR/$module"
        test -f $WORKDIR/$module/unbuild.log && rm -rf $WORKDIR/$module/unbuild.log
        bash $WORKDIR/$module/unbuild.sh $TAG >> $WORKDIR/$module/unbuild.log 2>&1
    done
}

function main() {
    unbuild
}

main
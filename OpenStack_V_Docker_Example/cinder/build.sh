#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf
TAG=$1

function build() {
    build_modules=(cinder-api cinder-scheduler cinder-volume)
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
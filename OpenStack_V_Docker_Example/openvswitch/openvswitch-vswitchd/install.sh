#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

function check_status() {
    count=1
    while ((count < 100)); do
        count_service=$(ps -ef | grep ovs-vswitchd | grep -v grep | wc -l)
        if [[ $count_service -ge 1 ]];then
            sleep 30
            echo "openvswitch-vswitchd is started!"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "openvswitch-vswitchd install failed, exit"
        exit 1
    fi
}

function load_images() {
    image_name=$1
    if docker images | grep $image_name; then
        TAG=$(docker images | grep $image_name | awk '{print $2}')
        docker rmi -f $image_name:$TAG
        docker load -i $WORKDIR/$image_name.tar
    else
        docker load -i $WORKDIR/$image_name.tar
    fi
}


function main() {
    load_images openvswitch-vswitchd

    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
    test -L /etc/cpcloud/openvswitch && rm -rf /etc/cpcloud/openvswitch
    ln -sv /var/lib/docker/volumes/openvswitch-vswitchd/_data /etc/cpcloud/openvswitch
}

main
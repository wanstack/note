#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

source /etc/environment_config.conf

function check_status() {
    count=1
    while ((count < 100)); do
        docker exec etcd etcdctl ls > /dev/null
        if [[ $? -eq 0 ]];then
            echo "etcd is started!"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "etcd install failed, exit"
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
    load_images etcd

    test -d /etc/cpcloud/etcd && rm -rf /etc/cpcloud/etcd
    mkdir -p /etc/cpcloud/etcd
    \cp -rp $WORKDIR/etcd.conf /etc/cpcloud/etcd
    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
}

main

# docker run -ti --name etcd --hostname etcd --network host -v /etc/environment_config.conf:/etc/environment_config.conf \
# etcd:latest bash
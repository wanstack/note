#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

source /etc/environment_config.conf
function check_status() {
    count=1
    while ((count < 100)); do
        docker exec nfs showmount -e
        if [[ $? -eq 0 ]];then
            echo "nfs is started"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "nfs install failed, exit"
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
    load_images nfs

    systemctl stop rpcbind.socket
    systemctl disable rpcbind.socket
    systemctl disable rpcbind
    systemctl stop rpcbind
    test -d /data/ || mkdir -p /data/
    docker-compose -f $WORKDIR/docker-compose.yml up -d
    chmod -R 777 /data/
    check_status
}

main
#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

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
    load_images tools
    docker-compose -f $WORKDIR/docker-compose.yml up -d
}

main




# docker run -ti --name chrony --hostname chrony --network host -v /etc/environment_config.conf:/etc/environment_config.conf chrony:latest bash
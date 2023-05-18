#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf

function check_status() {
    count=1
    while ((count < 100)); do
        sudo curl -v http://$CONTROLLER_MANAGEMENT_IP:8776 > /dev/null
        if [[ $? -eq 0 ]];then
            echo "cinder-api is started!"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "cinder-api install failed, exit"
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
    load_images cinder-api

    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
    test -L /etc/cpcloud/cinder-api && rm -rf /etc/cpcloud/cinder-api
    ln -sv /var/lib/docker/volumes/cinder-api/_data /etc/cpcloud/cinder-api
}

main
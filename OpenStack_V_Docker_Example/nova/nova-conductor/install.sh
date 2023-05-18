#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf

function check_status() {
    count=1
    while ((count < 100)); do
        count_service=$(ps -ef | grep nova-conductor | grep -v grep | wc -l)
        if [[ $count_service -ge 1 ]];then
            echo "nova-conductor is started!"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "nova-conductor install failed, exit"
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
    load_images nova-conductor

    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
    test -L /etc/cpcloud/nova-conductor && rm -rf /etc/cpcloud/nova-conductor
    ln -sv /var/lib/docker/volumes/nova-conductor/_data /etc/cpcloud/nova-conductor
}

main
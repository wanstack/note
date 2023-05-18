#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

source /etc/environment_config.conf
source /etc/admin.openrc

function check_status() {
    count=1
    while ((count < 100)); do
        openstack image list
        if [[ $? -eq 0 ]];then
            echo "glance started."
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "glance install failed, exit"
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
    load_images glance

    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
    chmod -R 777 /data
    test -L /etc/cpcloud/glance && rm -rf /etc/cpcloud/glance
    ln -sv /var/lib/docker/volumes/glance/_data /etc/cpcloud/glance
}

main
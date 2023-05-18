#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
source /etc/environment_config.conf

function check_status() {
    count=1
    while ((count < 100)); do
        count_service=$(ps -ef | grep "/usr/sbin/libvirtd" | grep -v grep | wc -l)
        if [[ $count_service -ge 1 ]];then
            echo "nova-libvirt is started!"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "nova-libvirt install failed, exit"
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
    load_images nova-libvirt

    test -d /var/lib/nova/mnt || mkdir -p /var/lib/nova/mnt
    chown -R 42436.42436 /var/lib/nova/mnt
    chmod -R 777 /var/lib/nova/mnt
    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
    test -L /etc/cpcloud/nova-libvirt && rm -rf /etc/cpcloud/nova-libvirt
    ln -sv /var/lib/docker/volumes/nova-libvirt/_data /etc/cpcloud/nova-libvirt
}

main
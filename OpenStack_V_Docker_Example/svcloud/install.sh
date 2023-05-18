#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

source /etc/environment_config.conf
source /etc/admin.openrc

function check_status() {
    count=1
    while ((count < 100)); do
        svcloud_process_count=$(ps -ef | grep "/usr/bin/python3.6 /usr/bin/gunicorn --config gunicorn_config.py server:app" | grep -v grep | wc -l)
        if [[ $svcloud_process_count -gt 2 ]];then
            echo "svcloud is started"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "svcloud install failed, exit"
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
    load_images svcloud
    \cp -rp $WORKDIR/source_code/* /opt/
    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
}

main
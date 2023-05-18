#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

source /etc/environment_config.conf
source /etc/admin.openrc

function check_status() {
    count=1
    while ((count < 100)); do
        ser_count=$(netstat -tunlp | grep 11111 | wc -l)
        if [[ $ser_count -eq 1 ]];then
            echo "nginx started"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "nginx install failed, exit"
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
    load_images nginx
    test -d /home/apps/ || mkdir -pv /home/apps/  # 前端静态资源
    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
    test -L /etc/nginx && rm -rf /etc/nginx
    ln -sv /var/lib/docker/volumes/nginx/_data /etc/nginx
}

main
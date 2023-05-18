#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

source /etc/environment_config.conf

function check_status() {
    count=1
    while ((count < 100)); do
        docker exec chrony chronyc sources
        if [[ $? -eq 0 ]];then
            echo "chrony is started!"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "chrony install failed, exit"
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
    load_images chrony
    test -d /etc/cpcloud/chrony && rm -rf /etc/cpcloud/chrony
    mkdir -p /etc/cpcloud/chrony
    \cp -rp $WORKDIR/chrony.conf /etc/cpcloud/chrony
    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
    test -L /var/log/cpcloud || ln -sv /var/lib/docker/volumes/cpcloud_logs/_data /var/log/cpcloud
}

main




# docker run -ti --name chrony --hostname chrony --network host -v /etc/environment_config.conf:/etc/environment_config.conf chrony:latest bash
#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

source /etc/environment_config.conf

function check_status() {
    count=1
    while ((count < 10)); do
        docker exec mariadb mysqladmin -uroot -p$MARIADB_ROOT_PASSWD ping
        if [[ $? -eq 0 ]];then
            echo "mariadb is started"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "mariadb install failed, exit"
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
    load_images mariadb

    test -d /etc/cpcloud/mariadb && rm -rf /etc/cpcloud/mariadb
    mkdir -p /etc/cpcloud/mariadb
    \cp -rp $WORKDIR/openstack.cnf /etc/cpcloud/mariadb
    export MARIADB_ROOT_PASSWD=${MARIADB_ROOT_PASSWD}
    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
}

main

# docker run -ti --name mariadb --hostname mariadb --network host  \
# -v /etc/environment_config.conf:/etc/environment_config.conf \
# mariadb:latest bash

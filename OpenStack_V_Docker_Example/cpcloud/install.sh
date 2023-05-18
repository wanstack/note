#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)

source /etc/environment_config.conf
source /etc/admin.openrc

function check_status() {
    count=1
    while ((count < 100)); do
        cpcloud_process_count=$(ps -ef | grep "supervisord" | grep -v grep | wc -l)
        if [[ $cpcloud_process_count -eq 1 ]];then
            echo "cpcloud is started"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "cpcloud install failed, exit"
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

function install_cpcloud() {
    test -d /opt/cpcloud_project/ || mkdir -p /opt/cpcloud_project/
    \cp -rp $WORKDIR/source_code/cpcloud /opt/cpcloud_project/
    mkdir -p /etc/cpcloud/supervisor.conf.d/
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
        \cp -rp $WORKDIR/etc/cpcloud_controller.conf /etc/cpcloud/supervisor.conf.d/cpcloud.conf
    else
        \cp -rp $WORKDIR/etc/cpcloud_compute.conf /etc/cpcloud/supervisor.conf.d/cpcloud.conf
    fi
}

function main() {
    load_images cpcloud
    install_cpcloud
    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
            docker exec cpcloud "/usr/local/bin/create.sh"
        fi
    else
        docker exec cpcloud "/usr/local/bin/create.sh"
    fi
}

main
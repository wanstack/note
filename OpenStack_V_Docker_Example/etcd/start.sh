#!/bin/bash

set -x

ENVIRONMENT_CONFIG=/etc/environment_config.conf
source $ENVIRONMENT_CONFIG
function change_config() {
    sudo chmod -R 777 /var/log/cpcloud
    sudo sed -ri "s@CONTROLLER_MANAGEMENT_IP@$CONTROLLER_MANAGEMENT_IP@g" /etc/etcd/etcd.conf
    sudo sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/etcd/etcd.conf

    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
}

function start_service() {
    sudo chown etcd: /var/lib/etcd/
    /usr/bin/etcd --name=$CONTROLLER_HOSTNAME --data-dir=/var/lib/etcd/default.etcd \
     -advertise-client-urls=http://$CONTROLLER_MANAGEMENT_IP:2379 \
     --listen-client-urls=http://$CONTROLLER_MANAGEMENT_IP:2379,http://127.0.0.1:2379 \
     -initial-advertise-peer-urls=http://$CONTROLLER_MANAGEMENT_IP:2380 \
     -listen-peer-urls=http://$CONTROLLER_MANAGEMENT_IP:2380 \
     -initial-cluster-token=etcd-cluster-01 \
     -initial-cluster=$CONTROLLER_HOSTNAME=http://$CONTROLLER_MANAGEMENT_IP:2380 \
     -initial-cluster-state=new
}

function main() {
    change_config
    start_service
}

main


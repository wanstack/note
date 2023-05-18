#!/bin/bash


set -x

function change_config() {
    sudo chmod -R 777 /var/log/cpcloud
    sudo mkdir -p /var/log/cpcloud/rabbitmq
    sudo chown -R rabbitmq.rabbitmq /var/log/cpcloud/rabbitmq
    sudo chown -R rabbitmq.rabbitmq /etc/rabbitmq

    ENVIRONMENT_CONFIG=/etc/environment_config.conf
    source $ENVIRONMENT_CONFIG
#    sudo sed -ri "s/LOCAL_IP/$LOCAL_IP/g" /etc/rabbitmq/rabbitmq.conf

    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
}


function start_service() {
    change_config
    /usr/sbin/rabbitmq-server
}

function main() {
    start_service
}

main
#!/bin/bash

set -x

source /etc/environment_config.conf


function change_config() {
    sudo test -d /var/log/cpcloud/cinder || sudo mkdir -p /var/log/cpcloud/cinder/
    sudo chmod -R 777 /var/log/cinder
    sudo chown -R cinder.cinder /var/log/cpcloud/cinder

    sudo sed -ri "s@RABBITMQ_USER@$RABBITMQ_USER@g" /etc/cinder/cinder.conf
    sudo sed -ri "s@RABBITMQ_PASSWD@$RABBITMQ_PASSWD@g" /etc/cinder/cinder.conf
    sudo sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/cinder/cinder.conf
    sudo sed -ri "s@LOCAL_IP@$LOCAL_IP@g" /etc/cinder/cinder.conf
    sudo sed -ri "s@CINDER_PASSWD@$CINDER_PASSWD@g" /etc/cinder/cinder.conf
    sudo sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/cinder/nfs_shares


    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
}


function start_service() {
    /usr/bin/cinder-volume --config-file /usr/share/cinder/cinder-dist.conf \
    --config-file /etc/cinder/cinder.conf --logfile /var/log/cpcloud/cinder/volume.log
}

function main() {
    change_config
    start_service

}

main
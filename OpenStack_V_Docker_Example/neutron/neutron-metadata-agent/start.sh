#!/bin/bash

set -x

source /etc/environment_config.conf


function change_config() {
    sudo test -d /var/log/cpcloud/neutron || sudo mkdir -p /var/log/cpcloud/neutron/
    sudo chmod -R 777 /var/log/cpcloud
    sudo chown -R nova.nova /var/log/cpcloud/neutron

    sudo sed -ri "s@RABBITMQ_USER@$RABBITMQ_USER@g" /etc/neutron/neutron.conf
    sudo sed -ri "s@RABBITMQ_PASSWD@$RABBITMQ_PASSWD@g" /etc/neutron/neutron.conf
    sudo sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/neutron/neutron.conf
    sudo sed -ri "s@NEUTRON_PASSWD@$NEUTRON_PASSWD@g" /etc/neutron/neutron.conf
    sudo sed -ri "s@NOVA_PASSWD@$NOVA_PASSWD@g" /etc/neutron/neutron.conf

    sudo sed -ri "s@LOCAL_HOSTNAME@$LOCAL_HOSTNAME@g" /etc/neutron/metadata_agent.ini
    sudo sed -ri "s@METADATA_PASSWD@$METADATA_PASSWD@g" /etc/neutron/metadata_agent.ini

    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
    sudo ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
}



function start_service() {
    /usr/bin/neutron-metadata-agent --config-file /usr/share/neutron/neutron-dist.conf \
    --config-file /etc/neutron/neutron.conf \
    --config-file /etc/neutron/metadata_agent.ini \
    --config-dir /etc/neutron/conf.d/common \
    --config-dir /etc/neutron/conf.d/neutron-metadata-agent \
    --log-file /var/log/cpcloud/neutron/metadata-agent.log
}

function main() {
    change_config
    start_service

}

main
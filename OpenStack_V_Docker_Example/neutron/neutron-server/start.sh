#!/bin/bash

set -x

source /etc/environment_config.conf

function create_db() {
    neutron_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N -e 'show databases'| grep 'neutron'|wc -l)
    if [[ $neutron_count -lt 1 ]];then
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "CREATE DATABASE IF NOT EXISTS neutron;"

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$NEUTRON_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$NEUTRON_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'controller' IDENTIFIED BY '$NEUTRON_PASSWD';"
    fi
}

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

    if [[ ! -f  /etc/neutron/plugin.ini ]];then
        sudo ln -sv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
    fi
}

function create_resource() {
    source /etc/admin.openrc
    openstack user list
    if [[ $? -eq 0 ]];then
        if ! openstack user list | grep neutron;then
            openstack user create --domain default --password $NEUTRON_PASSWD neutron
            openstack role add --project service --user neutron admin
        fi
    fi

    openstack service list
    if [[ $? -eq 0 ]];then
        if ! openstack service list | grep network;then
            openstack service create --name neutron --description "OpenStack Networking" network
            openstack endpoint create --region RegionOne network public http://$CONTROLLER_HOSTNAME:9696
            openstack endpoint create --region RegionOne network internal http://$CONTROLLER_HOSTNAME:9696
            openstack endpoint create --region RegionOne network admin http://$CONTROLLER_HOSTNAME:9696
        fi
    fi
}



function install_fwaas() {
    sudo test -d /usr/lib64/python3.6/site-packages/greenlet-1.0.0.dist-info/ || sudo mv /usr/lib64/python3.6/site-packages/greenlet* /tmp/
    if [[ -d /etc/neutron/rootwrap.d ]];then
        sudo mkdir /etc/neutron/rootwrap.d
    fi

    count=$(pip3 list all | grep neutron-fwaas | wc -l)
    if [[ $count -lt 1 ]];then
        sudo pip3 install --no-index --prefix=/usr --find-links=/opt/pip/v  neutron-fwaas
    fi

    if [[ -f /etc/neutron/rootwrap.d/fwaas-privsep.filters ]];then
        sudo \cp /usr/local/etc/neutron/rootwrap.d/fwaas-privsep.filters /etc/neutron/rootwrap.d/
    fi

    fwaas_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N neutron -e "show tables" | grep fwaas | wc -l)
    if [[ $fwaas_count -lt 1 ]];then
        sudo neutron-db-manage --subproject neutron-fwaas upgrade head
    fi
}

function create_table_structure() {
    neutron_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N neutron -e "show tables" |wc -l)
    if [[ $neutron_count -lt 10 ]];then
        sudo su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
    fi
}


function start_service() {
    /usr/bin/neutron-server --config-file /usr/share/neutron/neutron-dist.conf \
    --config-dir /usr/share/neutron/server \
    --config-file /etc/neutron/neutron.conf \
    --config-file /etc/neutron/plugin.ini \
    --config-dir /etc/neutron/conf.d/common \
    --config-dir /etc/neutron/conf.d/neutron-server \
    --log-file /var/log/cpcloud/neutron/server.log
}

function main() {
    process_count=$(ps -ef | grep /usr/bin/neutron-server| grep -v grep | wc -l)
    if [[ $process_count -lt 1 ]];then
        create_db
        create_resource
        change_config
        create_table_structure
        install_fwaas
        start_service
    fi


}

main
#!/bin/bash

set -x

ENVIRONMENT_CONFIG=/etc/environment_config.conf
source $ENVIRONMENT_CONFIG

function create_db() {
    glance_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N -e 'show databases'| grep 'glance'|wc -l)
    if [[ $glance_count -lt 1 ]];then
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "CREATE DATABASE IF NOT EXISTS glance;"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$GLANCE_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$GLANCE_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'controller' IDENTIFIED BY '$GLANCE_PASSWD';"
    fi
}

function change_config() {
    sudo chmod -R 777 /var/log/cpcloud
    sudo mkdir -p /var/log/cpcloud/glance
    sudo chown -R glance.glance /var/log/cpcloud/glance
    sudo sed -ri "s@CONTROLLER_MANAGEMENT_IP@$CONTROLLER_MANAGEMENT_IP@g" /etc/glance/glance-api.conf
    sudo sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/glance/glance-api.conf
    sudo sed -ri "s@GLANCE_PASSWD@$GLANCE_PASSWD@g" /etc/glance/glance-api.conf
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
}

function create_resource() {
    source /etc/admin.openrc
    openstack user list
    if [[ $? -eq 0 ]];then
        if ! openstack user list | grep glance;then
            openstack user create --domain default --password $GLANCE_PASSWD glance
            openstack role add --project service --user glance admin
        fi
    fi

    openstack service list
    if [[ $? -eq 0 ]];then
        if ! openstack service list | grep image;then
            openstack service create --name glance --description "OpenStack Image" image
            openstack endpoint create --region RegionOne image public http://$CONTROLLER_HOSTNAME:9292
            openstack endpoint create --region RegionOne image internal http://$CONTROLLER_HOSTNAME:9292
            openstack endpoint create --region RegionOne image admin http://$CONTROLLER_HOSTNAME:9292
        fi
    fi

    table_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME glance -N -e "show tables" | wc -l)
    if [[ $table_count -lt 10 ]];then
        sudo su -s /bin/sh -c "glance-manage db_sync" glance
    fi
}

function loop_mount() {
    sudo nohup bash /usr/local/bin/create.sh >> /opt/create.log 2>&1 &
}

function start_service() {
    glance-api
}


function main() {
    create_db
    change_config
    create_resource
    loop_mount
    start_service
}

main
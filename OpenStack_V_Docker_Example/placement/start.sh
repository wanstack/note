#!/bin/bash

set -x

ENVIRONMENT_CONFIG=/etc/environment_config.conf
source $ENVIRONMENT_CONFIG

function create_db() {
    placement_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N -e 'show databases'| grep 'placement'|wc -l)
    if [[ $placement_count -lt 1 ]];then
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "CREATE DATABASE IF NOT EXISTS placement;"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY '$PLACEMENT_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY '$PLACEMENT_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'controller' IDENTIFIED BY '$PLACEMENT_PASSWD';"
    fi
}

function change_config() {
    sudo chmod -R 777 /var/log/cpcloud
    sudo mkdir /var/log/cpcloud/placement
    sudo touch /var/log/cpcloud/placement/placement-api.log
    sudo chown -R placement.cpcloud /var/log/cpcloud/placement
    sudo sed -ri "s@CONTROLLER_MANAGEMENT_IP@$CONTROLLER_MANAGEMENT_IP@g" /etc/httpd/conf.d/00-placement-api.conf

    sudo sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/placement/placement.conf
    sudo sed -ri "s@PLACEMENT_PASSWD@$PLACEMENT_PASSWD@g" /etc/placement/placement.conf

    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
}

function create_resource() {
    source /etc/admin.openrc
    openstack user list
    if [[ $? -eq 0 ]];then
        if ! openstack user list | grep placement;then
            openstack user create --domain default --password $PLACEMENT_PASSWD placement
            openstack role add --project service --user placement admin
        fi
    fi

    openstack service list
    if [[ $? -eq 0 ]];then
        if ! openstack service list | grep placement;then
            openstack service create --name placement --description "Placement API" placement
            openstack endpoint create --region RegionOne placement public http://$CONTROLLER_HOSTNAME:8778
            openstack endpoint create --region RegionOne placement internal http://$CONTROLLER_HOSTNAME:8778
            openstack endpoint create --region RegionOne placement admin http://$CONTROLLER_HOSTNAME:8778
        fi
    fi
    placement_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N placement -e "show tables" |wc -l)
    if [[ $placement_count -lt 2 ]];then
        su -s /bin/sh -c "placement-manage db sync" placement
    fi
}


function start_service() {
    /usr/sbin/httpd -DFOREGROUND
}

function main() {
    create_db
    change_config
    create_resource
    start_service
}

main
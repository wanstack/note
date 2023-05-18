#!/bin/bash

set -x

source /etc/environment_config.conf

function create_db() {
    cinder_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N -e 'show databases'| grep 'cinder'|wc -l)
    if [[ $cinder_count -lt 1 ]];then
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "CREATE DATABASE IF NOT EXISTS cinder;"

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'controller' IDENTIFIED BY '$CINDER_PASSWD';"
    fi
}

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

function create_resource() {
    source /etc/admin.openrc
    openstack user list
    if [[ $? -eq 0 ]];then
        if ! openstack user list | grep cinder;then
            openstack user create --domain default --password $CINDER_PASSWD cinder
            openstack role add --project service --user cinder admin
        fi
    fi

    openstack service list
    if [[ $? -eq 0 ]];then
        if ! openstack service list | grep cinderv2;then
            openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
            openstack endpoint create --region RegionOne volumev2 public http://$CONTROLLER_HOSTNAME:8776/v2/%\(project_id\)s
            openstack endpoint create --region RegionOne volumev2 internal http://$CONTROLLER_HOSTNAME:8776/v2/%\(project_id\)s
            openstack endpoint create --region RegionOne volumev2 admin http://$CONTROLLER_HOSTNAME:8776/v2/%\(project_id\)s
        fi

        if ! openstack service list | grep cinderv3;then
            openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3
            openstack endpoint create --region RegionOne volumev3 public http://$CONTROLLER_HOSTNAME:8776/v3/%\(project_id\)s
            openstack endpoint create --region RegionOne volumev3 internal http://$CONTROLLER_HOSTNAME:8776/v3/%\(project_id\)s
            openstack endpoint create --region RegionOne volumev3 admin http://$CONTROLLER_HOSTNAME:8776/v3/%\(project_id\)s
        fi
    fi
}


function create_table_structure() {
    cinder_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N cinder -e "show tables" |wc -l)
    if [[ $cinder_count -lt 10 ]];then
        su -s /bin/sh -c "cinder-manage db sync" cinder
    fi
}


function start_service() {
    /usr/bin/cinder-api --config-file /usr/share/cinder/cinder-dist.conf \
    --config-file /etc/cinder/cinder.conf --logfile /var/log/cpcloud/cinder/cinder-api.log
}

function main() {
    create_db
    change_config
    create_resource
    create_table_structure
    start_service

}

main
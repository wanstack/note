#!/bin/bash

set -x

function del_resource() {
    source /etc/admin.openrc
    openstack user delete neutron
    for id in $(openstack endpoint list | grep neutron | awk -F '|' '{print $2}');do openstack endpoint delete $id;done
    for id in $(openstack service list | grep neutron | awk -F '|' '{print $2}'); do openstack service delete $id;done
}

function del_other() {
    ENVIRONMENT_CONFIG=/etc/environment_config.conf
    source $ENVIRONMENT_CONFIG

    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'DROP DATABASE IF EXISTS neutron;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'flush privileges;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user neutron@'%';\""
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user neutron@'controller';\""
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user neutron@'localhost';\""
    docker rm -f neutron-server
    docker volume rm neutron-server
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

function main() {
    del_resource
    del_other
}

main
#!/bin/bash

set -x

function del_resource() {
    source /etc/admin.openrc
    openstack user delete nova
    for id in $(openstack endpoint list | grep compute | awk -F '|' '{print $2}');do openstack endpoint delete $id;done
    for id in $(openstack service list | grep nova | awk -F '|' '{print $2}'); do openstack service delete $id;done
}

function del_other() {
    ENVIRONMENT_CONFIG=/etc/environment_config.conf
    source $ENVIRONMENT_CONFIG

    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'DROP DATABASE IF EXISTS nova_api;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'DROP DATABASE IF EXISTS nova;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'DROP DATABASE IF EXISTS nova_cell0;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'flush privileges;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user nova@'%';\""
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user nova@'controller';\""
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user nova@'localhost';\""
    docker rm -f nova-api
    docker volume rm nova-api
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

function main() {
    del_resource
    del_other
}

main
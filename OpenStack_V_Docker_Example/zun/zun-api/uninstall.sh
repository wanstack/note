#!/bin/bash

set -x

function del_resource() {
    source /etc/admin.openrc
    openstack user delete zun
    for id in $(openstack endpoint list | grep zun | awk -F '|' '{print $2}');do openstack endpoint delete $id;done
    for id in $(openstack service list | grep zun | awk -F '|' '{print $2}'); do openstack service delete $id;done
}

function del_other() {
    ENVIRONMENT_CONFIG=/etc/environment_config.conf
    source $ENVIRONMENT_CONFIG

    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'DROP DATABASE IF EXISTS zun;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'flush privileges;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user zun@'%';\""
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user zun@'controller';\""
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user zun@'localhost';\""
    docker rm -f zun-api
    docker volume rm zun-api
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}


function main() {
    del_resource
    del_other
}

main
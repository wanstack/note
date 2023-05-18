#!/bin/bash

set -x

function main() {
    ENVIRONMENT_CONFIG=/etc/environment_config.conf
    source $ENVIRONMENT_CONFIG
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'DROP DATABASE IF EXISTS keystone;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'flush privileges;'"
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user keystone@'%';\""
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user keystone@'controller';\""
    docker exec mariadb bash -c "mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e \"drop user keystone@'localhost';\""
    docker rm -f keystone
    docker volume rm keystone
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
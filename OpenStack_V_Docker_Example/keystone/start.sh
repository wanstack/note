#!/bin/bash

set -x

ENVIRONMENT_CONFIG=/etc/environment_config.conf
source $ENVIRONMENT_CONFIG

function create_db() {
    keystone_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N -e 'show databases'| grep 'keystone'|wc -l)
    if [[ $keystone_count -lt 1 ]];then
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "CREATE DATABASE IF NOT EXISTS keystone;"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'controller' IDENTIFIED BY '$KEYSTONE_PASSWD';"
    fi
}

function change_config() {
    mkdir -p /var/log/cpcloud/keystone/
    chmod -R 777 /var/log/cpcloud
    chown -R .cpcloud /var/log/cpcloud/keystone
    sed -ri "s@CONTROLLER_MANAGEMENT_IP@$CONTROLLER_MANAGEMENT_IP@g" /etc/keystone/keystone.conf
    sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/keystone/keystone.conf
    sed -ri "s@KEYSTONE_PASSWD@$KEYSTONE_PASSWD@g" /etc/keystone/keystone.conf

    sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/httpd/conf/httpd.conf
    sed -ri "s@CONTROLLER_MANAGEMENT_IP@$CONTROLLER_MANAGEMENT_IP@g" /etc/httpd/conf/httpd.conf

    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
}

function start_service() {
    table_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME keystone -N -e "show tables" | wc -l)
    if [[ $table_count -lt 40 ]];then
        su -s /bin/sh -c "keystone-manage db_sync" keystone
    fi
    if [ ! -d "/etc/keystone/fernet-keys" ] ; then
        keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    fi
    if [ ! -d '/etc/keystone/credential-keys' ] ; then
        keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
    fi
    region_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME keystone -N -e "SELECT COUNT(1) FROM region;")
    if [[ $region_count -lt 1 ]];then
        keystone-manage bootstrap --bootstrap-password $ADMIN_PASSWD \
      --bootstrap-admin-url http://$CONTROLLER_HOSTNAME:5000/v3/ \
      --bootstrap-internal-url http://$CONTROLLER_HOSTNAME:5000/v3/ \
      --bootstrap-public-url http://$CONTROLLER_HOSTNAME:5000/v3/ \
      --bootstrap-region-id RegionOne
    fi
    if [[ ! -f /etc/httpd/conf.d/wsgi-keystone.conf ]];then
        ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
    fi
    /usr/sbin/httpd -DFOREGROUND
}




function main() {
    create_db
    change_config
    start_service
    create_resource
}

main
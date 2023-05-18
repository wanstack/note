#!/bin/bash

set -x

source /etc/environment_config.conf
source /etc/admin.openrc

cp -rp /etc/admin.openrc /root/admin.openrc

function create_struct() {
    mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'create database IF NOT EXISTS cpcloud default character set utf8;'
    mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON cpcloud.* TO 'cpcloud'@'localhost' IDENTIFIED BY \"qworqwkan312fq\";"
    mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON cpcloud.* TO 'cpcloud'@'controller' IDENTIFIED BY \"qworqwkan312fq\";"
    mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON cpcloud.* TO 'cpcloud'@'%' IDENTIFIED BY \"qworqwkan312fq\";"
}

function install_supervisord() {
    count=$(pip list all | grep supervisor  |wc -l)
    if [[ $count -ne 1 ]];then
        pip install iniparse --no-index --find-links=/opt/pip/v
        pip install supervisor --no-index --find-links=/opt/pip/v
        mkdir -p /var/log/cpcloud/gunicorn && mkdir -p /var/log/cpcloud/supervisord && mkdir -p /var/log/cpcloud/supervisor

        cd /opt/cpcloud_project/cpcloud
        pip install -r requirements.txt --no-index --find-links=/opt/pip/cpcloud --ignore-installed PyYAML
        cd -
    fi

    test -d /var/log/gunicorn || mkdir -p /var/log/gunicorn

    test -L /usr/bin/cpc || ln -s /usr/bin/openstack /usr/bin/cpc

}

function change_config_supervisor() {
    sed -i "s/LOCAL_HOSTNAME/$LOCAL_HOSTNAME/g" /etc/cpcloud/supervisor.conf.d/cpcloud.conf
}

function change_config_cpcloud() {
    CPCLOUD_CONFIG=/opt/cpcloud_project/cpcloud/config.py
    old_origin_guacamole_url="127.0.0.3"
    new_origin_guacamole_url=$(ip a | grep $BR_EX_INTERFACE_NAME | grep inet | awk '{print $2}' | awk -F '/' '{print $1}')


    old_rabbit_config="rabbit://openstack:openstack888@controller:5672/"
    new_rabbit_config="rabbit://$RABBITMQ_USER:$RABBITMQ_PASSWD@$CONTROLLER_HOSTNAME:5672"
    sed -i "s#$old_rabbit_config#$new_rabbit_config#g" $CPCLOUD_CONFIG

    if [ "$ENABLE_HTTPS" = "TRUE" ];then
        sed -i "s#http://127.0.0.3:8200/#https://127.0.0.3:8443/#g" $CPCLOUD_CONFIG
        sed -i "s#http://127.0.0.3:8200/#https://127.0.0.3:8443/#g" $CPCLOUD_CONFIG
    fi

    sed -i "s/cpcloud888/${OS_PASSWORD}/g" $CPCLOUD_CONFIG
    sed -i "s/ens192/${BR_EX_INTERFACE_NAME}/g" $CPCLOUD_CONFIG
    sed -i "s/ens161/${BR_MANAGER_INTERFACE_NAME}/g" $CPCLOUD_CONFIG
    sed -i "s/ens224/${BR_MIRROR_INTERFACE_NAME}/g" $CPCLOUD_CONFIG
    sed -i "s/ens256/${BR_VLAN_INTERFACE_NAME}/g" $CPCLOUD_CONFIG

    sed -i "s/${old_origin_guacamole_url}/${new_origin_guacamole_url}/g" $CPCLOUD_CONFIG

    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf


    # 创建数据库表
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
        count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N cpcloud -e "show tables" | wc -l)
        if [[ $count -lt 2 ]];then
            cd /opt/cpcloud_project/cpcloud/common && /usr/bin/python3 create_table.py
            cd /opt/cpcloud_project/cpcloud && /usr/bin/python3 -m alembic stamp head
            # 初始化内置靶标
            cd /opt/cpcloud_project/cpcloud/apps/device/db && /usr/bin/python3 device_init.py
        fi
    fi
}

function cron_sdn() {
    chmod 777 /usr/local/bin/restart_sdn_app.sh
    echo > /var/spool/cron/root
    echo "*/2 * * * * /bin/bash /usr/local/bin/restart_sdn_app.sh" >> /var/spool/cron/root

}


function start_service() {
    /usr/sbin/crond -s
    /usr/local/bin/supervisord -n -c /etc/supervisord.conf

}

function main() {
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
        create_struct
    else
        echo "skip create table"
    fi

    install_supervisord
    change_config_supervisor
    change_config_cpcloud
    cron_sdn
    start_service
}

main


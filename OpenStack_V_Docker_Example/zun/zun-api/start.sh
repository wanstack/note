#!/bin/bash

set -x

source /etc/environment_config.conf
source /etc/admin.openrc

sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf


function install_cni_plugins() {
    test -d /opt/cni/bin || mkdir -p /opt/cni/bin
    cat /opt/pip/v/cni-plugins-amd64-v0.7.1.tgz | tar -C /opt/cni/bin -xzvf - ./loopback
    install -o zun -m 0555 -D /usr/bin/zun-cni /opt/cni/bin/zun-cni

    /usr/bin/zun-cni-daemon
}

function install_zun() {
    count=$(pip list all | grep zun | wc -l)
    if [[ $count -lt 1 ]];then
        sudo test -d /usr/lib64/python3.6/site-packages/greenlet-1.0.0.dist-info/ || sudo mv /usr/lib64/python3.6/site-packages/greenlet* /tmp/
        test -d /var/lib/zun || mkdir -pv /var/lib/zun
        tar -zxvf /opt/pip/v/zun-6.0.0.tar.gz -C /var/lib/zun
        mv /var/lib/zun/zun-6.0.0 /var/lib/zun/zun
        chown -R zun:zun /var/lib/zun/zun

        cd /var/lib/zun/zun
        pip install --no-index --prefix=/usr --find-links=/opt/pip/v -r requirements.txt
        python3 setup.py install --prefix=/usr
        cd -

        mkdir /var/log/cpcloud/zun && chown -R zun:zun /var/log/cpcloud/zun
    fi

}

function controller_create_kuryr_resource() {
    if [ `openstack user list | grep -c 'kuryr'` -lt 1 ] ; then
        openstack user create --domain default --password $KURYR_LIBNETWORK_PASSWD kuryr
        openstack role add --project service --user kuryr admin
    fi
}

function compute_kuryr() {
    count=$(pip list all | grep kuryr-libnetwork | wc -l)
    if [[ $count -lt 1 ]];then
        tar -zxvf /opt/pip/v/kuryr-libnetwork.tar.gz -C /var/lib/kuryr/
        chown -R kuryr:kuryr /var/lib/kuryr/kuryr-libnetwork

        cd /var/lib/kuryr/kuryr-libnetwork
        pip install --no-index --prefix=/usr --find-links=/opt/pip/v -r requirements.txt
        python3 setup.py install --prefix=/usr
        cd -

        mkdir -p /var/log/cpcloud/kuryr/
        sudo chown -R kuryr.kuryr /var/log/cpcloud/kuryr

        sudo sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/kuryr/kuryr.conf
        sudo sed -ri "s@KURYR_LIBNETWORK_PASSWD@$KURYR_LIBNETWORK_PASSWD@g" /etc/kuryr/kuryr.conf
    fi

    /usr/bin/kuryr-server --config-file /etc/kuryr/kuryr.conf
}


function create_db() {
    zun_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N -e 'show databases'| grep 'zun'|wc -l)
    if [[ $zun_count -lt 1 ]];then
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "CREATE DATABASE IF NOT EXISTS zun;"

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON zun.* TO 'zun'@'localhost' IDENTIFIED BY '$ZUN_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON zun.* TO 'zun'@'%' IDENTIFIED BY '$ZUN_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON zun.* TO 'zun'@'controller' IDENTIFIED BY '$ZUN_PASSWD';"
    fi
}

function change_config() {

    sudo test -d /var/log/cpcloud/zun || sudo mkdir -p /var/log/cpcloud/zun/
    sudo chmod -R 777 /var/log/cpcloud
    sudo chown -R zun.zun /var/log/cpcloud/zun

    sudo sed -ri "s@RABBITMQ_USER@$RABBITMQ_USER@g" /etc/zun/zun.conf
    sudo sed -ri "s@RABBITMQ_PASSWD@$RABBITMQ_PASSWD@g" /etc/zun/zun.conf
    sudo sed -ri "s@LOCAL_IP@$LOCAL_IP@g" /etc/zun/zun.conf
    sudo sed -ri "s@ZUN_PASSWD@$ZUN_PASSWD@g" /etc/zun/zun.conf
    sudo sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/zun/zun.conf

}

function create_resource() {
    source /etc/admin.openrc
    openstack user list
    if [[ $? -eq 0 ]];then
        if ! openstack user list | grep zun;then
            openstack user create --domain default --password $ZUN_PASSWD zun
            openstack role add --project service --user zun admin
        fi
    fi

    openstack service list
    if [[ $? -eq 0 ]];then
        if ! openstack service list | grep container;then
            openstack service create --name zun --description "Container Service" container
            openstack endpoint create --region RegionOne container public http://$CONTROLLER_HOSTNAME:9517/v1
            openstack endpoint create --region RegionOne container internal http://$CONTROLLER_HOSTNAME:9517/v1
            openstack endpoint create --region RegionOne container admin http://$CONTROLLER_HOSTNAME:9517/v1
        fi
    fi
}

function create_table_structure() {
    zun_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N zun -e "show tables" |wc -l)
    if [[ $zun_count -lt 10 ]];then
        su -s /bin/sh -c "zun-db-manage upgrade" zun
    fi
}

function start_service() {
    /usr/bin/zun-api
}


function main() {
    create_db
    create_resource
    install_zun
    change_config
    create_table_structure
    start_service
}

main
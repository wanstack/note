#!/bin/bash

set -x

ENVIRONMENT_CONFIG=/etc/environment_config.conf
source $ENVIRONMENT_CONFIG

function create_db() {

    nova_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N -e 'show databases'| grep 'nova_api'|wc -l)
    if [[ $nova_count -lt 1 ]];then
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "CREATE DATABASE IF NOT EXISTS nova_api;"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "CREATE DATABASE IF NOT EXISTS nova;"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "CREATE DATABASE IF NOT EXISTS nova_cell0;"

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'controller' IDENTIFIED BY '$NOVA_PASSWD';"

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'controller' IDENTIFIED BY '$NOVA_PASSWD';"

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_PASSWD';"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'controller' IDENTIFIED BY '$NOVA_PASSWD';"
    fi
}

function change_config() {
    mkdir -p /var/log/cpcloud/nova/
    chmod -R 777 /var/log/cpcloud
    chown -R nova.nova /var/log/cpcloud/nova

    if egrep -q '(vmx|svm)' /proc/cpuinfo; then
        VIRT_TYPE=kvm
    else
        VIRT_TYPE=qemu
    fi

    sed -ri "s@RABBITMQ_USER@$RABBITMQ_USER@g" /etc/nova/nova.conf
    sed -ri "s@RABBITMQ_PASSWD@$RABBITMQ_PASSWD@g" /etc/nova/nova.conf
    sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/nova/nova.conf
    sed -ri "s@LOCAL_IP@$LOCAL_IP@g" /etc/nova/nova.conf
    sed -ri "s@NOVA_PASSWD@$NOVA_PASSWD@g" /etc/nova/nova.conf
    sed -ri "s@VIRT_TYPE@$VIRT_TYPE@g" /etc/nova/nova.conf
    sed -ri "s@NEUTRON_PASSWD@$NEUTRON_PASSWD@g" /etc/nova/nova.conf
    sed -ri "s@METADATA_PASSWD@$METADATA_PASSWD@g" /etc/nova/nova.conf
    sed -ri "s@PLACEMENT_PASSWD@$PLACEMENT_PASSWD@g" /etc/nova/nova.conf
    sed -ri "s@WEB_IP@$WEB_IP@g" /etc/nova/nova.conf

    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
}

function create_resource() {
    source /etc/admin.openrc
    openstack user list
    if [[ $? -eq 0 ]];then
        if ! openstack user list | grep nova;then
            openstack user create --domain default --password $NOVA_PASSWD nova
            openstack role add --project service --user nova admin
        fi
    fi

    openstack service list
    if [[ $? -eq 0 ]];then
        if ! openstack service list | grep compute;then
            openstack service create --name nova --description "OpenStack Compute" compute
            openstack endpoint create --region RegionOne compute public http://$CONTROLLER_HOSTNAME:8774/v2.1
            openstack endpoint create --region RegionOne compute internal http://$CONTROLLER_HOSTNAME:8774/v2.1
            openstack endpoint create --region RegionOne compute admin http://$CONTROLLER_HOSTNAME:8774/v2.1
        fi
    fi
}

function create_table_structure() {
    nova_count=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N nova -e "show tables" |wc -l)
    if [[ $nova_count -lt 2 ]];then
        su -s /bin/sh -c "nova-manage api_db sync" nova >/dev/null 2>&1
        su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova  >/dev/null 2>&1
        su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova >/dev/null 2>&1
        su -s /bin/sh -c "nova-manage db sync" nova >/dev/null 2>&1
        su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova >/dev/null 2>&1
    fi
}

function auto_partition() {
    sudo chmod 777 /usr/share/nova/rootwrap/compute.filters
    sudo grep initializeDisk.sh /usr/share/nova/rootwrap/compute.filters > /dev/null
    if [ $? -ne 0 ]; then
        if ! sudo grep "\[Filters\]" /usr/share/nova/rootwrap/compute.filters > /dev/null;then
            sudo cat << EOF >> /usr/share/nova/rootwrap/compute.filters
[Filters]
# nova/virt/libvirt/driver.py
initializeDisk.sh: CommandFilter, /usr/lib/python3.6/site-packages/nova/virt/libvirt/initializeDisk.sh, root

EOF
        else

        sudo cat << EOF >> /usr/share/nova/rootwrap/compute.filters
# nova/virt/libvirt/driver.py
initializeDisk.sh: CommandFilter, /usr/lib/python3.6/site-packages/nova/virt/libvirt/initializeDisk.sh, root

EOF
        fi
    fi
    sudo chmod +x /usr/lib/python3.6/site-packages/nova/virt/libvirt/initializeDisk.sh

    sudo chmod 644 /usr/share/nova/rootwrap/compute.filters

}

function start_service() {
    /usr/bin/nova-api
}

function main() {
    create_db
    change_config
    create_resource
    create_table_structure
#    auto_partition
    start_service
}

main
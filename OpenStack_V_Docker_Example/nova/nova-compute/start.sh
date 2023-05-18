#!/bin/bash

set -x

ENVIRONMENT_CONFIG=/etc/environment_config.conf
source $ENVIRONMENT_CONFIG

function change_config() {
    sudo test -d /var/log/cpcloud/nova || sudo mkdir -p /var/log/cpcloud/nova/
    sudo chmod -R 777 /var/log/cpcloud
    sudo chown -R nova.nova /var/log/cpcloud/nova

    if sudo egrep -q '(vmx|svm)' /proc/cpuinfo; then
        VIRT_TYPE=kvm
    else
        VIRT_TYPE=qemu
    fi

    sudo sed -ri "s@RABBITMQ_USER@$RABBITMQ_USER@g" /etc/nova/nova.conf
    sudo sed -ri "s@RABBITMQ_PASSWD@$RABBITMQ_PASSWD@g" /etc/nova/nova.conf
    sudo sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/nova/nova.conf
    sudo sed -ri "s@LOCAL_IP@$LOCAL_IP@g" /etc/nova/nova.conf
    sudo sed -ri "s@NOVA_PASSWD@$NOVA_PASSWD@g" /etc/nova/nova.conf
    sudo sed -ri "s@VIRT_TYPE@$VIRT_TYPE@g" /etc/nova/nova.conf
    sudo sed -ri "s@NEUTRON_PASSWD@$NEUTRON_PASSWD@g" /etc/nova/nova.conf
    sudo sed -ri "s@METADATA_PASSWD@$METADATA_PASSWD@g" /etc/nova/nova.conf
    sudo sed -ri "s@PLACEMENT_PASSWD@$PLACEMENT_PASSWD@g" /etc/nova/nova.conf
    sudo sed -ri "s@WEB_IP@$WEB_IP@g" /etc/nova/nova.conf

    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
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
    /usr/bin/nova-compute
}

function main() {
    change_config
    auto_partition
    start_service
}

main
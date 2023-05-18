#!/bin/bash

set -x

source /etc/environment_config.conf

function mount_nfs() {
    count=$(sudo mount | grep /data/glance | wc -l)
    if [[ $count -lt 1 ]];then
	sudo mkdir -pv /var/lib/glance
	sudo chmod -R 777 /var/lib/glance
        sudo mount -v -t nfs -o rw,nfsvers=3,nolock,proto=udp,port=2049 $CONTROLLER_MANAGEMENT_IP:/data/glance /var/lib/glance
    fi
}

function install_zunclient() {
    zunclient_count=$(pip3 list | grep zunclient | wc -l)
    if [[ $zunclient_count -eq 1 ]];then
        echo "python-zunclient is installed."
    else
        pip3 install --no-index --prefix=/usr --find-links=/opt/pip/v python-zunclient > /dev/null 2>&1
    fi
}


function start_service() {
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
    ln -sv /usr/bin/openstack /usr/bin/cpc
    pip3 install --no-index --prefix=/usr --find-links=/opt/pip/v iniparse
    install_zunclient
    mount_nfs
    sleep infinity

}

function main() {
    start_service
}

main






#!/bin/bash

set -x

source /etc/environment_config.conf

function mount_nfs() {
    count=$(sudo mount | grep nfs | wc -l)
    if [[ $count -lt 1 ]];then
        sudo mount -v -t nfs -o rw,nfsvers=3,nolock,proto=udp,port=2049 $CONTROLLER_MANAGEMENT_IP:/data/glance /var/lib/glance
    fi
    sudo test -d /var/lib/glance/images || sudo mkdir -p /var/lib/glance/images
}





function main() {
    while true;do
        sleep 1
        mount_nfs
    done
}

main
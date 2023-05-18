#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
ENVIRONMENT_CONFIG=$WORKDIR/environment_config.conf
source $ENVIRONMENT_CONFIG

unset TAG

function del_global_config() {
    rm -rf /etc/$ENVIRONMENT_CONFIG
}

function clean_docker_config() {
    rm -rf /etc/systemd/system/docker.service.d
    rm -rf /usr/lib/docker/plugins/kuryr
    rm -rf /etc/containerd/config.toml
    rm -rf /var/run/docker.sock/
    systemctl daemon-reload
    systemctl restart docker
    systemctl restart docker.socket
    systemctl restart containerd
    rm -rf /usr/lib/docker/plugins/kuryr

}


function del_set_env() {
    rm -rf /etc/admin.openrc
    rm -rf /root/admin.openrc
}

function uninstall_zun() {
    echo "Uninstalling $WORKDIR/zun"
    test -f $WORKDIR/zun/uninstall.log && rm -rf $WORKDIR/zun/uninstall.log
    bash $WORKDIR/zun/uninstall.sh >> $WORKDIR/zun/uninstall.log 2>&1

}

function uninstall() {
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
             uninstall_modules=(cpcloud svcloud images vsftpd nginx cron tools cinder neutron horizon openvswitch nova placement glance \
             nfs etcd keystone rabbitmq mariadb memcached etcd chrony yum pypi)
        else
            uninstall_modules=(images neutron openvswitch nova chrony)
        fi
    else
         uninstall_modules=(cpcloud svcloud images vsftpd nginx cron tools cinder neutron horizon openvswitch nova placement\
         glance nfs etcd keystone rabbitmq mariadb memcached etcd chrony yum pypi)
    fi
    for module in "${uninstall_modules[@]}"; do
        echo "Uninstalling $WORKDIR/$module"
        test -f $WORKDIR/$module/uninstall.log && rm -rf $WORKDIR/$module/uninstall.log
        bash $WORKDIR/$module/uninstall.sh >> $WORKDIR/$module/uninstall.log 2>&1
    done
}

function clean_mount() {
    for i in $(mount | grep controller:/data | awk '{print $1}'); do umount $i;done
    rm -rf /etc/cpcloud/
    rm -rf /var/log/cpcloud
    docker volume rm -f cpcloud_logs
    docker volume rm -f cinder_lib
}

function main() {
    uninstall_zun
    clean_docker_config
    uninstall
    del_global_config
    del_set_env
    clean_mount

}

main
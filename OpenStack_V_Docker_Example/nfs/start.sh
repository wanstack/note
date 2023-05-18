#!/bin/bash

set -x

source /etc/environment_config.conf

function change_config() {
    nfsconf --set nfsd vers3 y
    nfsconf --set nfsd vers4 n
    nfsconf --set nfsd vers2 n
    nfsconf --set nfsd udp y
    sed -ri "s@ALLOW_CHRONY_NETWORKS@$ALLOW_CHRONY_NETWORKS@g" /etc/exports

    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
}

function is_process_running() {
    if [[ -n $(pgrep $1) ]]; then
        return 0
    else
        return 1
    fi
}

function stop_container() {
    echo 'received SIGTERM'
    /usr/bin/rpc.nfsd 0
    sleep 1
    exit
}

trap stop_container SIGTERM             # 收到 SIGTERM信号后，执行 stop_container函数

function start_service() {
    while :
    do
        if ! is_process_running 'rpcbind'; then # rpcbind 运行
            echo 'starting rpcbind'
            /sbin/rpcbind -i
        fi

        if ! is_process_running 'rpc.statd'; then
            echo 'starting rpc.statd'
            /sbin/rpc.statd --no-notify --port 32765 --outgoing-port 32766
            sleep .5
        fi

        if [[ ! -a /proc/fs/nfsd/threads ]]; then
            echo 'starting rpc.nfsd'
            echo $(pgrep 'nfsd')
            /usr/sbin/rpc.nfsd -V3 -N2 -N4 -d 8
        fi

        if ! is_process_running 'rpc.mountd'; then
            echo 'starting rpc.mountd'
            /usr/sbin/rpc.mountd -V3 -N2 -N4 --port 32767
            /usr/sbin/exportfs -ra
        fi

        sleep 5
    done
    
}

function main() {
    /usr/local/bin/exports.sh
    change_config
    start_service
}

main
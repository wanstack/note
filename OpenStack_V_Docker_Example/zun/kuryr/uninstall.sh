#!/bin/bash

set -x

source /etc/admin.openrc

function main() {
    docker rm -f kuryr
    docker volume rm kuryr
    docker restart memcached # 创建 endpoint 时 memcached有缓存
    openstack user delete kuryr
}

main
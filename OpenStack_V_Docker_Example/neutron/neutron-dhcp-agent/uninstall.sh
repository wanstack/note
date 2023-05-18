#!/bin/bash

set -x

function main() {
    docker rm -f neutron-dhcp-agent
    docker volume rm neutron-dhcp-agent
    docker volume rm neutron-metadata-socket
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
#!/bin/bash

set -x

function main() {
    docker rm -f neutron-l3-agent
    docker volume rm neutron-l3-agent
    docker volume rm neutron-metadata-socket
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
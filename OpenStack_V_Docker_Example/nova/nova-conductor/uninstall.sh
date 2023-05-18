#!/bin/bash

set -x

function main() {
    docker rm -f nova-conductor
    docker volume rm nova-conductor
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
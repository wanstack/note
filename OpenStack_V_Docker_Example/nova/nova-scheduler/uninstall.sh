#!/bin/bash

set -x

function main() {
    docker rm -f nova-scheduler
    docker volume rm nova-scheduler
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
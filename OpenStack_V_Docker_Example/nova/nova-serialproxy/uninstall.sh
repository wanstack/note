#!/bin/bash

set -x

function main() {
    docker rm -f nova-serialproxy
    docker volume rm nova-serialproxy
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
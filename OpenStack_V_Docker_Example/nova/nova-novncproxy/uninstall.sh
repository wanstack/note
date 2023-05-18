#!/bin/bash

set -x

function main() {
    docker rm -f nova-novncproxy
    docker volume rm nova-novncproxy
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
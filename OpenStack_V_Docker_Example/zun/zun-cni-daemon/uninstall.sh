#!/bin/bash

set -x

function main() {
    docker rm -f zun-cni-daemon
    docker volume rm zun-cni-daemon
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
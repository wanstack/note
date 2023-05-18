#!/bin/bash

set -x

function main() {
    docker rm -f zun-compute
    docker volume rm zun-compute
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
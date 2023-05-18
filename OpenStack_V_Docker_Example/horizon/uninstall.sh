#!/bin/bash

set -x

function main() {
    docker rm -f horizon
    docker volume rm horizon
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
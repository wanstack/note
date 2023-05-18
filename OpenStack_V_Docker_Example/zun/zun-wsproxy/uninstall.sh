#!/bin/bash

set -x

function main() {
    docker rm -f zun-wsproxy
    docker volume rm zun-wsproxy
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

main
#!/bin/bash

set -x

function del() {
    docker rm -f cinder-scheduler
    docker volume rm cinder-scheduler
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

function main() {
    del
}

main
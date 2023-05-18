#!/bin/bash

set -x

function del() {
    docker rm -f cinder-volume
    docker volume rm cinder-volume
    docker volume rm cinder_lib
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

function main() {
    del
}

main
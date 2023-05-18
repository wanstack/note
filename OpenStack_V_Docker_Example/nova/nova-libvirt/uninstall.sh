#!/bin/bash

set -x

function main() {
    docker rm -f nova-libvirt
    umount /var/lib/docker/volumes/nova-libvirt/_data/qemu/
    umount /var/lib/docker/volumes/nova-compute-shared/_data/mnt/
    docker volume rm nova-libvirt
    docker volume rm nova-compute-shared
    docker volume rm libvirtd-shared
    docker volume rm nova-libvirt-qemu
    docker restart memcached # 创建 endpoint 时 memcached有缓存
    rm -rf /run/libvirt*
}

main
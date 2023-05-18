#!/bin/bash

set -x

function main() {
    docker rm -f etcd
    docker volume rm -f etcd
}

main
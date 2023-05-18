#!/bin/bash

set -x

function main() {
    docker rm -f nfs
#    rm -rf /data/*
    for i in $(ps -ef | grep nfs | grep -v grep  | awk '{print $2}'); do kill -9 $i;done
}

main
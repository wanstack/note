#!/bin/bash

set -x

function main() {
    docker rm -f yum
    PID=$(netstat -tunlp | grep 8088 | awk '{print $(NF-1)}' | awk -F '/' '{print $1}')
    kill -9 $PID
}

main
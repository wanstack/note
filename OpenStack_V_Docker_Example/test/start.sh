#!/bin/bash

set -x


function start_service() {
    mkdir /opt/test
    echo "aaa" > /opt/test/2.sh

    ping 127.0.0.1

}

function main() {
    start_service
}

main






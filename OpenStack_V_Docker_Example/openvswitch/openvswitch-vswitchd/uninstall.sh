#!/bin/bash

set -x

function main() {
    docker rm -f openvswitch-vswitchd
    docker volume rm openvswitch-vswitchd
}

main
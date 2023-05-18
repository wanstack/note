#!/bin/bash

set -x

function main() {
    docker rm -f svcloud
    rm -rf /opt/svcloud
}

main
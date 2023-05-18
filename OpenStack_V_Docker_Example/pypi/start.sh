#!/bin/bash

set -x

function start_service() {
    pypi-server run -i 0.0.0.0 -p 8089 /opt/pip/ >> /var/log/pypi.log 2>&1
}

function main() {
    start_service
}

main
#!/bin/bash

set -x


function main() {
    docker rm -f vsftpd
}

main
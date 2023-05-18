#!/bin/bash

set -x


function main() {
    docker rm -f nginx
}

main
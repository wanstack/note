#!/bin/bash

set -x

function main() {
    docker rm -f pypi
}

main
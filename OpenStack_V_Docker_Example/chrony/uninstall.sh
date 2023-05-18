#!/bin/bash

set -x

function uninstall() {
    docker rm -f chrony
}

function main() {
    uninstall
}

main
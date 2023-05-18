#!/bin/bash

set -x

function uninstall() {
    docker rm -f mariadb
    docker volume rm mariadb
}

function main() {
    uninstall
}

main
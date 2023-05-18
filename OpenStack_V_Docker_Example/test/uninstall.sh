#!/bin/bash

set -x

function uninstall() {
    docker rm -f test

}

function main() {
    uninstall
}

main
#!/bin/bash

set -x

function uninstall() {
    docker rm -f tools

}

function main() {
    uninstall
}

main
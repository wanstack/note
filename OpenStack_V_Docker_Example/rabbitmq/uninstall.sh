#!/bin/bash


set -x


function uninstall() {
    docker rm -f rabbitmq
    docker volume rm rabbitmq

}

function main() {
    uninstall
}

main
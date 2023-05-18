#!/bin/bash

set -x



function del_docker_resource() {
    docker rm -f openvswitch-db-server
    docker volume rm openvswitch-db-server
    rm -rf /run/openvswitch
}

function main() {
    del_docker_resource

}

main
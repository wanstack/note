#!/bin/bash

# interface test todo

set -x

WORKDIR=$(cd $(dirname $0); pwd)

function main() {
    docker-compose -f $WORKDIR/docker-compose.yml up -d
}

main




# docker run -ti --name chrony --hostname chrony --network host -v /etc/environment_config.conf:/etc/environment_config.conf chrony:latest bash
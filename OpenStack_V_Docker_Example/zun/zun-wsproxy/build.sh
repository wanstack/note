#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
TAG=$1


function build_image() {
    image_name=$1
    docker build -t $image_name:$TAG $WORKDIR
    image=$WORKDIR/$image_name.tar
    if [[ ! -e $image ]]; then
        docker save -o $image $image_name:$TAG
    else
        rm -rf $image
        docker save -o $image $image_name:$TAG
    fi

    docker rmi -f $image_name:$TAG

}

function main() {
    build_image zun-wsproxy
}

main

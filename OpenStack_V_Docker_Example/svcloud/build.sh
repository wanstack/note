#!/bin/bash

set -x

WORKDIR=$(cd $(dirname $0); pwd)
BRANCH=$1
TAG=$2


function clone_svcloud() {
    rm -rf $WORKDIR/source_code/*
    git clone -b $BRANCH git@10.10.10.12:cpcloud/svcloud.git $WORKDIR/source_code/svcloud
}


function build_image() {
    clone_svcloud

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
    build_image svcloud
}

main

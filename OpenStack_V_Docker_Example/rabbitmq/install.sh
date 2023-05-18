#!/bin/bash


set -x


WORKDIR=$(cd $(dirname $0); pwd)

function check_status() {
    count=1
    while ((count < 100)); do
        docker exec rabbitmq rabbitmqctl list_users
        if [[ $? -eq 0 ]];then
            sleep 50
            docker exec rabbitmq /bin/bash -c "create.sh"
            echo "rabbitmq is started"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 49 ]];then
        echo "rabbitmq install failed, exit"
        exit 1
    fi
}

function load_images() {
    image_name=$1
    if docker images | grep $image_name; then
        TAG=$(docker images | grep $image_name | awk '{print $2}')
        docker rmi -f $image_name:$TAG
        docker load -i $WORKDIR/$image_name.tar
    else
        docker load -i $WORKDIR/$image_name.tar
    fi
}

function main() {
    load_images rabbitmq

    test -d /etc/cpcloud/rabbitmq && rm -rf /etc/cpcloud/rabbitmq
    mkdir -p /etc/cpcloud/rabbitmq
    \cp -rp $WORKDIR/rabbitmq.conf /etc/cpcloud/rabbitmq
    \cp -rp $WORKDIR/rabbitmq-env.conf /etc/cpcloud/rabbitmq
    docker-compose -f $WORKDIR/docker-compose.yml up -d
    check_status
}

main


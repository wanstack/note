#!/bin/bash

set -x

function create() {
    source /etc/environment_config.conf
    sudo /usr/sbin/rabbitmq-plugins enable rabbitmq_management
    if [ `rabbitmqctl list_users|grep -c "$RABBITMQ_USER"` -lt 1 ] ; then
        rabbitmqctl add_user $RABBITMQ_USER $RABBITMQ_PASSWD
        rabbitmqctl set_permissions $RABBITMQ_USER ".*" ".*" ".*"
        rabbitmqctl set_user_tags   $RABBITMQ_USER  administrator >/dev/null
    fi

}

function main() {
    create
}

main

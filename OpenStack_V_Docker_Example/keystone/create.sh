#!/bin/bash

set -x

function create_resource() {
    source /etc/admin.openrc
    while ((count < 10)); do
        openstack endpoint list
        if [[ $? -eq 0 ]]; then
            service_count=$(openstack project list | grep service | wc -l)
            if [[ $service_count -lt 1 ]];then
                openstack project create --domain default --description "Service Project" service
            fi
            break
        else
            sleep 10
            ((count++))
        fi
    done
    if (( count >= 10 ));then
       echo "Create keystone resource ERROR!"
       exit 1
    fi
}

function main() {
    create_resource
}

main
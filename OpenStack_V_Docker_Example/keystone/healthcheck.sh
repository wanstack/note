#!/bin/bash

function check_keystone() {
    ss -antl | grep 5000 > /dev/null
    if [[ $? -eq 0 ]];then
        exit 0
    else
        exit 1
    fi
}
#!/bin/bash

set -x
source /etc/admin.openrc
source /etc/environment_config.conf

function change_config() {
    sed -i "s/cpcloud888/$OS_PASSWORD/g" /opt/svcloud/svcloud/config.py
    if [ "$ENABLE_HTTPS" = "TRUE" ];then
        sed -i "s#http://{host}:8080/e/{hostname}#https://{host}:8080/e/{hostname}#g" /opt/svcloud/svcloud/config.py
    fi
    sed -i 's@/var/log/svcloud/@/var/log/cpcloud/svcloud/@g' /opt/svcloud/svcloud/config.py

    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf

    rm -rf /etc/localtime
    echo "Etc/UTC" > /etc/timezone
}

function start_service() {

    cd /opt/svcloud
    pip install --no-index --prefix=/usr --find-links=/opt/pip/svcloud -r requirements.txt
    cd /opt/svcloud/svcloud
    exec gunicorn --config gunicorn_config.py server:app
}

function main() {
    change_config
    start_service
}

main


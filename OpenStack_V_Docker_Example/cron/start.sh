#!/bin/bash

set -x

source /etc/environment_config.conf
source /etc/admin.openrc






function cron_clean_resource() {
    grep "cpcloud_resource_clean.sh" /var/spool/cron/root
    if [[ $? -ne 0 ]];then
        # 每天凌晨执行一次
        echo "0 1 * * * /bin/bash /usr/local/bin/cpcloud_resource_clean.sh" >> /var/spool/cron/root
    fi
}

function cron_ssh_authorization() {
    grep "ssh_authorization.sh" /var/spool/cron/root
    if [[ $? -ne 0 ]];then
        echo "*/2 * * * * /bin/bash /usr/local/bin/ssh_authorization.sh" >> /var/spool/cron/root
    fi
}

function cron_backup_all_dbs() {
    grep "backup_all_dbs.sh" /var/spool/cron/root
    if [[ $? -ne 0 ]];then
        echo "0 3 * * * /bin/bash /usr/local/bin/backup_all_dbs.sh" >> /var/spool/cron/root
    fi
}


function start_service() {
   /usr/sbin/crond -s -n

}

function main() {
    cron_clean_resource
#    cron_ssh_authorization
#    cron_backup_all_dbs

    start_service
}

main


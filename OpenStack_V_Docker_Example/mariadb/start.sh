#!/bin/bash

set -x

function change_config() {
    source /etc/environment_config.conf
    sudo chmod -R 777 /var/log/cpcloud
    sudo mkdir -p /var/log/cpcloud/mariadb
    sudo chown -R mysql.mysql /var/log/cpcloud/mariadb
#    sudo sed -ri "s@LOCAL_IP@$LOCAL_IP@g" /etc/my.cnf.d/openstack.cnf

    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sudo sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf

}

function change_root_passwd {
    source /etc/environment_config.conf
    mysqladmin -u root password "${MARIADB_ROOT_PASSWD}"
    mysql -uroot -p"${MARIADB_ROOT_PASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWD}' WITH GRANT OPTION;"
    mysql -uroot -p"${MARIADB_ROOT_PASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWD}' WITH GRANT OPTION;"
    mysql -uroot -p"${MARIADB_ROOT_PASSWD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'controller' IDENTIFIED BY '${MARIADB_ROOT_PASSWD}' WITH GRANT OPTION;"
    mysqladmin -uroot -p"${MARIADB_ROOT_PASSWD}" shutdown
}


function start_service() {
    mysql_install_db
    if [[ $? -eq 0 ]]; then
        /usr/bin/mysqld_safe &
    else
        echo "mysql_install_db ERROR"
        exit 1
    fi

    count=1
    while (( count < 10 )) ; do
        mysqladmin ping
        if [[ $? -eq 0 ]]; then
            change_root_passwd
            break
        else
            sleep 3
            ((count++))
        fi
    done
    if (( count >= 10 ));then
       echo "change_root_passwd ERROR!"
       exit 1
    fi

    /usr/bin/mysqld_safe
}

function main() {
    change_config
    start_service
}

main
#!/bin/bash

source /etc/environment_config.conf

set -x

function uninstall() {
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]] ; then
        docker rm -f cpcloud_guacamole
        docker rm -f cpcloud_guacd
        docker rm -f redis
        docker rm -f cpcloud_web-tty-client
        docker rm -f cpcloud_web-tty-client-ssl
        docker rm -f fastdfs

        docker rmi -f redis:latest
        docker rmi -f vbox:v1
        docker rmi -f guacamole:v3.1
        docker rmi -f guacd:v2
        docker rmi -f container-web-tty:latest
        docker rmi -f container-web-tty:v2
        docker rmi -f fastdfs:latest
        docker rmi -f tomcat:5.3c

        umount /home/guacamole
        umount /home/guacdrive
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'DROP DATABASE IF EXISTS guacamole;'
    else
        docker rm -f cpcloud_guacamole
        docker rm -f cpcloud_guacd
        docker rm -f cpcloud_web-tty-client
        docker rm -f cpcloud_web-tty-client-ssl

        docker rmi -f guacamole:v3.1
        docker rmi -f guacd:v2
        docker rmi -f container-web-tty:latest
        docker rmi -f container-web-tty:v2
        docker rmi -f tomcat:5.3c

    fi
}

function main() {
    uninstall
}

main

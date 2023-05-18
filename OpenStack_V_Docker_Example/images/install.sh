#!/bin/bash
set -x

WORKDIR=$(cd $(dirname $0); pwd)

source /etc/environment_config.conf

test -d /opt/docker_build || mkdir -p /opt/docker_build
\cp -rp $WORKDIR/* /opt/docker_build/


function load_images() {
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]] ; then
        docker load < /opt/docker_build/redis.tar
        docker load < /opt/docker_build/tomcat53c.tar
        docker load < /opt/docker_build/vbox_v1.tar
        docker load < /opt/docker_build/fastdfs.tar
        docker load < /opt/docker_build/guacamole.tar
        docker load < /opt/docker_build/guacd.tar
        docker load < /opt/docker_build/container-web-tty.tar
        docker load < /opt/docker_build/container-web-tty-ssl.tar
    else
        docker load < /opt/docker_build/guacamole.tar
        docker load < /opt/docker_build/guacd.tar
        docker load < /opt/docker_build/container-web-tty.tar
        docker load < /opt/docker_build/container-web-tty-ssl.tar
    fi
}

function create_db() {
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]] ; then
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'create database IF NOT EXISTS oj default character set utf8;'
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'create database IF NOT EXISTS cr default character set utf8;'
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'create database IF NOT EXISTS rtks default character set utf8;'
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'create database IF NOT EXISTS rd default character set utf8;'

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON oj.* TO 'crdbuser'@'localhost' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON oj.* TO 'crdbuser'@'controller' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON oj.* TO 'crdbuser'@'%' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON cr.* TO 'crdbuser'@'localhost' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON cr.* TO 'crdbuser'@'controller' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON cr.* TO 'crdbuser'@'%' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON rtks.* TO 'crdbuser'@'localhost' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON rtks.* TO 'crdbuser'@'controller' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON rtks.* TO 'crdbuser'@'%' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"

        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON rd.* TO 'crdbuser'@'localhost' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON rd.* TO 'crdbuser'@'controller' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"
        mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON rd.* TO 'crdbuser'@'%' IDENTIFIED BY \"$MARIADB_CRDBUSER_PASS\";"
    fi
}



function check_status() {
    service=$1
    count=1
    while ((count < 100)); do
        count_service=$(docker ps -f name=$service | grep -v IMAGE | wc -l)
        if [[ $count_service -eq 1 ]];then
            echo "$service is started!"
            break
        else
            sleep 10
            ((count++))
        fi
    done
    echo $count
    if [[ $count -gt 99 ]];then
        echo "$service install failed, exit"
        exit 1
    fi
}

function install_mariadb() {
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]] ; then
        MARIADB=/opt/docker_build/docker_compose_mariadb.yml
        docker-compose -f $MARIADB up -d
        check_status mariadb_mp
    fi

}

function install_redis() {
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]] ; then
        REDIS=/opt/docker_build/docker_compose_redis.yml
        sed -i "s/\"9379:6379/\"${CONTROLLER_MANAGEMENT_IP}:9379:6379/g" $REDIS

        docker-compose -f $REDIS up -d
        check_status redis
    fi

}

function install_rabbitmq() {
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]] ; then
        RABBITMQ=/opt/docker_build/docker_compose_rabbitmq.yml
        RABBITMQ_CONF=/etc/cpcloud/rabbitmq/rabbitmq.conf
        rm -rf /opt/docker_build/rabbitmq.conf
        \cp -rf  $RABBITMQ_CONF /opt/docker_build/
        echo 'consumer_timeout=7200000' >>/opt/docker_build/rabbitmq.conf

        docker-compose -f $RABBITMQ up -d
        check_status rabbitmq

        if [ `docker ps -f name='rabbitmq_mp'|grep -ic 'up'` -gt 0 ] ; then
            docker exec  rabbitmq_mp sh -c 'rabbitmq-plugins enable rabbitmq_management' >/dev/null 2>&1
            docker exec  rabbitmq_mp sh -c "sed -i 's/true/false/g' /etc/rabbitmq/conf.d/management_agent.disable_metrics_collector.conf"
        fi
    fi
}

function install_fastfs() {
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]] ; then
        FASTDFS=/opt/docker_build/docker_compose_fastdfs.yml
        sed -i "s/IPADDR_FASTDFS/$WEB_IP/g" $FASTDFS

        docker-compose -f $FASTDFS up -d
        check_status fastdfs
    fi


}

function install_web_tty() {

    WEB_TTY_HTTP=/opt/docker_build/cpcloud_web_tty_client_http.yml
    WEB_TTY_HTTPS=/opt/docker_build/cpcloud_web_tty_client_https.yml
    GUACAMOLE=/opt/docker_build/docker-compose-guacamole.yml

    if [ "$ENABLE_HTTPS" = "TRUE" ];then
        [ ! -d /etc/webtty/ssl ] && mkdir -p /etc/webtty/ssl
        \cp -rp /opt/docker_build/webtty_ssl/* /etc/webtty/ssl/
        docker-compose -f $WEB_TTY_HTTPS  up -d
        check_status cpcloud_web-tty-client-ssl
    else
        docker-compose -f $WEB_TTY_HTTP  up -d
        check_status cpcloud_web-tty-client
    fi 
}

function install_guacamole() {
    test -d /home/guacamole || mkdir -p /home/guacamole
    test -d /home/guacdrive || mkdir -p /home/guacdrive
    mount -v -t nfs -o rw,nfsvers=3,nolock,proto=udp,port=2049 controller:/data/guacamole /home/guacamole
    mount -v -t nfs -o rw,nfsvers=3,nolock,proto=udp,port=2049 controller:/data/guacdrive /home/guacdrive

    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]] ; then
        if [ `mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N -e 'show databases'|grep -c 'guacamole'` -lt 1 ] ;then
            mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e 'create database IF NOT EXISTS guacamole default character set utf8;'
            mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON guacamole.* TO 'guacamole'@'localhost' IDENTIFIED BY 'guacamole';"
            mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON guacamole.* TO 'guacamole'@'controller' IDENTIFIED BY 'guacamole';"
            mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON guacamole.* TO 'guacamole'@'%' IDENTIFIED BY 'guacamole' ;"
            mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -Dguacamole < /opt/docker_build/initsb.sql
            for nodename in `grep -i controller /etc/hosts|awk '/^[1-9]/{print $2}'` ; do
                mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -e "GRANT ALL PRIVILEGES ON  guacamole.* TO 'guacamole'@'${nodename}' IDENTIFIED BY 'guacamole';"
            done
        fi
    fi

    docker-compose -p guacamole -f $GUACAMOLE up -d
    check_status cpcloud_guacamole
    check_status cpcloud_guacd
}




function main() {
    load_images
    install_redis
    install_fastfs
    install_web_tty
    install_guacamole
    create_db
}

main
#!/bin/bash


source  /root/admin.openrc
source /etc/environment_config.conf

function firtlineconfig() {
    office_IP=$(openstack server list -c Networks -f value | awk -F '=' '{print $NF}')
    test -d /home/tmpinstallusr || mkdir -pv /home/tmpinstallusr
    echo > /home/tmpinstallusr/firstlineconfig
    cat >> /home/tmpinstallusr/firstlineconfig <<EOF
office_IP=${office_IP}
webcard=${BR_EX_INTERFACE_NAME}
webcard_ip=${WEB_IP}
management_card=${BR_MANAGER_INTERFACE_NAME}
management_card_ip=${CONTROLLER_MANAGEMENT_IP}
AllInOne=${ALL_IN_ONE}
noderole=${CURRENT_NODE_TYPE}
host_name=${LOCAL_HOSTNAME}
mirror_card=${BR_MIRROR_INTERFACE_NAME}
trunk_card=${BR_VLAN_INTERFACE_NAME}
HTTPS_ENABLE=${ENABLE_HTTPS}
MARIADB_ROOT_PASSWORD='cyberpeace@2020'
languageType=Chinese
OJ_PORT=8996
MYSQL_ROOT_PASSWORD='cyberpeace@2020'
MYSQL_PORT=9306
REDIS_PASSWORD=MzhhMzU4NDQzNzU
REDIS_PORT=9379
RABBITMQ_DEFAULT_USER=cpcloud
RABBITMQ_DEFAULT_PASS=MzhhMzU4NDQzNzU
RABBITMQ_PORT=9672
MP_PORT=8001
EOF

}

firtlineconfig
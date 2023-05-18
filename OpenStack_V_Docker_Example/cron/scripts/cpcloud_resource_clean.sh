#!/bin/bash

source /etc/admin.openrc
export PATH=$PATH:/usr/bin:/usr/share/locale/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin

DELETE_DAY=7
MAX_ROWS=10000

HOSTNAME=$(hostname)

function init_log_file() {
    # 清空日志，每次只记录最新日志
    LOG_FILE=/var/log/cpcloud_resource_clean.log
    if [ ! -f $LOG_FILE ]; then
        touch $LOG_FILE
    else
        echo > $LOG_FILE
    fi
}

function clean_error_instance() {
    # 清除错误状态的虚拟机
    ERROR_INSTANCE_ID=$(openstack server list -c ID -c Status -f value | grep ERROR | awk '{print $1}')
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for error_id in ${ERROR_INSTANCE_ID}; do
        echo "${DATE} Delete ERROR instance ${error_id}" >> $LOG_FILE
        openstack server delete ${error_id} >> $LOG_FILE 2>&1
        if [ $? -ne 0 ]; then
            echo -e "\e[1;33;41m ${DATE} Deleted ERROR container failed \e[0m" >> $LOG_FILE
            # exit 1
            continue
        fi

    done
    echo -e "\e[1;33;42m ${DATE} Deleted ERROR instance complete \e[0m" >> $LOG_FILE

    # 清理虚拟机libvirt启动日志
    rm -rf /var/log/libvirt/qemu/*.log
}

function clean_error_container() {
    # 清除错误状态容器
    ERROR_CONTAINER_ID=$(openstack appcontainer list -c uuid -c status -f value | grep Error | awk '{print $1}')
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for error_id in ${ERROR_CONTAINER_ID}; do
        echo "${DATE} Delete ERROR instance ${error_id}" >> $LOG_FILE
        openstack appcontainer delete ${error_id} >> $LOG_FILE 2>&1
        if [ $? -ne 0 ]; then
            echo -e "\e[1;33;41m ${DATE} Deleted ERROR container failed \e[0m" >> $LOG_FILE
            # exit 1
            continue
        fi
    done
    echo -e "\e[1;33;42m ${DATE} Deleted ERROR container complete \e[0m" >> $LOG_FILE
}

function clean_error_snapshot() {
    # 清除错误状态卷快照
    ERROR_SNAPSHOT_ID=$(openstack volume snapshot list -c ID -c Status -f value | grep error | awk '{print $1}')
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for error_id in ${ERROR_SNAPSHOT_ID}; do
        echo "${DATE} Delete ERROR snapshot ${error_id}" >> $LOG_FILE
        openstack volume snapshot delete ${error_id} >> $LOG_FILE 2>&1
        if [ $? -ne 0 ]; then
            echo -e "\e[1;33;41m ${DATE} Deleted ERROR snapshot failed \e[0m" >> $LOG_FILE
            # exit 1
            continue
        fi
    done
    echo -e "\e[1;33;42m ${DATE} Deleted ERROR snapshot complete \e[0m" >> $LOG_FILE
}

function clean_unless_image() {
    # 清除镜像大小为0，并且对应的卷快照不存在

    # 查找状态是active的image
    ACTIVE_IMAGES_ID=$(openstack image list -c ID -c Status -f value | grep active | awk '{print $1}')
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    GLANCE_MARIADB_PASSWD=$(cat /etc/glance/glance-api.conf| grep "pymysql" | awk -F '[:|@]' '{print $3}')
    for active_id in ${ACTIVE_IMAGES_ID}; do
        image_size=$(openstack image show ${active_id} -c size -f value)
        if [ $image_size -eq 0 ]; then
            # 查找image属性中的snapshot_id
            image_properties=$(mysql -uglance -p$GLANCE_MARIADB_PASSWD -e \
            "select value from glance.image_properties where image_id='${active_id}' and name='block_device_mapping';"\
            | grep -v value | sed s/null/None/g | sed s/true/True/g | sed s/false/False/g)
            image_snapshot_id=$(python -c "print(${image_properties}[0].get('snapshot_id'))")
            # 如果在snapshot中找不到则删除此镜像
            openstack volume snapshot list | grep ${image_snapshot_id}
            if [ $? -ne 0 ]; then
                echo "${DATE} Delete ERROR image ${active_id}" >> $LOG_FILE
                openstack image delete ${active_id} >> $LOG_FILE 2>&1
                # 删除不了，则退出脚本
                if [ $? -ne 0 ]; then
                    echo -e "\e[1;33;41m ${DATE} Deleted ERROR image failed \e[0m" >> $LOG_FILE
                    #exit 1
                    continue
                fi
            fi
        fi
    done
    echo -e "\e[1;33;42m ${DATE} Deleted ERROR image complete \e[0m" >> $LOG_FILE

}

function is_more_than_hour() {
    status=false # false表示不超过一个小时，true表示超过一个小时
    delta_time=3600

    CURRENT_TIMESTAMP=$(date +%s)
    CREATE_TIMESTAMP=$(date +%s -d $1)
    DELTA_TIMESTAMP=$(($CURRENT_TIMESTAMP - $CREATE_TIMESTAMP))
    if [ $DELTA_TIMESTAMP -gt $delta_time ];then
       status=true
    fi

    result=$status
}

function clean_unless_error_volume() {
    # 卷快照不存在，并且没有关联到实例，并且创建时间大于一个小时；或者状态为error 的卷

    # 1. 删除卷是error状态的
    ERROR_VOLUME_ID=$(openstack volume list -c ID -c Status -f value | grep error | awk '{print $1}')
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for error_id in ${ERROR_VOLUME_ID}; do
        echo "${DATE} Delete ERROR volume ${error_id}" >> $LOG_FILE
        openstack volume delete ${error_id} >> $LOG_FILE 2>&1
        if [ $? -ne 0 ]; then
            echo -e "\e[1;33;41m ${DATE} Deleted ERROR volume failed \e[0m" >> $LOG_FILE
            continue
        fi
    done
    echo -e "\e[1;33;42m ${DATE} Deleted ERROR volume complete \e[0m" >> $LOG_FILE

    # 2. 删除volume 不在 snapshot中的，并且创建时间大于一个小时
    UNLESS_VOLUME_ID=$(openstack volume list -c ID -c Status -f value | egrep -v "error|in-use" | awk '{print $1}')
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for unless_id in ${UNLESS_VOLUME_ID}; do
        count=$(cinder snapshot-list  --volume-id=$unless_id | wc -l) # null=4
        CREATE_AT=$(openstack volume show ${unless_id} -c created_at -f value)
        is_more_than_hour $CREATE_AT

        if [ $count -eq 4 ] && [ $status = "true" ]; then
            # 删除
            echo "${DATE} Delete UNLESS volume ${unless_id}" >> $LOG_FILE
            openstack volume delete ${unless_id} >> $LOG_FILE 2>&1
            if [ $? -ne 0 ]; then
                echo -e "\e[1;33;41m ${DATE} Deleted UNLESS volume failed \e[0m" >> $LOG_FILE
                continue
            fi
        fi
    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS volume complete \e[0m" >> $LOG_FILE
}


function clean_unless_router() {
    # 路由器连接的网络，网络上仅有一个interface，没有compute:nova 端口。则路由器删除和网络的连接端口
    ROUTER_LIST=$(openstack router list -c ID -f value)
    for router_id in $ROUTER_LIST; do
        INTERFACE_INFO=$(openstack router show $router_id -c interfaces_info -f value)
        CREATE_AT_ROUTER=$(openstack router show $router_id -c created_at -f value)

        # 获取和路由器关联的subnet_ids
        SUBNET_ATTR=$(openstack router show $router_id -c interfaces_info -f value)
        for SUBNET_ID in $(python -c "for i in $SUBNET_ATTR:print(i.get('subnet_id'))");do
            # 获取SUBNET_ID 子网下的所有相关port_id
            PORT_IDS=$(openstack port list | grep $SUBNET_ID | awk -F '|' '{print $2}' | sed s/[[:space:]]//g)
            # 遍历查询PORT_ID的属性,包含compute:nova，compute:kuryr则跳过
            PORT_COUNTS=0
            COUNT=0
            for port_id in $PORT_IDS; do
                PORT_COUNTS=$(($PORT_COUNTS+1))
                port_attr=$(openstack port show $port_id -c device_owner -f value)
                port_attr=`eval echo $port_attr`
                if [ -n "$port_attr" ] && [ $port_attr == "compute:kuryr" -o $port_attr == "compute:nova"  ];then
                    # 如果包含compute:kuryr 和compute:nova，则跳出
                    break
                else
                    # 只包含network:router_interface 和 network:dhcp，count+1，count == PORT_COUNTS
                    # 则 可以进行删除，否则则跳出，继续下一个SUBNET_ID
                    COUNT=$(($COUNT+1))
                fi
            done
            if [ $PORT_COUNTS -eq $COUNT ]; then
               # 删除
               # 删除路由器关联subnet_id
               openstack router remove subnet $router_id $SUBNET_ID
            fi
        done


        is_more_than_hour $CREATE_AT_ROUTER
        # 只连接外部网络, 且 创建时间超过一个小时
        if [ "$INTERFACE_INFO" = "[]" ] && [ $status = "true" ]; then
            echo "${DATE} Delete UNLESS router ${router_id}" >> $LOG_FILE
            # 先删除静态路由规则
            neutron router-update --no-routes $router_id >> $LOG_FILE 2>&1
            openstack router delete $router_id >> $LOG_FILE 2>&1
            if [ $? -ne 0 ]; then
                echo -e "\e[1;33;41m ${DATE} Deleted UNLESS router failed \e[0m" >> $LOG_FILE
                continue
            fi
        fi
    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS router complete \e[0m" >> $LOG_FILE
}

function clean_unless_port() {
    UNLESS_PORT_ID=$(openstack port list -c ID -c Status -f value | grep DOWN | awk '{print $1}')
    # down且device_id 为空
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for port_id in ${UNLESS_PORT_ID}; do
        is_device_id_None=$(openstack port show $port_id -c device_id -f value)
        CREATE_AT_PORT=$(openstack port show $port_id -c created_at -f value)
        is_more_than_hour $CREATE_AT_PORT
        if [ $status = "true" ] && [ "$is_device_id_None" = "" ]; then
            echo "${DATE} Deleted UNLESS port ${port_id}" >> $LOG_FILE
            openstack port delete ${port_id} >> $LOG_FILE 2>&1
            if [ $? -ne 0 ]; then
                echo -e "\e[1;33;41m ${DATE} Deleted UNLESS por failed \e[0m" >> $LOG_FILE
                # exit 1
                continue
            fi
        fi

    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS por complete \e[0m" >> $LOG_FILE
}

function clean_unless_network() {
    # 如果仅仅只有dhcp port可以正常删除，否则删除报错，然后删除下一个
    # 关于port 是down状态的，clean_unless_port 会清除掉
    NETWORK_ID=$(openstack network list -c ID -c Name -f value | egrep -v "oj_ext|mgmt|fpc-net" | awk '{print $1}')
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for net_id in ${NETWORK_ID}; do
        CREATE_AT_NETWORK=$(openstack network show $net_id -c created_at -f value)
        is_more_than_hour $CREATE_AT_NETWORK
        if [ $status = "true" ]; then
            echo "${DATE} Deleted UNLESS network ${net_id}" >> $LOG_FILE
            openstack network delete ${net_id} >> $LOG_FILE 2>&1
            if [ $? -ne 0 ]; then
                echo -e "\e[1;33;41m ${DATE} Deleted UNLESS network failed \e[0m" >> $LOG_FILE
                # exit 1
                continue
            fi
        fi

    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS network complete \e[0m" >> $LOG_FILE
}

function clean_unless_floatingip() {
    # 查找所有floating ip的id
    FLOATINGIP_ID=$(openstack floating ip list -c ID -f value)
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for floating_ip_id in ${FLOATINGIP_ID}; do
        FIXED_IP=$(openstack floating ip show $floating_ip_id -c fixed_ip_address -f value)
        if [ "$FIXED_IP" = None ];then
            CREATE_AT_FLOATING_IP=$(openstack floating ip show $floating_ip_id -c created_at -f value)
            is_more_than_hour $CREATE_AT_FLOATING_IP
            if [ $status = "true" ]; then
                echo "${DATE} Deleted UNLESS floating ip ${floating_ip_id}" >> $LOG_FILE
                openstack floating ip delete ${floating_ip_id} >> $LOG_FILE 2>&1
                if [ $? -ne 0 ]; then
                    echo -e "\e[1;33;41m ${DATE} Deleted UNLESS floating ip failed \e[0m" >> $LOG_FILE
                    # exit 1
                    continue
                fi
            fi
        fi
    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS floating ip complete \e[0m" >> $LOG_FILE
}


function clean_unless_fwaas() {
    # 1. 先删除firewall_group
    # 2. 再删除policy
    # 3. 再删除rule
    DATE=$(date "+%Y-%m-%d %H:%M:%S")

    # 1. 删除firewall group
    FW_GROUP_IDS=$(openstack firewall group list -f value | awk '{print $2,$1,$3,$4}' | egrep -v "^default" | awk '{print $2}')
    for fw_group_id in $FW_GROUP_IDS; do
        FW_GROUP_STATUS=$(openstack firewall group show $fw_group_id -c Status -f value)
        if [ "$FW_GROUP_STATUS" != "ACTIVE" ];then
           # 删除防火墙
           openstack firewall group delete $fw_group_id >> $LOG_FILE 2>&1
           if [ $? -eq 0 ]; then
                echo "${DATE} Deleted UNLESS firewall group  $fw_group_id" >> $LOG_FILE
           fi
        fi
    done

    # 2. 删除policy
    FW_GROUP_POLICY_IDS=$(openstack firewall group policy list -c ID -f value)
    for fw_group_policy_id in $FW_GROUP_POLICY_IDS; do
        openstack firewall group policy delete $fw_group_policy_id >> $LOG_FILE 2>&1
        if [ $? -eq 0 ]; then
                echo "${DATE} Deleted UNLESS firewall group policy $fw_group_policy_id" >> $LOG_FILE
           fi
    done

    # 3. 删除rule
    FW_GROUP_RULE_IDS=$(openstack firewall group rule list -c ID -f value)
    for fw_group_rule_id in $FW_GROUP_RULE_IDS; do
        openstack firewall group rule delete $fw_group_rule_id >> $LOG_FILE 2>&1
        if [ $? -eq 0 ]; then
                echo "${DATE} Deleted UNLESS firewall group rule $fw_group_rule_id" >> $LOG_FILE
           fi
    done


}


function clean_unless_policy() {
    # 未使用
    PORT_IDS=$(openstack port list -c ID -c Status -f value | grep ACTIVE | awk '{print $1}')
    QOS_POLICY_IDS=$(neutron qos-policy-list -c id -f value)
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for qos_policy_id in $QOS_POLICY_IDS; do

        for port_id in $PORT_IDS; do
            qos_policy_id_port=$(openstack port show $port_id -c qos_policy_id -f value)
            if [ "$qos_policy_id_port" != None ]; then  # 说明关联了qos-policy
                if [[ "$qos_policy_id_port" =~ ${qos_policy_id} ]]; then # 找到了qos-policy-id和port关联上了
                    echo "${DATE} $qos_policy_id_port qos_policy is used"
                else
                    # 开始删除qos-policy
                    CREATE_AT_QOS=$(neutron qos-policy-show $qos_policy_id -c created_at -f value)
                    is_more_than_hour $CREATE_AT_QOS
                    if [ $status = "true" ]; then # 超出1个小时了
                        echo "${DATE} Deleted UNLESS qos-policy ${qos_policy_id}" >> $LOG_FILE
                        neutron qos-policy-delete $qos_policy_id >> $LOG_FILE 2>&1
                        if [ $? -ne 0 ]; then
                            echo -e "\e[1;33;41m ${DATE} Deleted UNLESS qos-policy failed \e[0m" >> $LOG_FILE
                            # exit 1
                            continue
                        fi
                    fi


                fi
            fi

        done

    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS qos-policy complete \e[0m" >> $LOG_FILE
}

function clean_unless_qos_policy() {
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    NEUTRON_MARIADB_PASSWD=$(cat /etc/neutron/neutron.conf| grep "pymysql" | awk -F '[:|@]' '{print $3}')
    # 找到所有和port关联的policy
    POLICY_IDS=$(mysql -uneutron -p$NEUTRON_MARIADB_PASSWD -e "select policy_id from neutron.qos_port_policy_bindings;" | awk -F '|' '{print $1}'| grep -v policy_id)
    for p_id in $POLICY_IDS; do
        UNLESS_POLICY_ID=$(neutron qos-policy-list -c id -f value | grep -v $p_id) # 过滤掉关联的policy
        for unless_id in $UNLESS_POLICY_ID; do # 遍历没有关联的qos-policy-id
            CREATE_AT_QOS=$(neutron qos-policy-show $unless_id -c created_at -f value)
            is_more_than_hour $CREATE_AT_QOS
            if [ $status = "true" ]; then # 找到超出1个小时了
                echo "${DATE} Deleted UNLESS qos policy ${unless_id}" >> $LOG_FILE
                neutron qos-policy-delete $unless_id >> $LOG_FILE 2>&1  # 这里可以直接删除qos policy
                if [ $? -ne 0 ]; then
                    echo -e "\e[1;33;41m ${DATE} Deleted UNLESS qos policy failed \e[0m" >> $LOG_FILE
                    # exit 1
                    continue
                fi
            fi
        done

    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS qos policy complete \e[0m" >> $LOG_FILE
}


function clean_unless_ovs_port() {
    UNLESS_OVS_PORTS=$(ovs-vsctl show | grep "No such device" | awk '{print $(NF-3)}')
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    for ovs_id in $UNLESS_OVS_PORTS; do
        echo "${DATE} Deleted UNLESS ovs port ${ovs_id}" >> $LOG_FILE
        ovs-vsctl del-port $ovs_id
        if [ $? -ne 0 ]; then
            echo -e "\e[1;33;41m ${DATE} Deleted UNLESS ovs port failed \e[0m" >> $LOG_FILE
            # exit 1
            continue
        fi
    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS ovs port complete \e[0m" >> $LOG_FILE
}

function unless_portmapping() {
    # LIST REQ
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    FWD_LIST_INFO=$(curl -X GET "http://controller:9999/knapsack/fwd_app/v1/" -H "accept: application/json" | sed s/true/True/g | sed s/false/False/g)
    for FWD_ID in $(python -c "for v in $FWD_LIST_INFO.get('data'):print(v.get('id'))"); do
        # GET REQ
        FWD_GET_INFO=$(curl -X GET "http://controller:9999/knapsack/fwd_app/v1/$FWD_ID" -H "accept: application/json" | sed s/true/True/g | sed s/false/False/g)
        network_id=$(python -c "print($FWD_GET_INFO.get('network_id'))")
        instance_ip=$(python -c "print($FWD_GET_INFO.get('instance_ip'))")
        is_network_id=$(openstack network list -c ID -f value | grep -c $network_id)
        is_instance_ip=$(openstack server list -c Networks -f value | grep -c $instance_ip)
        is_container_ip=$(openstack appcontainer list -c addresses -f value | grep -c $instance_ip)
        # 网络不存在，或者虚拟机和容器都不存在，则删除
        if [[ $is_network_id -lt 1 ]]; then
           CREATE_AT=$(python -c "print($FWD_GET_INFO.get('created_at'))")

           is_more_than_hour $CREATE_AT
           if [ $status = "true" ]; then
                echo "${DATE} Deleted UNLESS FWD ${FWD_ID}, NETWORK_ID: ${network_id}, INSTANCE_IP: ${instance_ip}" >> $LOG_FILE
                # 调用删除接口
                curl -X DELETE "http://controller:9999/knapsack/fwd_app/v1/$FWD_ID" -H "accept: application/json"
            fi
        fi

    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS portmapping complete \e[0m" >> $LOG_FILE

}


function clean_unless_container_network() {
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    KURYR_NETWORK_UUIDS=$(docker network ls -f driver=kuryr | awk '{print $2}' | grep -v ID)
    NEUTRON_NETWORK_UUIDS=$(openstack network list -c ID -f value)
    for kuryr_network_uuids in $KURYR_NETWORK_UUIDS; do
        # 如果 $NEUTRON_NETWORK_UUIDS 不包含 $kuryr_network_uuids 则开始删除
        if [[ ! $NEUTRON_NETWORK_UUIDS =~ $kuryr_network_uuids ]]; then
            # 获取网络信息
            DOCKER_INSPECT_INFO=$(docker inspect $kuryr_network_uuids | sed s/false/False/g | sed s/true/True/g)
            DOCKER_NETWORK_ID=$(python -c "print(${DOCKER_INSPECT_INFO}[0].get('Id'))")

            # 删除docker网络信息
            docker network rm $kuryr_network_uuids >> $LOG_FILE 2>&1

            # 删除etcd中配置信息
            if [[ $? != 0 ]]; then
                etcdctl --endpoints=http://controller:2379 rm /docker/network/v1.0/network/$DOCKER_NETWORK_ID >> $LOG_FILE 2>&1
                etcdctl --endpoints=http://controller:2379 rm /docker/network/v1.0/endpoint/$DOCKER_NETWORK_ID >> $LOG_FILE 2>&1
                etcdctl --endpoints=http://controller:2379 rm /docker/network/v1.0/endpoint_count/$DOCKER_NETWORK_ID >> $LOG_FILE 2>&1
            fi
            echo "${DATE} Deleted UNLESS CONTAINER NETWORK  ${kuryr_network_uuids}" >> $LOG_FILE
        fi
    done
    echo -e "\e[1;33;42m ${DATE} Deleted UNLESS CONTAINER NETWORK complete \e[0m" >> $LOG_FILE


}

function clean_db_deleted_records(){
    echo "${DATE} Start cleaning up database records" >> $LOG_FILE
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    CURRENT_DATE=$(date "+%Y%m%d")
    DELETE_DATE=$(date -d "$CURRENT_DATE -$DELETE_DAY days" +"%Y-%m-%d")
    delta_time=1800
    # 清理nova数据库7天前已经删除记录
    echo "${DATE} Clearing the Nova Database" >> $LOG_FILE

    NOVA_START_TIMESTAMP=$(date +%s)
    while true
    do
        nova-manage db archive_deleted_rows --before $DELETE_DATE --max_rows $MAX_ROWS
        if [[ $? -eq 0 ]];then
            echo "${DATE} The Nova database is successfully cleared" >> $LOG_FILE
            break
        fi
        CURRENT_TIMESTAMP=$(date +%s)
        DELTA_TIMESTAMP=$(($CURRENT_TIMESTAMP - $NOVA_START_TIMESTAMP))
        if [ $DELTA_TIMESTAMP -gt $delta_time ];then
            echo "ERROR: ${DATE} Clearing the Nova database timed out" >> $LOG_FILE
            break
        fi
    done

    # 清理cinder数据库7天前已经删除记录
    echo "${DATE} Clearing the Cinder Database" >> $LOG_FILE
    cinder-manage db purge $DELETE_DAY
    if [[ $? -eq 0 ]];then
        echo "${DATE} The Cinder database is successfully cleared" >> $LOG_FILE
    else
        echo "ERROR: ${DATE} Failed to clear the Cinder database" >> $LOG_FILE
    fi

    # 清理glance数据库7天前已经删除记录
    echo "${DATE} Clearing the Glance Database" >> $LOG_FILE
    GLANCE_START_TIMESTAMP=$(date +%s)
    while true
    do
        glance-manage db purge --max_rows $MAX_ROWS --age_in_days $DELETE_DAY
        glance-manage db purge_images_table --max_rows $MAX_ROWS --age_in_days $DELETE_DAY
        if [[ $? -eq 0 ]];then
            echo "${DATE} The Glance database is successfully cleared" >> $LOG_FILE
            break
        fi
        CURRENT_TIMESTAMP=$(date +%s)
        DELTA_TIMESTAMP=$(($CURRENT_TIMESTAMP - $GLANCE_START_TIMESTAMP))
        if [ $DELTA_TIMESTAMP -gt $delta_time ];then
            echo "ERROR: ${DATE} Clearing the Glance database timed out" >> $LOG_FILE
            break
        fi
    done
}


function free_memory() {
    /usr/bin/sync
    echo 3 > /proc/sys/vm/drop_caches
}

function main() {
    init_log_file
    if [[ $HOSTNAME =~ "controller" ]]; then
        clean_error_instance
        clean_error_container
        clean_error_snapshot
        clean_unless_image
        clean_unless_error_volume
        clean_unless_port
        clean_unless_router
        clean_unless_network
        clean_unless_floatingip
        clean_unless_fwaas
        clean_unless_qos_policy
        clean_unless_ovs_port
        unless_portmapping
        clean_unless_container_network
        clean_db_deleted_records
        free_memory
    else
        clean_unless_ovs_port
        free_memory
    fi
}

main

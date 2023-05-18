#!/bin/bash

source /root/admin.openrc
source /etc/environment_config.conf

WORKDIR=$(cd $(dirname $0); pwd)

function modify_security_group(){
    #删除老规则:

    ruleid=$(mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME -N -e "select id from neutron.securitygrouprules where project_id in (select id from keystone.project where name='admin')")
    for rid in $ruleid
    do
        openstack security group rule delete $rid
    done

    #新增规则,分别给local与default增加：
    for grouplist in default
    do
        openstack security group rule create  --protocol icmp --ingress  --remote-ip 0.0.0.0/0  --project  admin  $grouplist
        openstack security group rule create  --protocol icmp --egress  --remote-ip 0.0.0.0/0  --project  admin   $grouplist
        openstack security group rule create  --protocol udp  --ingress --dst-port 1:65535  --remote-ip 0.0.0.0/0  --project  admin  $grouplist
        openstack security group rule create  --protocol udp  --egress  --dst-port 1:65535  --remote-ip 0.0.0.0/0  --project  admin  $grouplist
        openstack security group rule create  --protocol tcp  --ingress --dst-port 1:65535  --remote-ip 0.0.0.0/0  --project  admin  $grouplist
        openstack security group rule create  --protocol tcp  --egress  --dst-port 1:65535  --remote-ip 0.0.0.0/0  --project  admin  $grouplist
    done

}

function modify_quota(){
    openstack quota set --instances -1  --key-pairs -1 --cores -1 --ram -1 admin
    openstack quota set --injected-files -1  --injected-file-size -1 --injected-path-size -1 admin
    openstack quota set --network -1 --routers -1 --subnets -1 --port -1 --floating-ips -1 admin
    openstack quota set --volumes -1 --snapshots -1 --gigabytes -1 --per-volume-gigabytes -1 admin
}

function add_oj_ext(){
    net_id=$(openstack network list -f value -c ID --name oj_ext)
    if [ -z "$net_id" ]; then
        net_id=$(openstack network create -f value -c id --provider-network-type flat \
        --provider-physical-network provider  --availability-zone-hint nova \
        --default --share --enable --external --project admin oj_ext)
    fi
    subnet_id=$(openstack subnet list -f value -c ID --name oj_ext_subnet)
    if [[ -z $subnet_id ]];then
        openstack subnet create --dhcp --gateway  ${EX_GATEWAY} \
        --ip-version 4 --subnet-range  ${LOCAL_CIDR} --allocation-pool \
        start=${IP_POOL_START},end=${IP_POOL_END}  --network oj_ext "oj_ext_subnet"
    fi
}

function post_scripts() {
    # 屏蔽外部其他 dhcp server
    docker exec openvswitch-vswitchd ls /tmp/block_out_dhcp
    if [[ $? -ne 0 ]];then
        docker cp $WORKDIR/post_scripts/block_outer_dhcp.sh openvswitch-vswitchd:/usr/local/bin/
        docker exec openvswitch-vswitchd bash block_outer_dhcp.sh
    fi
    
    # todo
}

function post_sql() {
    if [ `mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME  -N -e "SELECT COUNT(1) FROM nova_api.flavors"` -lt 10 ] ; then
      mysql -uroot -p$MARIADB_ROOT_PASSWD -h$CONTROLLER_HOSTNAME nova_api < $WORKDIR/post_sql/flavor.sql
    fi
}




function main() {
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
            modify_security_group
            modify_quota
            add_oj_ext
            post_scripts
            post_sql
        fi
    else
        modify_security_group
        modify_quota
        add_oj_ext
        post_scripts
        post_sql
    fi
}

main
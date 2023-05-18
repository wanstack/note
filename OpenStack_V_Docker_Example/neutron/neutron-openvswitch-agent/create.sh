#!/bin/bash

set -x

source /etc/environment_config.conf

function create_bridge() {
    sudo ovs-vsctl add-br br-mirror
    sudo ovs-vsctl add-br br-vlan
    sudo ovs-vsctl add-br br-ex
    sudo ovs-vsctl add-br ovs-vpn
}

function add_port_to_bridge() {
    sudo ovs-vsctl add-port br-mirror $BR_MIRROR_INTERFACE_NAME
    sudo ovs-vsctl add-port br-ex $BR_EX_INTERFACE_NAME
    sudo ovs-vsctl add-port br-vlan $BR_VLAN_INTERFACE_NAME
}

function motify_port_to_bridge() {
    # 设置br-int网桥与br-mirror网桥相连
    sudo ip link add int-br-mirror type veth peer name mirror-br-int
    sudo ovs-vsctl add-port br-int int-br-mirror -- set interface int-br-mirror ofport_request=100
    sudo ovs-vsctl set interface  int-br-mirror type=patch
    sudo ovs-vsctl add-port br-mirror mirror-br-int  -- set interface mirror-br-int ofport_request=100
    sudo ovs-vsctl set interface mirror-br-int type=patch
    sudo ovs-vsctl set interface mirror-br-int option:peer=int-br-mirror
    sudo ovs-vsctl set interface int-br-mirror option:peer=mirror-br-int

    # 设置与br-mirror网桥相连的物理网卡固定端口号为101，固定死
    sudo ovs-vsctl set interface $BR_MIRROR_INTERFACE_NAME ofport_request=101


    # 设置ovs-vpn网桥与br-vlan网桥相连，并设置相连端口号为9400
    sudo ip link add vlan-br-vpn type veth peer name vpn-br-vlan
    sudo ovs-vsctl add-port br-vlan vlan-br-vpn -- set interface vlan-br-vpn ofport_request=9400
    sudo ovs-vsctl set interface  vlan-br-vpn type=patch
    sudo ovs-vsctl add-port ovs-vpn vpn-br-vlan  -- set interface vpn-br-vlan ofport_request=9400
    sudo ovs-vsctl set interface vpn-br-vlan type=patch
    sudo ovs-vsctl set interface vpn-br-vlan option:peer=vlan-br-vpn
    sudo ovs-vsctl set interface vlan-br-vpn option:peer=vpn-br-vlan
}

function call_motify_port_to_bridge() {
    count=1
    while ((count < 100)); do
        sudo ovs-vsctl list-br | grep br-int
        if [[ $? -eq 0 ]];then
            motify_port_to_bridge
            break
        else
            sleep 10
            ((count++))
        fi
    done

}

function main() {
    count=$(sudo ovs-vsctl list-br | grep br-ex| wc -l)
    if [[ $count -lt 1 ]];then
        create_bridge
        add_port_to_bridge
        call_motify_port_to_bridge
    fi
}

main
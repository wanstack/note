#!/bin/bash

set -x

source /etc/environment_config.conf

function del_port_from_bridge() {

    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-port $BR_MIRROR_INTERFACE_NAME
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-port $BR_EX_INTERFACE_NAME
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-port $BR_VLAN_INTERFACE_NAME
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-port int-br-vlan
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-port int-br-ex
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-port int-br-mirror
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-port mirror-br-int
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-port vlan-br-vpn
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-port vpn-br-vlan
    docker exec neutron-openvswitch-agent sudo ip link delete int-br-mirror type veth peer name mirror-br-int
    docker exec neutron-openvswitch-agent sudo ip link delete vlan-br-vpn type veth peer name vpn-br-vlan

}

function del_bridge() {
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-br br-mirror
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-br br-vlan
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-br br-ex
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-br ovs-vpn
    docker exec neutron-openvswitch-agent sudo ovs-vsctl del-br br-int

}

function del_docker_resource() {
    docker rm -f neutron-openvswitch-agent
    docker volume rm neutron-openvswitch-agent
    docker restart memcached # 创建 endpoint 时 memcached有缓存
}

function main() {
    del_port_from_bridge
    del_bridge
    del_docker_resource
}

main
#!/bin/bash

br_ex="br-ex"
ext_net_name="oj_ext"

source /etc/admin.openrc

function block_out_dhcp() {
    # 检测本地外部网络网卡
    br_ex_mac=`ip l show dev $br_ex | grep ether | awk '{print $2}'`
    if [ $? -ne 0 ]; then
      echo "Error: netif $br_ex not found."
      exit 1
    fi
    local_ext_if=`ip addr show|xargs|sed 's/ \([0-9]*: \)/\n\1/g' | grep -v $br_ex | grep $br_ex_mac | awk '{print $2}'`
    local_ext_if=${local_ext_if::-1}
    echo "get local_ext_if $local_ext_if"

    # 获取外部网络DHCP地址
    ext_net_id=`neutron net-show $ext_net_name | grep " id " | awk '{print $4}'`
    if [ $? -ne 0 ]; then
      echo "Error: network $ext_net_name not found."
      exit 1
    fi
    echo "get ext_net_id $ext_net_id"

    # 获取dhcp端口地址
    dhcp_port=`neutron port-list --network_id=$ext_net_id --device_owner="network:dhcp" | grep ip_address| awk '{print $12}'`
    if [ $? -ne 0 ]; then
      echo "Error: dhcp port for $ext_net_name not found."
      exit 1
    fi
    dhcp_addr=${dhcp_port:1}
    dhcp_addr=${dhcp_addr::-2}
    echo "get dhcp_addr $dhcp_addr"

    # 获取cookies
    cookies=`ovs-ofctl dump-flows br-ex | grep "priority=0"| grep "table=0" | grep "actions=NORMAL" | awk '{print $1}'`
    if [ $? -ne 0 ]; then
      echo "Error: dhcp port for $ext_net_name not found."
      exit 1
    fi
    echo "get cookies $cookies"

    # 检测三个变量是否都有值
    if [[ "$local_ext_if" = "" || "$dhcp_addr" = "" || "$cookies" = "" ]]; then
      echo "Error: local_ext_if or dhcp_addr get failed."
      exit 1
    fi

    # 添加流表规则,只允许外部网络的DHCP通过
    ovs-ofctl add-flow $br_ex ${cookies}priority=4,in_port=$local_ext_if,udp,nw_src=$dhcp_addr,udp_src=67,udp_dst=68,actions=NORMAL
    ovs-ofctl add-flow $br_ex ${cookies}priority=1,in_port=$local_ext_if,udp,udp_src=67,udp_dst=68,actions=drop

    echo "Done" > /tmp/block_out_dhcp
}

function main() {
    block_out_dhcp
}

main
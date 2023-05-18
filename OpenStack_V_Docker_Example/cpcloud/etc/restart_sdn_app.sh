#!/bin/bash

function check_br_int_table() {
    flag=1
    table_100=$(ovs-ofctl dump-flows br-int |grep "table=100" |grep "priority=0")
    if [[ -z $table_100 ]];then
        flag=0
    fi
    table_0=$(ovs-ofctl dump-flows br-int |grep "table=0" |grep "priority=100")
    if [[ -z $table_0 ]];then
        flag=0
    fi
    table_60=$(ovs-ofctl dump-flows br-int |grep "table=60" |grep "priority=4")
    if [[ -z $table_60 ]];then
      flag=0
    fi
    if [[ ${flag} = "0" ]];then
      /usr/local/bin/supervisorctl restart cpcloud:sdn_app
    fi
}



check_br_int_table

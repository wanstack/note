#!/bin/bash

set -x

source /root/admin.openrc
source /etc/environment_config.conf

WORKDIR=$(cd $(dirname $0); pwd)



function ssh_trust() {
    user=root
    ip=$1
    passwd=$2
    [[ -f ~/.ssh/id_rsa ]] || ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

/usr/bin/expect << EOF
set timeout 30
spawn ssh-copy-id -i /$user/.ssh/id_rsa.pub $user@$ip
expect {
    "(yes/no)" {send "yes\r"; exp_continue}
    "password:" {send "$passwd\r"}
}
expect eof
EOF
}

function main() {
    pwd="QWEasd123#"
    computes=$(cat /etc/hosts | grep compute | awk '{print $NF}')
    for compute in computes; do
        ssh_trust $compute $pwd
    done
}

main
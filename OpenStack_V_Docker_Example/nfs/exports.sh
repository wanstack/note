#!/bin/bash

set -x

source /etc/environment_config.conf

function main() {
    NFS_EXPORT_DIRS=$(compgen -A variable|grep NFS_EXPORT_DIR)
    echo 'configure-exports called!'
#    echo > /etc/exports
    for dir in $NFS_EXPORT_DIRS; do
        test -d ${!dir} || mkdir -p ${!dir}
        echo ${!dir} ${net}${opt}
#        echo ${!dir} ${net}${opt} >> /etc/exports

    done
}

main
#!/bin/bash

set -x

function start_service() {
    yum install -y python3-gobject-base.x86_64
    cd /root/modulemd-tools/
    pip3 install --no-index --prefix=/usr --find-links=/opt/pip/v gssapi
    pip3 install --no-index --prefix=/usr --find-links=/opt/pip/v -r requirements.txt
    python3 setup.py install --user
    cd -
    test -d /opt/yum/v/repodata && rm -rf /opt/yum/v/repodata
    test -f /opt/yum/v/modules.yaml && rm -rf /opt/yum/v/modules.yaml
    cd /opt/yum/v/
    createrepo ./
    /root/.local/bin/repo2module  -s stable . -n modules.yaml
    modifyrepo_c --mdtype=modules modules.yaml repodata/
    cd -
    yum clean all
    nginx -g "daemon off;"
}

function main() {
    start_service
}

main
#!/bin/bash

set -x 

source /etc/environment_config.conf

function replace_logo() {
    dest1=/usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img
    dest2=/usr/share/openstack-dashboard/static/dashboard/img
    src=/opt/img
    if [ -d $dest1 ];then
    # shellcheck disable=SC2045
        for file in $(ls ${src});do
            \cp -rp ${src}/${file} ${dest1}
            echo "copy ${src}/${file} to ${dest1}"
        done
    fi
    if [ -d $dest2 ];then
    # shellcheck disable=SC2045
        for file in $(ls ${src});do
            \cp -rp ${src}/${file} ${dest2}
            echo "copy ${src}/${file} to ${dest2}"
        done
    fi
    chown -R apache.apache /usr/share/openstack-dashboard
}

function patch() {
    patch_path=/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/instances/
    \cp -rp /opt/tabs.py $patch_path
}

function change_config() {
    mkdir -p /var/log/cpcloud/horizon/
    chmod -R 777 /var/log/cpcloud
    chown -R .cpcloud /var/log/cpcloud/horizon
    sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/httpd/conf/httpd.conf

    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /etc/yum.repos.d/cpcloud.repo
    sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
}

function install_fwaas_ui() {
    count=$(pip3 list all | grep neutron-fwaas-dashboard| wc -l)
    if [[ $count -lt 1 ]];then
        pip3 install --no-index --prefix=/usr --find-links=/opt/pip/v neutron-fwaas-dashboard
    fi
    \cp -rp /usr/lib/python3.6/site-packages/neutron_fwaas_dashboard/enabled/_* /usr/share/openstack-dashboard/openstack_dashboard/local/enabled/
}

function install_zun_ui() {
    count=$(pip3 list all | grep zun-ui | wc -l)
    if [[ $count -lt 1 ]];then
        tar -zxvf /opt/pip/v/zun-ui.tar.gz -C /tmp/
        pip3 install --no-index --prefix=/usr --find-links=/opt/pip/v zun-ui
        rm -rf /tmp/zun-ui/zun_ui/enabled/__init__.py
        \cp -rf /tmp/zun-ui/zun_ui/enabled/* /usr/share/openstack-dashboard/openstack_dashboard/local/enabled/
    fi
}

function start_service() {
    /usr/sbin/httpd -DFOREGROUND
}

function main() {
    replace_logo
    change_config
    install_fwaas_ui
    install_zun_ui
    patch
    start_service
}

main

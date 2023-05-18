#!/bin/bash

#set -x

WORKDIR=$(cd $(dirname $0); pwd)

\cp -rp $WORKDIR/environment_config.conf /etc/ > /dev/null 2>&1
ENVIRONMENT_CONFIG=/etc/environment_config.conf
source $ENVIRONMENT_CONFIG

TAG=$1
if [[ $TAG == "" ]]; then
    TAG=latest
fi
export TAG=$TAG

release=$(cat /etc/redhat-release)


function set_system() {
    groupadd --force --gid 42463 zun > /dev/null 2>&1
    useradd -l -M --shell /usr/sbin/nologin --uid 42463 --gid 42463 zun > /dev/null 2>&1
    hostnamectl set-hostname $LOCAL_HOSTNAME > /dev/null 2>&1
    hostname $LOCAL_HOSTNAME > /dev/null 2>&1
    systemctl stop firewalld > /dev/null 2>&1
    systemctl disable firewalld > /dev/null 2>&1
    setenforce 0 > /dev/null 2>&1
    sed -i 's@SELINUX=enforcing@SELINUX=disabled@g' /etc/selinux/config
    timezone=$(timedatectl show |grep -i 'Time.*zone'|awk -F'=' '{print $NF}')
    echo "${timezone}" > /etc/timezone
}

function set_env() {
    cp -rp $WORKDIR/admin.openrc /root/ > /dev/null 2>&1
    sed -ri "s@ADMIN_PASSWD@$ADMIN_PASSWD@g" /root/admin.openrc
    sed -ri "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /root/admin.openrc
    sed -ri "s@MARIADB_ROOT_PASSWORD@$MARIADB_ROOT_PASSWD@g" /root/admin.openrc
    cp -rp /root/admin.openrc /etc/ > /dev/null 2>&1
}

function install_containerd() {
    containerd config default > /etc/containerd/config.toml
    ZUN_GID=42463
    sed -i "15s/gid = .*/gid = $ZUN_GID/g" /etc/containerd/config.toml
    systemctl restart containerd
}

function config_docker() {
    if [[ $release == "CentOS Linux release 8.3.2011" ]];then
        mkdir -p /etc/systemd/system/docker.service.d
        \cp -rp $WORKDIR/zun/ssl /etc/docker/ > /dev/null 2>&1
        \cp -rp $WORKDIR/docker.conf /etc/systemd/system/docker.service.d/ > /dev/null 2>&1
        sed -i "s@LOCAL_HOSTNAME@$LOCAL_HOSTNAME@g" /etc/systemd/system/docker.service.d/docker.conf
        sed -i "s@CONTROLLER_HOSTNAME@$CONTROLLER_HOSTNAME@g" /etc/systemd/system/docker.service.d/docker.conf
        systemctl daemon-reload
        systemctl restart docker
  else
        echo "The platform is not CentOS Linux release 8.3.2011!!!"
        echo "Pls config docker"
        exit 1
    fi
}

function install_docker_compose() {
    docker-compose --version > /dev/null 2>&1
    if [[ $? -eq 0 ]];then
        echo "docker-compose is installed" > /dev/null 2>&1
    else
        if [[ $release == "CentOS Linux release 8.3.2011" ]];then
            \cp $WORKDIR/docker-compose /usr/local/bin/
            chmod +x /usr/local/bin/docker-compose
        else
            echo "The platform is not CentOS Linux release 8.3.2011!!!"
            echo "Pls config docker-compose"
            exit 1
        fi
    fi
}

function install_docker() {
    docker_count=$(rpm -qa | grep docker | wc -l)
    if [[ $docker_count -gt 1 ]];then
        echo "docker is installed."
    else
        if [[ $release == "CentOS Linux release 8.3.2011" ]];then
            yum install docker-ce -y > /dev/null 2>&1
            systemctl enable docker.socket > /dev/null 2>&1
            systemctl restart docker.socket
            systemctl daemon-reload
            systemctl enable docker > /dev/null 2>&1
            systemctl start docker
            sleep 10
            systemctl daemon-reload
            systemctl restart docker
        else
            echo "The platform is not CentOS Linux release 8.3.2011!!!"
            echo "Pls install docker and docker-compose"
            exit 1
        fi
    fi
}

function install_local_repo() {
    if [[ $release == "CentOS Linux release 8.3.2011" ]];then
        test -d /opt/yum/v || mkdir -p /opt/yum/v
        test -d /opt/pip/v || mkdir -p /opt/pip/v
        test -d /opt/pip/svcloud || mkdir -p /opt/pip/svcloud
        test -d /opt/pip/cpcloud || mkdir -p /opt/pip/cpcloud
        \cp -rp $WORKDIR/yum/v/* /opt/yum/v/ > /dev/null 2>&1
        \cp -rp $WORKDIR/pypi/pip/v/* /opt/pip/v/ > /dev/null 2>&1
        \cp -rp $WORKDIR/pypi/pip/svcloud/* /opt/pip/svcloud/ > /dev/null 2>&1
        \cp -rp $WORKDIR/pypi/pip/cpcloud/* /opt/pip/cpcloud/ > /dev/null 2>&1
        rm -rf /etc/yum.repos.d/*
        \cp -rp $WORKDIR/cpcloud_local.repo /etc/yum.repos.d/
    fi
}

function shell_replace() {
    env_config=/etc/profile
    if ! grep "docker exec tools showmount" $env_config;then
        echo "alias showmount='docker exec tools showmount'" >> $env_config
        echo "alias netstat='docker exec tools netstat'" >> $env_config
        echo "alias mysql='docker exec tools mysql'" >> $env_config
        echo "alias lsof='docker exec tools lsof'" >> $env_config
        echo "alias crudini='docker exec tools crudini'" >> $env_config
        echo "alias export_images.sh='docker exec tools export_images.sh'" >> $env_config
        echo "alias export_snapshots.sh='docker exec tools export_snapshots.sh'" >> $env_config
        echo "alias import_images.sh='docker exec tools import_images.sh'" >> $env_config
        echo "alias import_snapshots.sh='docker exec tools import_snapshots.sh'" >> $env_config
        echo "alias cryptsetup='docker exec tools cryptsetup'" >> $env_config

        source $env_config
    fi
}

function install_local_packages() {
    local_rpm_count=$(rpm -qa | egrep "python3-openstackclient|net-tools|MariaDB-client|nfs-utils" | wc -l)
    if [[ $local_rpm_count -eq 4 ]];then
        echo "python3-openstackclient net-tools MariaDB-client nfs-utils is installed."
    else
        if [[ $release == "CentOS Linux release 8.3.2011" ]];then
            yum install -y python3-openstackclient net-tools MariaDB-client nfs-utils > /dev/null 2>&1
            ln -s /usr/bin/openstack /usr/bin/cpc
        else
            echo "The platform is not CentOS Linux release 8.3.2011!!!"
            echo "Pls install python3-openstackclient"
            exit 1
        fi
    fi

    zunclient_count=$(pip3 list | grep zunclient | wc -l)
    if [[ $zunclient_count -eq 1 ]];then
        echo "python-zunclient is installed."
    else
        if [[ $release == "CentOS Linux release 8.3.2011" ]];then
            pip3 install --no-index --prefix=/usr --find-links=/opt/pip/v python-zunclient > /dev/null 2>&1
        else
            echo "The platform is not CentOS Linux release 8.3.2011!!!"
            echo "Pls install python-zunclient"
            exit 1
        fi
    fi
}

function create_docker_bridge_network() {
    DOCKER_BRIDGE_NETWORK=172.30.0.1/24
    if ! docker network inspect bridge_network &>/dev/null; then
        docker network create --driver=bridge --subnet=$DOCKER_BRIDGE_NETWORK bridge_network > /dev/null 2>&1
    fi
}

function cpcloud_host_init() {
    # bridge 网络中的容器可以访问controller 主机名

    success=true
    # shellcheck disable=SC2006
    DOCKER_BRIDGE_NETWORK=`docker network inspect -f '{{(index .IPAM.Config 0).Subnet}}' bridge_network`
    if [ -z "$DOCKER_BRIDGE_NETWORK" ]; then
        echo "DOCKER_BRIDGE_NETWORK not configured"
       return
    fi
    for i in {1..300}; do
        id=$(docker network ls | awk '$2=="bridge_network"{print $1}')
        test -n "$id" && break
    done
    if [ -z "$id" ]; then
        echo "bridge not up"
        return
    fi
    br=br-$id
    mark=1
    if ! iptables -t nat -I PREROUTING -i $br -s "$DOCKER_BRIDGE_NETWORK" -j MARK --set-mark $mark; then
        echo "iptables failed"
        success=false
    fi
    if !  iptables -t nat -I POSTROUTING ! -o $br -m mark --mark $mark -j MASQUERADE; then
        echo "iptables failed"
        success=false
    fi
    $success
}




function install_docker_repo() {
    if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
        repo=(pypi yum)
        for module in "${repo[@]}"; do
            echo "Installing $WORKDIR/$module"
            test -f $WORKDIR/$module/install.log && rm -rf $WORKDIR/$module/install.log
            bash $WORKDIR/$module/install.sh >> $WORKDIR/$module/install.log 2>&1
        done
    fi
    if [[ $release == "CentOS Linux release 8.3.2011" ]];then
        test -d /root/.pip/ || mkdir -p /root/.pip
        rm -rf /etc/yum.repos.d/*
        \cp -f $WORKDIR/base/cpcloud.repo /etc/yum.repos.d/
        \cp -f $WORKDIR/base/pip.conf /root/.pip/pip.conf
        sed -ri "s@10.100.7.56@$CONTROLLER_MANAGEMENT_IP@g" /root/.pip/pip.conf
    else
        echo "The platform is not CentOS Linux release 8.3.2011!!!"
        echo "Pls install repo"
        exit 1
    fi
}

function install() {
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
            install_modules=(chrony etcd mariadb rabbitmq memcached keystone nfs glance placement nova openvswitch \
            neutron cinder tools cron vsftpd images svcloud cpcloud nginx)
        else
            install_modules=(chrony nova openvswitch neutron images)
        fi
    else
        install_modules=(chrony etcd mariadb rabbitmq memcached keystone nfs glance placement nova openvswitch \
        neutron cinder tools cron vsftpd images svcloud cpcloud nginx)
    fi
    for module in "${install_modules[@]}"; do
        echo "Installing $WORKDIR/$module"
        test -f $WORKDIR/$module/install.log && rm -rf $WORKDIR/$module/install.log
        bash $WORKDIR/$module/install.sh >> $WORKDIR/$module/install.log 2>&1
    done
}

function install_zun() {
    echo "Installing $WORKDIR/zun"
    test -f $WORKDIR/zun/install.log && rm -rf $WORKDIR/zun/install.log
    bash $WORKDIR/zun/install.sh >> $WORKDIR/zun/install.log 2>&1
}

function install_horizon() {
    if [[ ${ALL_IN_ONE} != True ]]; then
        if [[ ${CURRENT_NODE_TYPE} =~ "controller" ]];then
            echo "Installing $WORKDIR/horizon"
            test -f $WORKDIR/horizon/install.log && rm -rf $WORKDIR/horizon/install.log
            bash $WORKDIR/horizon/install.sh >> $WORKDIR/horizon/install.log 2>&1
        fi
    else
        echo "Installing $WORKDIR/horizon"
        test -f $WORKDIR/horizon/install.log && rm -rf $WORKDIR/horizon/install.log
        bash $WORKDIR/horizon/install.sh >> $WORKDIR/horizon/install.log 2>&1
    fi
}

function post_install() {
    bash $WORKDIR/create_resource.sh >> $WORKDIR/create_resource.log 2>&1
    echo "Installing $WORKDIR/post_install"
}

function main() {
    set_system
    set_env
    install_local_repo
    install_docker
    install_docker_compose
    install_docker_repo
    install_local_packages
#    shell_replace

    create_docker_bridge_network
    cpcloud_host_init

    install

    config_docker
    install_containerd
    install_zun
    install_horizon
    
    post_install


}

main
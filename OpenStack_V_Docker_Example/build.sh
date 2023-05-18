#!/bin/bash

set -x

set -e

WORKDIR=$(cd $(dirname $0); pwd)

OPENSTACK_PACKAGES_PATH=/usr/share/nginx/html/openstack_victoria
OPENSTACK_PACKAGES_URL="http://10.100.7.30/openstack_victoria/"
PACKAGES_PATH=/home/gitlab-runner/capstone
RELEASE_PATH=/usr/share/nginx/html/capstone/
BRANCH=$1
TAG=$2
TEST=$3

release=$(cat /etc/redhat-release)

if [[ -z $TEST ]];then
    TEST=""
fi

function git_config() {
    # 删除当前目录下没有被track过的文件和文件夹
    git clean -fd
    git checkout -- '*'
}

function clean_env() {
    sudo rm -rf /home/gitlab-runner/builds/*
}

function init_env() {
    sudo chmod -R 777 /var/run/docker.sock
}



function copy_rpm_to_yum() {
    # 创建临时目录存放 openstack rpm 包
    test -d /tmp/rpm || mkdir /tmp/rpm/
    rm -rf /tmp/rpm/*

    openstack_packages=$(curl $OPENSTACK_PACKAGES_URL | awk -F "\"" '{print $2}' | egrep "rpm")
    for p in $openstack_packages; do
        wget -P /tmp/rpm/ $OPENSTACK_PACKAGES_URL$p
    done
    \cp /tmp/rpm/* $WORKDIR/yum/v/
}

function create_update_yum() {
    test -d $WORKDIR/yum/v/repodata && rm -rf $WORKDIR/yum/v/repodata
    test -f $WORKDIR/yum/v/modules.yaml && rm -rf $WORKDIR/yum/v/modules.yaml
    cd $WORKDIR/yum/v/
    sudo createrepo ./
    /usr/bin/repo2module  -s stable . -n modules.yaml
    sudo modifyrepo_c --mdtype=modules modules.yaml repodata/
    cd -
    yum clean all
}

function copy_gz_to_pypi() {
    # 创建临时目录存放 openstack tar.gz 包
    test -d /tmp/gz || mkdir /tmp/gz/
    rm -rf /tmp/gz/*

    openstack_packages=$(curl $OPENSTACK_PACKAGES_URL | awk -F "\"" '{print $2}' | egrep "tar.gz")
    for p in $openstack_packages; do
        wget -P /tmp/gz/ $OPENSTACK_PACKAGES_URL$p
    done
    \cp /tmp/gz/* $WORKDIR/pypi/pip/v/
}


function create_install_package() {
    cd $WORKDIR
    tag=$(git describe --tags --exact-match 2>/dev/null || true)
    if [ -n "$tag" ]; then
        ver=$tag
    else
        ver=$(git describe --tags 2>/dev/null || true)
        if [ -z "$ver" ]; then
            ver=$(date +%Y%m%d)-$(git log --format="%h" -n1)
        fi
    fi
    cd $WORKDIR/..
    tar --exclude=".git" --exclude=".gitlab-ci.yml" -czf capstone-$ver.tgz capstone

    echo "capstone-$ver.tgz complete"
}

function release_to_nginx() {
    cd $WORKDIR
    test -d $PACKAGES_PATH || mkdir -p $PACKAGES_PATH
    commit=$(git log --format="%H" -n1)
    commit_dir=$PACKAGES_PATH/$BRANCH/$commit

    if [ -e $commit_dir ]; then
        /bin/rm -fr $commit_dir
    fi
    cd $WORKDIR/..
    mkdir -p $commit_dir
    sudo cp capstone-$ver.tgz $commit_dir

    sudo rm -rf $RELEASE_PATH/capstone-*
    sudo test -d $RELEASE_PATH/$BRANCH || sudo mkdir -p $RELEASE_PATH/$BRANCH
    sudo rm -rf $RELEASE_PATH/$BRANCH/capstone-*
    sudo mv capstone-$ver.tgz $RELEASE_PATH/$BRANCH
    echo "capstone-$ver.tgz storage $commit_dir and $RELEASE_PATH/$BRANCH"

}

function install_docker() {
    docker_count=$(rpm -qa | grep docker | wc -l)
    if [[ $docker_count -gt 1 ]];then
        echo "docker is installed."
    else
        if [[ $release == "CentOS Linux release 8.3.2011" ]];then
            yum install docker-ce -y > /dev/null 2>&1
            systemctl enable docker.socket
            systemctl restart docker.socket
            systemctl daemon-reload
            systemctl enable docker
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

function build() {

    build_modules=(pypi yum chrony etcd mariadb rabbitmq memcached keystone nfs glance placement \
     nova openvswitch horizon neutron cinder zun tools cron vsftpd nginx)

    for module in "${build_modules[@]}"; do
        echo "Building $WORKDIR/$module"
        test -f $WORKDIR/$module/build.log && rm -rf $WORKDIR/$module/build.log
        bash $WORKDIR/$module/build.sh $TAG >> $WORKDIR/$module/build.log 2>&1
    done

    echo "Building $WORKDIR/svcloud"
    test -f $WORKDIR/svcloud/build.log && rm -rf $WORKDIR/svcloud/build.log
    bash $WORKDIR/svcloud/build.sh $BRANCH $TAG >> $WORKDIR/svcloud/build.log 2>&1

    echo "Building $WORKDIR/cpcloud"
    test -f $WORKDIR/cpcloud/build.log && rm -rf $WORKDIR/cpcloud/build.log
    bash $WORKDIR/cpcloud/build.sh $BRANCH $TAG >> $WORKDIR/cpcloud/build.log 2>&1

}

function main() {
    if [[ -n $TEST ]];then
        install_local_repo
        install_docker
        build
    else
        init_env
        git_config
        copy_rpm_to_yum
        create_update_yum
        copy_gz_to_pypi

        build

        create_install_package
        release_to_nginx
        clean_env
    fi


}

main
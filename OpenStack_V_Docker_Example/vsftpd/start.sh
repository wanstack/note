#!/bin/bash

set -x

source /etc/environment_config.conf
source /etc/admin.openrc


function install_vsftpd() {
    if [[ $(grep -c "ftp_user" /etc/passwd) -lt 1 ]] ; then
        useradd ftp_user -d /home/ftp -s /sbin/nologin
        echo ftp_password | passwd --stdin  ftp_user
        chown -R ftp_user.ftp_user /home/ftp
    fi

    sed -i "s@WEB_IP@$WEB_IP@g" /etc/vsftpd/vsftpd.conf

    echo 'ftp_user' > /etc/vsftpd/user_list
    echo 'ftp_user' >  /etc/vsftpd/chroot_list
    sed -i 's/^\(auth.*pam_shells.so\)/#\1/' /etc/pam.d/vsftpd
    test -d /home/ftp/import || mkdir /home/ftp/import -pv
    test -d /home/ftp/upgrade || mkdir /home/ftp/upgrade -pv

    chmod -R 777  /home/ftp
    mkdir -p /var/log/cpcloud/vsftpd/
}

function start_service() {
    /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
    tail -f /dev/null
}

function main() {
    install_vsftpd
    start_service
}

main

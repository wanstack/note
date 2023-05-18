#!/bin/bash
my_passwd="QWEasd123#"
export PATH=$PATH:/usr/bin:/usr/share/locale/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin

authorization(){
cd /root
cat > /tmp/scp.exp <<EOF
#!/usr/bin/expect
set timeout 60
spawn ssh-copy-id -p22 -f -i /root/.ssh/id_rsa.pub root@$1
expect {
"Are you sure you want to continue connecting (yes/no)?" { send "yes\r"; exp_continue}
"password:" { send "$my_passwd\r"; exp_continue}
}
EOF
chmod 755 /tmp/scp.exp
/tmp/scp.exp
rm /tmp/scp.exp
}


function gen_ssh_key(){
    rsa=`ls /root/.ssh | grep id_rsa.pub`
    if [ x"$rsa" = x ];then
        ssh-keygen  -t rsa -P '' -f /root/.ssh/id_rsa
        if [ -e "/root/.ssh/authorized_keys" ] ; then \cp /root/.ssh/id_rsa.pub  /root/.ssh/authorized_keys;chmod 400 /root/.ssh/authorized_keys; fi
    fi
}

function restore_backup(){
    file_flag=0 
    bfile="/opt/BACKUP_DIR/CPCLOUD_BACKUP/etc_hosts"

    if [ `grep -c 'localhost' /etc/hosts` -gt 0 ] && [ `grep -c 'controller' /etc/hosts` -gt 0 ] ; then
      if [ ! -d "/opt/BACKUP_DIR/CPCLOUD_BACKUP/" ] ; then mkdir -p /opt/BACKUP_DIR/CPCLOUD_BACKUP/ ;\cp -arp /etc/hosts  ${bfile}; fi
      if [ ! -f "${bfile}" ] || [ `md5sum ${bfile}|awk '{print $1}'` != `md5sum /etc/hosts|awk '{print $1}'` ] ; then 
         \cp -arp /etc/hosts  ${bfile}; 
         contentnew=`cat /etc/hosts`
         docker exec adaptation bash -c "echo \"$contentnew\" > /etc/hosts"
      fi
    else 
      if [ -e "$bfile" ] ; then \cp -arp  ${bfile}  /etc/hosts ;file_flag=`expr $file_flag + 1`; fi
    fi

    if [[ `hostname` =~ "controller" ]] ; then  
      if [ `grep -c 'compute' /etc/ansible/hosts` -gt 0 ] && [ `grep -c '[0-9]\.[0-9]' /etc/ansible/hosts` -gt 0 ] ; then
       echo 'pass'
      else
       if [ -e '/opt/BACKUP_DIR/CPCLOUD_BACKUP/etc_ansible_hosts' ] ; then \cp /opt/BACKUP_DIR/CPCLOUD_BACKUP/etc_ansible_hosts  /etc/ansible/hosts ;file_flag=`expr $file_flag + 1`; fi
      fi
    fi
 if [ $file_flag -gt 0 ] ; then  restart_cpcloud.sh ;fi
}


function  build_trust(){
 ips=$(cat /etc/hosts| grep -vE "localhost|^#"|grep -i 'compute'| awk '{print $1}')
 if [ -n  "$ips" ] ;then 
    for line in ${ips}
    do 
        line=`eval echo $line`
        ping -c2  $line >/dev/null
        if [ $? = 0 ] ; then
            ssh root@${line} -o PreferredAuthentications=publickey date
            if [ $? != 0 ];then
                sed -i "/${line}/d" /root/.ssh/known_hosts
                sshpass -p"$my_passwd"  ssh root@$line  "rm -rf  /root/.ssh/*"
                sshpass -p"$my_passwd"  ssh-copy-id   -i /root/.ssh/id_rsa.pub  root@$line
            fi
        fi
    done
 fi
}

function check_quota(){
 if [ $(mount -l|grep -c '/home/ftp') -gt 0 ] ;then
    echo 'pass'
 else
   if [ -e "/etc/projid" ] && [ `grep -c "myquotaproject" /etc/projid` -gt 0 ]; then
     quotasize=$(xfs_quota -x -c "report -p" /|awk '/myquotaproject/{print $3}')
     if [ $quotasize -lt 200000000 ] ; then 
       xfs_quota -x -c "limit -p  bsoft=200G  bhard=200G myquotaproject"  /   >/dev/null 2>&1
     else
       echo "no need modify"
     fi
   fi
 fi
}

function check_quota_file_cfg(){
 if [ -f "/etc/logsize_limit.conf" ] ; then
    while read line
    do
       if [[ `echo "$line"|grep -c "^/[a-zA-Z].*=[0-9]"` -gt 0 ]] ; then
           path=`echo $line |awk -F'=' '{print $1}'`
           if [ ! -d "$path" ] ; then continue ; fi
           size=`echo $line |awk -F'=' '{print $2}'`
           quotaname=$(echo "$path" |sed "s;/;_;g" |sed "s;^_;;")
           num=$(grep "^[a-zA-Z].*[a-zA-Z]:[0-9]" /etc/projid|tail -n1|awk -F':' '{print $2}')
           size=`eval echo $size`; if [ x"$size" = x ] ;then continue; fi
           num=`eval echo $num` ;  if [ x"$num" = x ] ; then num=11 ;  fi
           cnum=`expr $num + 1`
	       
           if [ `grep -c "$path" /etc/projects` -lt 1 ] ; then  echo "${cnum}:${path}" >> /etc/projects ;fi
           if [ `grep -c "${quotaname}:" /etc/projid` -lt 1 ] ; then echo "${quotaname}:${cnum}" >> /etc/projid;fi
           xfs_quota -x -c "project -s ${quotaname}" >/dev/null 2>&1 
           xfs_quota -x -c "limit -p  bsoft=${size}  bhard=${size}  ${quotaname}"  /   >/dev/null 2>&1
       fi
    done</etc/logsize_limit.conf
    xfs_quota -x -c "report -p" /
 fi
}

function  manage_ansible_hosts(){
    cat /etc/hosts| grep -v -E "^#|localhost"|grep 'compute'| awk '{print $1}' | while read ip; do
        if grep -qx $ip /etc/ansible/hosts; then
            continue
        else
            echo $ip >> /etc/ansible/hosts
        fi
    done
    
    if grep -c 'compute'  /etc/hosts ; then
      #sed -i '/^$/d'  /etc/ansible/hosts
      ansible compute -m command -a "systemctl restart chronyd" >/dev/null 2>&1
      sleep 5
    fi

    if [[ `hostname` =~ 'compute' ]] ;then 
       systemctl restart chronyd ; sleep 5
    fi
}

function check_rabbitmq_container(){

  if [ -e "/opt/docker_build/net-tools_amd64.deb" ] && [ `docker ps |grep -c 'rabbitmq'` -gt 0 ] ;then
     docker cp /opt/docker_build/net-tools_amd64.deb   rabbitmq:/home
     docker exec  rabbitmq  sh -c 'dpkg  -i  /home/net-tools_amd64.deb'
      
     if [ `docker exec rabbitmq sh -c "netstat -antp|grep -i listen|grep -c ':5672'"` -gt 0 ] ; then 
        echo "rabbitmq running OK"
     else
        docker restart  rabbitmq
     fi
  fi
  
}

function restart_compute(){
  if [ -f "/tmp/reboot_now" ] ; then
    if [ `grep -ic 'compute' /etc/hosts` -gt 0 ] ; then
       if [ `netstat -antp | grep ':5672'|grep -ic listen` -gt 0 ] ; then
         sleep 20; ansible compute -m shell -a "restart_cpcloud.sh"
         rm -rf   /tmp/reboot_now
       fi
    fi
  fi
}

function check_office_status(){
  source /root/admin.openrc; office=$(openstack server list -f value|grep -i office|head -n1|awk '{print $1,$2,$3}') ; office=`eval echo $office`
  if [ -n "$office" ] && [[ ! "$office" =~ 'ACTIVE' ]] ; then officeid=`echo $office|awk '{print $1}'`;openstack server start ${officeid}; fi
}

if [[ `hostname` =~ 'controller' ]] ; then
   gen_ssh_key
   restore_backup
   build_trust
   manage_ansible_hosts
   check_quota_file_cfg
   restart_compute

   chown ftp_user:ftp_user /home/ftp
   check_office_status
   #check_quota
   #check_rabbitmq_container
elif [[ `hostname` =~ 'compute' ]] ; then
   restore_backup
   check_quota_file_cfg
fi

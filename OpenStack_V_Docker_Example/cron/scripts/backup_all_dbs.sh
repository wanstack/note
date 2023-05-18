#!/bin/bash
backdir="/opt/BACKUP_DIR/CPCLOUD_BACKUP"
backdir_app="/opt/BACKUP_DIR/APP_BACKUP"
backdir_vul="/opt/BACKUP_DIR/VUL_BACKUP"

export PATH=$PATH:/usr/bin:/usr/share/locale/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin

#只允许在controller节点执行：
if [[ ! `hostname` =~ 'controller' ]] ; then  echo 'Not controller node!!';sleep 3;exit 1;fi

#删除数据库多余数据
    nova_USER=$(cat /etc/nova/nova.conf| grep "pymysql"|grep -i 'connection'|head -n1|sed -r "s/.*:\/\/(.*):(.*)@.*/\1/g")
    nova_PASSWORD=$(cat /etc/nova/nova.conf| grep "pymysql"|grep -i 'connection'|head -n1|sed -r "s/.*:\/\/(.*):(.*)@.*/\2/g")
    mysql -hcontroller -u${nova_USER} -p${nova_PASSWORD} -e "delete from nova_api.allocations where consumer_id not in (select uuid from nova.instances where deleted_at is NULL union select uuid from nova_cell0.instances where deleted_at is NULL);"
    
#清理内存
    sync; echo 3 > /proc/sys/vm/drop_caches 
    
#清理缓存
    echo  "flush_all" |nc  `hostname` 11211     

#各个计算节点时间同步
 if [ `grep -c 'compute' /etc/hosts` -gt 0 ] ; then 
    now_time=`date +"%Y-%m-%d\ %H:%M:%S"`
    ansible compute -m command -a "date -s $now_time" >/dev/null
    ansible compute -m command -a "systemctl restart chronyd">/dev/null
    sleep 5
    ansible compute -m command -a "hwclock -w">/dev/null
 fi
#############备份/etc/hosts 和 /etc/ansible/hosts###############
  if [ ! -d "$backdir" ] ; then mkdir  -p  $backdir  ;fi
  
  if [ `grep -c 'localhost' /etc/hosts` -gt 0 ] && [ `grep -c controller /etc/hosts` -gt 0 ] ; then
    \cp  -r /etc/hosts   $backdir/etc_hosts
  fi
  if [ `grep -c 'compute' /etc/ansible/hosts` -gt 0 ] && [ `grep -c '[0-9]\.[0-9]' /etc/ansible/hosts` -gt 0 ] ; then
    \cp  -r  /etc/ansible/hosts   $backdir/etc_ansible_hosts
  fi 
#############备份openstack数据库#################################
#############数据库备份5天以内##################################
  #dbs=(nova nova_api nova_cell0 zun neutron keystone glance cinder)
  date=$(date +'%Y%m%d_%H%M')
function backup_cpcloud_dbs(){
  #获取所有数据库清单:
  databasecps=$(mysql -N -e 'show databases' | grep '' | xargs)
  databasecps=(${databasecps[*]/information_schema})
  databasecps=(${databasecps[*]/performance_schema})
#  databasecps=(${databasecps[*]/mysql})

  for i in  ${databasecps[*]} ; do
      echo "$i"
      mysqldump ${i} > ${backdir}/${i}_${date}.sql
      nums=`ls -lt $backdir/${i}_2[0123]*|wc  -l`   #查看备份的天数
      let sur=${nums}-5
      if [ $sur -gt 0 ] ; then    #如果大于5天就清理老的
          ls -t ${backdir}/${i}_2[0123]*| tail -n${sur}|xargs rm -rf
      fi 
  done

  \cp -ra  /var/lib/mysql   ${backdir}/var_lib_mysql_${date}
  numls=`echo  $backdir/var_lib_mysql_2[0123]*|wc  -w`   #查看备份的天数
  let surl=${numls}-3
  if [ $surl -gt 0 ] ; then    #如果大于3天就清理老的 
      ls -tr ${backdir}|grep "var_lib_mysql_2[0123]"|tail -n${surl} |xargs -I {} rm -rf ${backdir}/{}
  fi
}  
################备份业务数据库#######################  
##############数据库备份5天以内####################
function backup_app_dbs(){
    if [ ! -d "$backdir_app" ] ; then mkdir -p $backdir_app ;fi
    
    db_host=$(awk '/controller/{print $1}' /etc/hosts)
    if [ -z "$db_host" ] || [ `echo $db_host|wc -w` -gt 1 ] ; then  db_host=$(hostname) ; fi
    db_port=$(docker port mariadb 3306 | cut -d ":" -f2)
    db_root_pass=$(docker exec mariadb env | grep MYSQL_ROOT_PASSWORD | cut -d "=" -f2)
    db_root_pass=`eval echo $db_root_pass`
    
    databases=$(mysql -h$db_host -P$db_port -uroot -p$db_root_pass -N -e 'show databases' | grep '' | xargs)
    databases=(${databases[*]/information_schema})
    databases=(${databases[*]/performance_schema})
#    databases=(${databases[*]/mysql})
    for database in ${databases[*]} ; do
      echo "$database"
      mysqldump -h$db_host -P$db_port -uroot -p$db_root_pass $database > ${backdir_app}/${database}_${date}.sql
      nums=`ls -lt  $backdir_app/${database}_2[0123]*|wc  -l`   #查看备份的天数
      let sur=${nums}-5
      if [ $sur -gt 0 ] ; then    #如果大于5天就清理老的
          ls -t ${backdir_app}/${database}_2[0123]*| tail -n${sur}|xargs rm -rf
      fi
    done
}
################备份vuln_mariadb数据库#######################
##############数据库备份3天以内####################
function backup_vuln_dbs(){
    if [ ! -d "$backdir_vul" ] ; then mkdir -p $backdir_vul; fi

    db_host=$(awk '/controller/{print $1}' /etc/hosts)
    if [ -z "$db_host" ] || [ `echo $db_host|wc -w` -gt 1 ] ; then  db_host=$(hostname) ; fi
    db_port=$(docker port vuln_mariadb 3306 | cut -d ":" -f2)
    db_root_pass=$(docker exec vuln_mariadb env | grep MYSQL_ROOT_PASSWORD | cut -d "=" -f2)
    db_root_pass=`eval echo $db_root_pass`

    echo "mysql -h$db_host -P$db_port -uroot -p$db_root_pass -N -e 'show databases' | grep '' | xargs"
    adatabases=$(mysql -h$db_host -P$db_port -uroot -p$db_root_pass -N -e 'show databases' | grep '' | xargs)
    adatabases=(${adatabases[*]/information_schema})
    adatabases=(${adatabases[*]/performance_schema})
#    adatabases=(${adatabases[*]/mysql})
    echo "$adatabases"
    for database in ${adatabases[*]} ; do
      echo "$database  ==="
      mysqldump -h$db_host -P$db_port -uroot -p$db_root_pass $database > ${backdir_vul}/${database}_${date}.sql
      nums=`ls -lt  ${backdir_vul}/${database}_2[0123]*|wc  -l`   #查看备份的天数
      let sur=${nums}-3
      if [ $sur -gt 0 ] ; then    #如果大于3天就清理老的
          ls -t ${backdir_vul}/${database}_2[0123]*| tail -n${sur}|xargs rm -rf
      fi
    done
}

#
function  failed_builds_count(){
fhosts=$( mysql -N -e "SELECT T.host  FROM nova.compute_nodes A,nova.services T WHERE A.deleted=0 AND T.binary LIKE 'nova-compute' AND T.disabled=0 AND A.stats NOT LIKE '%failed_builds\": \"0%' AND T.host=A.hypervisor_hostname ;")
fhosts=`eval echo $fhosts`

NetworkID=`mysql -N -e "SELECT N.id FROM neutron.networks N WHERE N.name='oj_ext' AND N.status='ACTIVE';"`
NetworkID=`eval echo $NetworkID`

if [ -n "$fhosts" ] ; then
  for node in $fhosts
  do
      flag=0
      ntime=`date`
      ping  -c4   $node >/dev/null  2>&1
      if [ $? != 0 ] ; then
          #ping不通 记录日志
          echo "$ntime [ERROR]Test ping $node failed" | tee -a /var/log/messages
      else
          #能ping通的情况下，先重启一下服务:
          ssh root@$node "restart_cpcloud.sh"  >/dev/null  2>&1
          sleep 60
          #查询服务状态:
          source  /root/admin.openrc
          #nova 服务是否正常
          if [ `openstack compute service list  -f value -c  Host -c Status -c State | grep -ic "$node enabled up"` -lt 1 ] ; then 
               echo "$ntime [ERROR]$node nova service-list service abnormal" | tee -a /var/log/messages ; flag=1
          fi
          #neutron是否正常:
          if [ `openstack network agent list -f value -c Host -c Alive -c State | grep -ic "$node True True"` -lt 1 ] ; then 
              echo "$ntime [ERROR]$node neutron agent-list service abnormal" | tee -a /var/log/messages; flag=1
          fi
          #zun服务是否正常
          if [ `openstack appcontainer service list -f value -c Host -c State -c Disabled|grep -ic "$node up False"` -lt 1 ] ; then 
              echo "$ntime [ERROR]$node zun service-list service abnormal" | tee -a /var/log/messages; flag=1
          fi

          #查看剩余资源：物理内存+硬盘:
          freemem=$(ssh root@${node} "cat /proc/meminfo"|grep -i 'MemFree'|awk '{print $2}') #单位:k  不能小于5G(5242880k)
          freemem=`eval echo $freemem`
          freedisk=$(ssh root@${node} "stat -f /"|grep -iE 'Blocks.*Free'|sed "s/Blocks.*Free://"|sed "s/Available:.*$//")  #get block num*4 = k
          freedisk=`eval echo $freedisk`
          freedisk2=`expr $freedisk \* 4`
          
          if [ ${freemem} -lt 5242880 ] ;then echo "$ntime [ERROR]$node Not much memory left: $freemem kB" | tee -a /var/log/messages; flag=1; fi
          if [ ${freedisk2} -lt 52428800 ] ;then echo "$ntime [ERROR]$node Not much disk left: $freedisk2 kB" | tee -a /var/log/messages; flag=1; fi
         
          #查看openstack资源利用:
          openstack hypervisor show ${node} -f shell > /tmp/linshi_hypervisor_info
          source  /tmp/linshi_hypervisor_info  >/dev/null
          if [ $free_ram_mb -lt 5120 ] ; then  echo "$ntime [ERROR]$node Not much memory left: $freemem kB" | tee -a /var/log/messages; flag=1; fi
          if [ $free_disk_gb -lt 50 ] ; then echo "$ntime [ERROR]$node Not much disk left: $free_disk_gb gB" | tee -a /var/log/messages; flag=1; fi 
          vcpusused=`eval echo $vcpus`
          all_vcpu=`expr $vcpusused \* 2`
          available_cpu=`expr $vcpusused - $vcpus_used`
          if [ $available_cpu -lt 5 ] ; then echo "$ntime [ERROR]$node Not much vcpu left, available cpu: $available_cpu" | tee -a /var/log/messages; flag=1; fi 
          
          #如果资源足够尝试启动一次: 
          image=`openstack image list |grep -c 'tgn-trex'`
          flavor=`openstack flavor list|grep -c 'm4.4c-8192m-40g'`
          if [ $flag = 0 ] && [ -n "$NetworkID" ] && [ $image -gt 0 ] && [ $flavor -gt 0 ]; then 
             nova boot --image tgn-trex --flavor m4.4c-8192m-40g --security-groups default --nic net-id=${NetworkID} --availability-zone nova:${node} tteestt0011
             #暂停300秒,启动成功则删除虚拟机
             sleep 300; if [ `openstack server list|grep 'tteestt0011'|grep -c 'ACTIVE'` -lt 1 ] ; then  sleep 200 ;fi
             nova delete tteestt0011
          fi  
      fi
  done
fi
}

mysql -e "show databases";
if [ $? = 0 ] ; then  backup_cpcloud_dbs ; fi 

db_port=$(docker port mariadb 3306 | cut -d ":" -f2)
db_port=`eval echo $db_port`
if [ -n "$db_port" ] ; then  backup_app_dbs ; fi 

vdb_port=$(docker port vuln_mariadb 3306 | cut -d ":" -f2)
vdb_port=`eval echo $vdb_port`
if [ -n "$vdb_port" ] ; then  backup_vuln_dbs ; fi 

failed_builds_count

#if [ -f '/home/tmpinstallusr/11_modify_root_password.sh' ] ; then 
#  sh  /home/tmpinstallusr/11_modify_root_password.sh
#elif [ -f '/opt/BACKUP_DIR/home/tmpinstallusr/11_modify_root_password.sh' ] ; then 
#  sh  /opt/BACKUP_DIR/home/tmpinstallusr/11_modify_root_password.sh
#fi

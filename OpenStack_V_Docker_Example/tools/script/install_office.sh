#!/bin/bash
source  /root/admin.openrc
source /etc/environment_config.conf
set -x
#创建主机类型:
mysql -uroot -hcontroller -p${MARIADB_ROOT_PASSWD} -e "INSERT INTO nova_api.flavors VALUES ('2022-02-15 02:37:51',NULL,'office_f',55,16384,8,0,NULL,'6a90840d-93d4-4320-bf96-815a814596cf',1,500,0,0,1,NULL);" >/dev/null 2>&1

function wait(){
      sleep 10
      if [ `openstack server list|grep -c "office"` -lt 1 ] ;then
          echo "Create office failed..."; exit 1
      fi
      while true
      do
         if [ `openstack server list|grep "office"|grep -c "ACTIVE"` -lt 1 ] ;then
           echo -n '.'; sleep 10;continue
         else
           sleep 25; echo "create office virtual machine finished!"
           break
         fi
      done
}

if [ -e "/homt/ftp/office_snap.tgz" ] ; then
   echo 'import office snapshot...'
   rm  -rf  /homt/ftp/office_snap
   if [ `openstack volume snapshot list -f value -c ID -c Name|grep -c 'office_snap'` -lt 1 ] ; then
      tar  -xf  /homt/ftp/office_snap.tgz  -C   /homt/ftp/
      /usr/local/bin/import_snapshots.sh   /homt/ftp/office_snap
   fi

    #创建虚拟机:
    echo 'create office virtual machine...'
    net_id=`openstack network list -f value|grep 'oj_ext'|awk '{print $1}'`
    volume_snapshotID=`openstack volume snapshot list -f value -c ID -c Name|grep 'office_snap'|awk '{print $1}'`
    if [ -n "$volume_snapshotID" ] && [ -n "$net_id" ] ;then echo ''; else echo 'Can not find snapshotID or netID';exit 1 ;fi
    offvm=`openstack server list|grep "office"|grep -c "ACTIVE"`
    if [ $offvm -lt 1 ] ; then
      nova boot --snapshot ${volume_snapshotID} --flavor office_f --security-groups default --nic net-id=${net_id} --availability-zone nova:controller  office
      wait
    else
      echo "[OK]officevm already exist!"
    fi
elif [ -e "/homt/ftp/office.vmdk" ] ;then
    flag=`openstack image list|grep office |grep -ic 'active'`
    if [ $flag -lt 1 ] ;then
      openstack image create --property hw_disk_bus=ide --container-format bare --disk-format qcow2 --file /homt/ftp/office.vmdk  office
      sleep 10
    fi

    if [ `openstack image list|grep -i 'active'|grep -c 'office'` -lt 1 ] ;then
        echo "[ERROR]office.vmdk import failed!!";exit 1;
    fi

    #创建虚拟机:
    sudo echo 'create office virtual machine...'
    net_id=`openstack network list -f value|grep 'oj_ext'|awk '{print $1}'`
    offvm=`openstack server list|grep "office"|grep -c "ACTIVE"`
    if [ $offvm -lt 1 ] ; then
      nova boot --image office --flavor office_f --security-groups default --nic net-id=${net_id} --availability-zone nova:controller  office
      wait
    else
      echo "[OK]officevm already exist!"
    fi
else
    echo "[ERROR]cat not find office.vmdk  or office_snap.tgz "
    exit 1
fi


#关闭控制节点计算服务:
if [ "$AllInOne" == "False" ] ; then
  if [ `grep -c "compute" /etc/hosts` -lt 1 ] ; then echo "No compute nodes available! install compute node first,or you may no execute 5 checkstatus" ;exit 1; fi
fi

if [ "$AllInOne" == "False" ] ; then
  flag1=`nova service-list|grep 'nova-compute'|grep 'controller'|grep -c 'enabled'`
  if [ $flag1 -gt 0 ] ; then
    echo  "close controller nova..."
    nova_compute_id=`nova service-list --host controller --binary  nova-compute |grep -Ev 'Binary|----'|awk -F'|' '{print $2}'`
    nova service-disable  $nova_compute_id
  fi
fi

#获取虚拟机信息:
echo -n "The office virtual machine is starting."
office_IP=`openstack server list -c Name -c Status -c Networks  -f value|grep 'ACTIVE'|grep "office"|awk -F'=' '{print $2}'`
office_IP=`eval echo $office_IP`
if [ ! -n "$office_IP" ] ;then  echo "office vm has no IP";exit 1;  fi
while true
do
  if [ `ping -c2 $office_IP|grep -c '0 received'` -gt 0 ] ; then
    sleep 10;echo -n '.';continue
  else
    break
  fi
done
test -e /home/tmpinstallusr/firstlineconfig ||  touch /home/tmpinstallusr/firstlineconfig
test -e /home/tmpinstallusr/officevnc || touch /home/tmpinstallusr/officevnc
clear; echo '';echo '';echo ''
sed -i '/office_IP=/d'  /home/tmpinstallusr/firstlineconfig
echo "office_IP=$office_IP" >> /home/tmpinstallusr/firstlineconfig
echo '==================================================='
echo "[Finished]RDP login and modify office information!!!"
echo "office IP is：$office_IP  user:administrator  password:ycxx123#"
echo '===================VNC URL========================='
nova get-vnc-console office  novnc >/home/tmpinstallusr/officevnc
echo  "office_VM_IP=$office_IP" >> /home/tmpinstallusr/officevnc
echo  '---------------------------------------------------------------------------------------------------' >>/home/tmpinstallusr/officevnc
cat /home/tmpinstallusr/officevnc
echo '==================================================='
echo 'Continue after 20 seconds!'; sleep  20

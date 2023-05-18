
### 1 项目说明:
#### 1.1 项目目录说明
- base: 制作 openstack-base 基础镜像目录
- chrony: 时间同步服务
- etcd: 云平台 etcd 服务
- mariadb: 数据库（云平台、中台、应用公用）服务
- rabbitmq: 消息队列（云平台、中台、应用公用）服务
- memcached: 云平台 memcached 服务
- keystone: 云平台 keystone 服务
- nfs: 共享存储服务
- glance: 云平台 glance 服务目录
- placement: 云平台placement 服务
- nova: 云平台 nova 服务 
- openvswitch: 云平台 openvswitch服务
- neutron: 云平台 neutron 服务
- cinder: 云平台 cinder 服务
- tools: 工具包括导入镜像脚本等外部脚本, 控制节点宿主机: /opt/images/ 上传镜像目录
- cron: 定时任务服务
- vsftpd: ftp服务器
- images: 外部镜像导入
- svcloud: 云平台 svcloud 服务
- cpcloud: 云平台 cpcloud 服务
- nginx: 云平台 nginx 反向代理服务
- zun: 云平台 zun 服务
- horizon: 云平台 horizon 服务
- post_sql: 存放需要被执行的 sql 文件
- post_script: 云平台安装完成后需要执行的脚本
- .gitlab-ci.yml: gitlab 打包文件
- create_resource.sh: 云平台安装完成后创建资源文件，例如: ob_ext 外部网络, 默认安全组规则等

#### 1.2 项目子目录说明 
- build.sh 根据 Dockerfile 打包成镜像脚本, 镜像存放在每个子项目目录中
- docker-compose.yml 使用 docker-compose 根据镜像启动成容器
- Dockerfile 根据 openstack-base 镜像(此镜像根据CentOS8.3.2011制作)制作服务镜像
- install.sh 根据docker-compose.yml 文件启动容器
- start.sh 容器启动后在容器中执行的脚本
- unbuild.sh 删除镜像脚本
- uninstall.sh 卸载脚本
- openstack-xxx logrotate 日志分割配置文件
- create.sh 容器中 start.sh 脚本执行完成后, 相关服务启动完成后执行create.sh 脚本, 主要创建相关资源
- /var/log/cpcloud 为容器日志路径
- /etc/cpcloud 为容器配置文件路径
- /var/lib/docker/volumes/nova-compute-shared/_data/instances 虚拟机文件
- /data 目录为nfs 共享目录
#### 1.3 未解决的问题:
- horizon 项目目前只支持英文

#### 1.4 docker-compose 版本
docker-compose version 1.29.2, build 5becea4c


### 2. 安装配置

#### 2.1 安装前宿主机资源准备
```shell script
网络接口: 控制和计算节点至少需要4个网络接口, 可以为 5张网卡
WEB_IP: WEB 访问接口，可以对云平台之外通信, 可以和 BR_MANAGER_INTERFACE_NAME 进行合并
BR_EX_INTERFACE_NAME: br-ex 接口，和 WEB_IP 不同，不能用于 ssh 管理，否则安装过程会断开ssh连接，导致安装失败
BR_MANAGER_INTERFACE_NAME: LOCAL_IP 网卡名称，如下面的 192.168.7.50 主用于云平台之间通信，不对云平台之外通信
BR_MIRROR_INTERFACE_NAME: br-mirror桥接物理接口
BR_VLAN_INTERFACE_NAME: br-vlan 桥接物理接口

CPU:
控制节点预留 8 核心，宿主机内存必须大于 8 核心
计算节点预留 8 核心，宿主机内存必须大于 8 核心

内存:
控制节点预留 65536MB 内存，宿主机内存必须大于 65536MB 内存
计算节点预留 20484MB 内存，宿主机内存必须大于 20484MB 内存

硬盘:
控制节点预留 100GB 硬盘，宿主机内存必须大于 100GB 硬盘
计算节点预留 100GB 硬盘，宿主机内存必须大于 100GB 硬盘
```

#### 2.2 安装说明
- 1. 宿主机 docker 挂载路径为 /var/lib/docker 建议单独划分一个磁盘分区, 进行单独挂载, 防止出现容器磁盘沾满影响宿主机正常使用。
例如:
```shell script
[root@controller ~]# cat /etc/fstab 
...
/dev/sdb /var/lib/docker xfs defaults 0 0
```

- 2. 宿主机非 CentOS8.3 操作系统, docker 服务和 python3-openstackclient、net-tools、MariaDB-client、nfs-utils 需要自行安装并且配置,然后执行脚本, 否则脚本错误退出。


#### 2.3 所有节点配置
```shell script
### 所有节点配置
```shell script
# 1. 下载tar rpm包并且安装 curl -O http://10.100.7.30/installer/tar-1.30-5.el8.x86_64.rpm
rpm -ivh tar-1.30-5.el8.x86_64.rpm
# 1.2 下载文件 
curl -O  http://10.100.7.30/capstone/develop/capstone-20230106-f0cf939.tgz --output capstone-20230106-f0cf939.tgz

# 2. 控制节点添加/etc/hosts主机解析：
vim /etc/hosts

127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

10.100.7.50 controller
10.100.7.51 compute51
```

#### 2.4 安装配置控制节点
```shell script
# 说明: 不管是控制节点还是计算节点安装, 除了web网卡之外，其他网卡均不能配置网关
# 1. 修改配置文件
## 当前节点类型,controller,node,network,cinder
CURRENT_NODE_TYPE="controller"

## 集群是否为all-in-one,选填True/False
ALL_IN_ONE=False

## 控制节点主机名
CONTROLLER_HOSTNAME="controller"
## 本机主机名
LOCAL_HOSTNAME="controller"

## WEB访问地址
WEB_IP="10.100.7.50"

## 用于主机解析，云平台API内部调用
LOCAL_IP="10.100.7.50"

## br-ex 与 WEB_IP 不同
BR_EX_INTERFACE_NAME="ens192"

EX_GATEWAY="10.100.7.254"
LOCAL_CIDR="10.100.7.0/24"
IP_POOL_START="10.100.7.203"
IP_POOL_END="10.100.7.240"

## LOCAL_IP 网卡名称
BR_MANAGER_INTERFACE_NAME="ens161"

## br-mirror
BR_MIRROR_INTERFACE_NAME="ens224"

## br-vlan
BR_VLAN_INTERFACE_NAME="ens256"

## chrony允许通过的网段,如果有多个网段中间用空格分割,默认允许所有,例如:ALLOW_CHRONY_NETWORKS="10.99.99.0/24"
ALLOW_CHRONY_NETWORKS="192.168.7.0/24"

## 控制节点管理段IP地址,即控制节点与各个计算节点、存储节点、网络节点相互通信的地址
CONTROLLER_MANAGEMENT_IP="192.168.7.50"

## 快速配置用户/密码
QUICK_CONF_USER="woodpecker"
QUICK_CONF_PASS="woodpecker"

## rabbitmq用户与密码
## RABBITMQ_USER_old="openstack"
RABBITMQ_USER="cpcloud"
RABBITMQ_PASSWD=ODg5YmVjOWU0MWU

## Mariadb服务的root密码
MARIADB_ROOT_PASSWD=iAdBLsIQx4qSpVN

MARIADB_CRDBUSER_PASS=iAdBLsIQx4qSpVN

## admin用户密码
ADMIN_PASSWD=YWNkMGFjNDIwMzl

## keystone服务密码
KEYSTONE_PASSWD="keystone888"

## glance服务密码
GLANCE_PASSWD="glance888"

## placement服务密码
PLACEMENT_PASSWD="placement888"

## nova服务密码
NOVA_PASSWD="nova888"

## neutron服务密码
NEUTRON_PASSWD="neutron888"

## metadata密码
METADATA_PASSWD="metadata888"

## kuryr-libnetwork密码
KURYR_LIBNETWORK_PASSWD="kuryr888"

## zun服务密码
ZUN_PASSWD="zun888"

## cinder服务密码
CINDER_PASSWD="cinder888"

##
REGISTRY_PASS="fRdieLMnv4Sm"
#######是否开启https#######
ENABLE_HTTPS=FALSE

#######后端存储,CEPH,NFS,LOCAL
BAKEND_STORAGE="CEPH"
TIMEZONE="Asia/Shanghai"

## ops账号密码, echo 'eWN4eDEyMyMK' | base64 -di 获取原始密码
OPS_PASS_BASE64="eWN4eDEyMyMK"




nohup bash install.sh >> install.log 2>&1 &
```

#### 2.5 安装配置计算节点
```shell script
# 1. 修改environment_config.conf
## 当前节点类型,controller,node,network,cinder
CURRENT_NODE_TYPE="node"

## 集群是否为all-in-one,选填True/False
ALL_IN_ONE=False

## 控制节点主机名
CONTROLLER_HOSTNAME="controller"
## 本机主机名
LOCAL_HOSTNAME="compute51"

## WEB访问地址
WEB_IP="10.100.7.50"

## 用于主机解析，云平台API内部调用
LOCAL_IP="10.100.7.50"

## br-ex 与 WEB_IP 不同
BR_EX_INTERFACE_NAME="ens192"

EX_GATEWAY="10.100.7.254"
LOCAL_CIDR="10.100.7.0/24"
IP_POOL_START="10.100.7.203"
IP_POOL_END="10.100.7.240"

## LOCAL_IP 网卡名称
BR_MANAGER_INTERFACE_NAME="ens161"

## br-mirror
BR_MIRROR_INTERFACE_NAME="ens224"

## br-vlan
BR_VLAN_INTERFACE_NAME="ens256"

## chrony允许通过的网段,如果有多个网段中间用空格分割,默认允许所有,例如:ALLOW_CHRONY_NETWORKS="10.99.99.0/24"
ALLOW_CHRONY_NETWORKS="192.168.7.0/24"

## 控制节点管理段IP地址,即控制节点与各个计算节点、存储节点、网络节点相互通信的地址
CONTROLLER_MANAGEMENT_IP="192.168.7.50"

## 快速配置用户/密码
QUICK_CONF_USER="woodpecker"
QUICK_CONF_PASS="woodpecker"

## rabbitmq用户与密码
## RABBITMQ_USER_old="openstack"
RABBITMQ_USER="cpcloud"
RABBITMQ_PASSWD=ODg5YmVjOWU0MWU

## Mariadb服务的root密码
MARIADB_ROOT_PASSWD=iAdBLsIQx4qSpVN

MARIADB_CRDBUSER_PASS=iAdBLsIQx4qSpVN

## admin用户密码
ADMIN_PASSWD=YWNkMGFjNDIwMzl

## keystone服务密码
KEYSTONE_PASSWD="keystone888"

## glance服务密码
GLANCE_PASSWD="glance888"

## placement服务密码
PLACEMENT_PASSWD="placement888"

## nova服务密码
NOVA_PASSWD="nova888"

## neutron服务密码
NEUTRON_PASSWD="neutron888"

## metadata密码
METADATA_PASSWD="metadata888"

## kuryr-libnetwork密码
KURYR_LIBNETWORK_PASSWD="kuryr888"

## zun服务密码
ZUN_PASSWD="zun888"

## cinder服务密码
CINDER_PASSWD="cinder888"

##
REGISTRY_PASS="fRdieLMnv4Sm"
#######是否开启https#######
ENABLE_HTTPS=FALSE

#######后端存储,CEPH,NFS,LOCAL
BAKEND_STORAGE="CEPH"
TIMEZONE="Asia/Shanghai"

## ops账号密码, echo 'eWN4eDEyMyMK' | base64 -di 获取原始密码
OPS_PASS_BASE64="eWN4eDEyMyMK"




nohup bash install.sh >> install.log 2>&1 & 
```



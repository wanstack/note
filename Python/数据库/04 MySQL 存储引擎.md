[toc]

# 基础知识

在关系型数据库中每一个数据表相当于一个文件，而不同的存储引擎则会构建出不同的表类型。

存储引擎的作用是规定数据表如何存储数据，如何为存储的数据建立索引以及如何支持更新、查询等技术的实现。

在`Oracle`以及`SqlServer`等数据库中只支持一种存储引擎，故其数据存储管理机制都是一样的，而`MySQL`中提供了多种存储引擎，用户可以根据不同的需求为数据表选择不同的存储引擎，用户也可以根据自己的需要编写自己的存储引擎。

> 如处理文本文件可使用`txt`类型，处理图片可使用`png`类型

# 存储引擎

在`MySQL`中支持多种存储引擎，使用`show engines;`命令可查看所支持的存储引擎

```objectivec
mysql> show engines;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
9 rows in set (0.00 sec)

mysql>
```



## InnoDB

`InnoDB`存储引擎是`MySQL`默认的存储引擎，支持事务操作，其设计目标主要面向联机事务处理(OLTP)的应用。

特点是行锁设计、支持外键，并支持类似`Oracle`的非锁定读，即默认读取操作不会产生锁。 `InnoDB`存储引擎将数据放在一个逻辑的表空间中，这个表空间就像黑盒一样由`InnoDB`存储引擎自身来管理。

从`MySQL4.1`(包括 4.1)版本开始，可以将每个`InnoDB`存储引擎的 表单独存放到一个独立的 ibd文件中。此外，`InnoDB`存储引擎支持将裸设备(row disk)用 于建立其表空间。 `InnoDB`通过使用多版本并发控制(MVCC)来获得高并发性，并且实现了SQL标准 的4种隔离级别，默认为REPEATABLE级别，同时使用一种称为netx-key locking的策略来避免幻读(phantom)现象的产生。

除此之外，`InnoDB`存储引擎还提供了插入缓冲(insert buffer)、二次写(double write)、自适应哈希索引(adaptive hash index)、预读(read ahead) 等高性能和高可用的功能。 对于表中数据的存储，`InnoDB`存储引擎采用了聚集(clustered)的方式，每张表都是按主键的顺序进行存储的，如果没有显式地在表定义时指定主键，`InnoDB`存储引擎会为每一 行生成一个 6字节的行ID(ROWID)，并以此作为主键。 `InnoDB`存储引擎是 `MySQL`数据库最为常用的一种引擎，Facebook、Google、Yahoo等 公司的成功应用已经证明了 `InnoDB`存储引擎具备高可用性、高性能以及高可扩展性。对其底层实现的掌握和理解也需要时间和技术的积累。

如果想深入了解 `InnoDB`存储引擎的工作原理、实现和应用可以参考《MySQL 技术内幕:InnoDB存储引擎》一书。



## MyISAM

不支持事务、表锁设计、支持全文索引，主要面向一些 OLAP数据库应用，在`MySQL5.5.8`版本之前是默认的存储引擎(除 Windows 版本外)。数据库系统与文件系统一个很大的不同在于对事务的支持，`MyISAM`存储引擎是不支持事务的。

究其根本，这也并不难理解。用户在所有的应用中是否都需要事务呢？在数据仓库中，如果没有ETL这些操作，只是简单地通过报表查询还需要事务的支持吗？此外，`MyISAM`存储引擎的另一个与众不同的地方是，它的缓冲池只缓存(cache)索引文件，而不缓存数据文件，这与大多数的数据库都不相同。



## NDB

2003年，MysqlAB公司从SonyEricsson公司收购了`NDB`存储引擎。

`NDB`存储引擎是一个集群存储引擎，类似于Oracle的RAC集群，不过与Oracle RAC的share everythin结构不同的是，其结构是share nothing的集群架构，因此能提供更高级别的高可用性。

`NDB`存储引擎的特点是数据全部放在内存中(从 5.1 版本开始，可以将非索引数据放在磁盘上)，因此主键查找(primary key lookups)的速度极快，并且能够在线添加 `NDB`数据存储节点(data node)以便线性地提高数据库性能。

由此可见，`NDB`存储引擎是高可用、 高性能、高可扩展性的数据库集群系统，其面向的也是OLTP的数据库应用类型。



## Memory

正如其名，`Memory`存储引擎中的数据都存放在内存中。

数据库重启或发生崩溃，表中的数据都将消失。它非常适合于存储`OLTP`数据库应用中临时数据的临时表，也可以作为OLAP数据库应用中数据仓库的维度表。

`Memory`存储引擎默认使用哈希索引,而不是通常熟悉的B+树索引。



## Infobright

第三方的存储引擎。

其特点是存储是按照列而非行的，因此非常适合`OLAP`的数据库应用。

其官方网站是 http://www.infobright.org/，上面有不少成功的数据 仓库案例可供分析。



## NTSE

网易公司开发的面向其内部使用的存储引擎。

目前的版本不支持事务，但提供压缩、行级缓存等特性，不久的将来会实现面向内存的事务支持。



## BLACKHOLE

洞存储引擎，可以应用于主备复制中的分发主库。



# 设置引擎



## 建表指定

在建表语句后使用`engine`关键字可指定存储引擎。

```
create table 表名(id int,name char) engine=存储引擎（默认innodb）;
```

以下将创建一个`temp`临时表，使用`memory`存储引擎。

```sql
mysql> create table temp(id int) engine=memory;
Query OK, 0 rows affected (0.01 sec)

mysql> show create table temp;  # 查看创建信息
+-------+------------------------------------------------------------------------------------------+
| Table | Create Table                                                                             |
+-------+------------------------------------------------------------------------------------------+
| temp  | CREATE TABLE `temp` (
  `id` int(11) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=latin1 |
+-------+------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql>
```

`memory`中的数据将在关闭`MySQL`服务时清空。

而`blackhole`存储引擎特征则是无论插入多少条记录表内永远都不会存放。



## 配置指定

在配置文件中，也可指定建表时的存储引擎。

```ini
[mysqld]
#创建新表时将使用的默认存储引擎
default-storage-engine=INNODB
```



## 文件结构

这里以`InnoDB`为例，我们先创建出一个`student`表，再查看其文件结构。

```sql
mysql> create table student(id int) engine=innodb;
Query OK, 0 rows affected (0.02 sec)
```

![image-20200829141336661](mysql_images/1881426-20200829141545611-2054763709.png)

student.frm 存储的是表结构，如字段等信息

student.ibd 存储的是表数据，如记录等信息
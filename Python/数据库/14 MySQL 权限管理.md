[toc]

# 权限管理

在`MySQL`中，我们可以使用`root`用户创建出一些新的用户并为他们分配一些权限，如可编辑那些数据库，可使用那些`SQL`语句等等。

打个比方，一个开发部门可能公用一个数据库，而各个开发小组的组长包括成员只能查看或编辑自身业务范围之内的记录，这种需求下就需要使用到权限管理。



# 系统权限

系统权限是存储于`MySQL`数据库中，该数据库下有4张关于权限的表。

| 表名         | 描述                                                   | 授权书写          |
| ------------ | ------------------------------------------------------ | ----------------- |
| user         | 针对所有数据库，所有库下所有表，以及表下的所有字段     | *.*               |
| db           | 针对某一数据库，该数据库下的所有表，以及表下的所有字段 | 数据库名.*        |
| tables_priv  | 针对某一张表，以及该表下的所有字段                     | 数据库名.数据表名 |
| columns_priv | 针对某一个字段                                         | 字段名1，字段名2  |

我们使用`select * from MySQL.user`l来看一下这张表部分内容。

针对root用户的权限

```sql
*************************** 1. row ***************************
                  Host: localhost  -- 只能从本地进行登录
                  User: root   -- 针对root用户，它具有以下所有权限
           Select_priv: Y
           Insert_priv: Y
           Update_priv: Y
           Delete_priv: Y
           Create_priv: Y
             Drop_priv: Y
           Reload_priv: Y
         Shutdown_priv: Y
          Process_priv: Y
             File_priv: Y
            Grant_priv: Y
       References_priv: Y
            Index_priv: Y
            Alter_priv: Y
          Show_db_priv: Y
            Super_priv: Y
 Create_tmp_table_priv: Y
      Lock_tables_priv: Y
          Execute_priv: Y
       Repl_slave_priv: Y
      Repl_client_priv: Y
      Create_view_priv: Y
        Show_view_priv: Y
   Create_routine_priv: Y
    Alter_routine_priv: Y
      Create_user_priv: Y
            Event_priv: Y
          Trigger_priv: Y
Create_tablespace_priv: Y
              ssl_type:
            ssl_cipher:
           x509_issuer:
          x509_subject:
         max_questions: 0
           max_updates: 0
       max_connections: 0
  max_user_connections: 0
                plugin: mysql_native_password
 authentication_string:
      password_expired: N
 password_last_changed: 2020-08-30 23:17:49
     password_lifetime: NULL
        account_locked: N

```





# 创建用户

创建用户与修改用户权限必须登录`root`账户，其他账户均无法完成该两项操作。

```
create user "用户名"@"允许登录的地址" identified by "密码;"
create user "Yunya"@"localhost" identified by "123"; -- 创建用户名为云崖的用户，允许该用户从本地进行登录

create user "Yunya"@"192.168.31.10" identified by "123"; -- 创建用户名为云崖的用户，允许该用户从192.168.31.10进行登录

create user "Yunya"@"192.168.31.%" identified by "123"; -- 创建用户名为云崖的用户，允许该用户从192.168.31.xxx的网段进行登录

create user "Yunya"@"%" identified by "123"; -- 创建用户名为云崖的用户，允许该用户从任意ip地址的网络进行登录
```



# 分配权限

分配权限与释放权限必须在`root`账户下进行

```vhdl
grant all on *.* to "Yunya"@"%"; -- 为云崖分配所有权限
grant select on db1.* to "Yunya"@"%" -- 为云崖分配db1数据库下的所有数据表的查看权限

grant select(id,name),update(age) on db1.t1 to "Yunya"@"%" -- 为云崖分配db1数据库下的t1数据表的查看id，name字段与更新age字段的权限

revoke all on *.* to "Yunya"@"%"; -- 释放掉Yunya的所有权限
```

接下来将为Yunya分配`db1.t1`的`select`权限与`update`权限

权限分配

```sql
create database db1;

create table db1.t1(
        id int auto_increment primary key,
        name char(5)
);

create table db1.t2(
        id int auto_increment primary key,
        name char(5)
);

use db1;

insert into t1(name) values ("t1");

insert into t2(name) values ("t2");

grant select,update on db1.t1 to "Yunya"@"%";
　　 开始测试。

mysql> show databases;  # Yunya只能查看这些数据库
+--------------------+
| Database           |
+--------------------+
| information_schema |
| db1                |
+--------------------+
2 rows in set (0.00 sec)

mysql> use db1;
Database changed
mysql> show tables;  # Yunya只能看到t1表
+---------------+
| Tables_in_db1 |
+---------------+
| t1            |
+---------------+
1 row in set (0.00 sec)

mysql> delete from t1 where name = "t1";  # 无法完成记录的删除操作
ERROR 1142 (42000): DELETE command denied to user 'Yunya'@'localhost' for table 't1'
mysql> select name from t1;  # 可以使用查询操作
+------+
| name |
+------+
| t1   |
+------+
1 row in set (0.00 sec)

mysql>

```



最后我们重新登录`root`用户，查看一下`MySQL.USER`表中的变化。

新增的用户Yunya权限信息

```sql
*************************** 4. row ***************************
                  Host: %  -- 允许从任意IP进行登录
                  User: Yunya
           Select_priv: N
           Insert_priv: N
           Update_priv: N
           Delete_priv: N
           Create_priv: N
             Drop_priv: N
           Reload_priv: N
         Shutdown_priv: N
          Process_priv: N
             File_priv: N
            Grant_priv: N
       References_priv: N
            Index_priv: N
            Alter_priv: N
          Show_db_priv: N
            Super_priv: N
 Create_tmp_table_priv: N
      Lock_tables_priv: N
          Execute_priv: N
       Repl_slave_priv: N
      Repl_client_priv: N
      Create_view_priv: N
        Show_view_priv: N
   Create_routine_priv: N
    Alter_routine_priv: N
      Create_user_priv: N
            Event_priv: N
          Trigger_priv: N
Create_tablespace_priv: N
              ssl_type:
            ssl_cipher:
           x509_issuer:
          x509_subject:
         max_questions: 0
           max_updates: 0
       max_connections: 0
  max_user_connections: 0
                plugin: mysql_native_password
 authentication_string: *23AE809DDACAF96AF0FD78ED04B6A265E05AA257  -- 存储的密文密码
      password_expired: N
 password_last_changed: 2020-09-03 23:27:26
     password_lifetime: NULL
        account_locked: N

```


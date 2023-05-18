[toc]

# 数据表操作

每一张数据表都相当于一个文件，在数据表中又分为表结构与表记录。

> 表结构：包括存储引擎，字段，主外键类型，约束性条件，字符编码等
>
> 表记录：数据表中的每一行数据（不包含字段行）

| id   | name  | gender | age  |
| ---- | ----- | ------ | ---- |
| 1    | YunYa | male   | 18   |
| 2    | Jack  | male   | 17   |
| 3    | Baby  | famale | 16   |

## 创建数据表

创建数据表其实大有讲究，它包括表名称，表字段，存储引擎，主外键类型，约束性条件，字符编码等。

如果`InnoDB`数据表没有创建主键，那么`MySQL`会自动创建一个以行号为准的隐藏主键。

```markdown
#语法: []为可选
create table 表名(
字段名1 类型[(宽度) 约束条件],
字段名2 类型[(宽度) 约束条件],
字段名3 类型[(宽度) 约束条件]
) [chrset="字符编码"];

#注意:
1. 在同一张表中，字段名是不能相同
2. 宽度和约束条件可选
3. 字段名和类型是必须的
4. 表中最后一个字段不要加逗号
```

以下示例将演示在`school`数据库中创建`student`数据表

```rust
mysql> use school;
Database changed
mysql> create table student(
    ->         name varchar(32),
    ->         gender enum("male","famale"),
    ->         age smallint
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql>
```

也可以不进入数据库在外部或另外的库中进行创建，那么创建时就应该指定数据库

```css
create table 数据库名.新建的数据表名(
	字段名1 类型[(宽度) 约束条件],
	字段名2 类型[(宽度) 约束条件]
	);
```



## 查看数据表

在某一数据库中使用`show tables;`可查看该库下的所有数据表。

使用`show create table 表名;`可查看该表的创建信息。

使用`desc 表名;`可查看该表的表结构，包括字段，类型，约束条件等信息

```sql
mysql> select database(); # 查看当前所在数据库
+------------+
| database() |
+------------+
| school     |
+------------+
1 row in set (0.00 sec)

mysql> show tables; # 查看当前库下所有表名
+------------------+
| Tables_in_school |
+------------------+
| student          |
+------------------+
1 row in set (0.00 sec)

mysql> show create table student;  # 查看student表的创建信息
+---------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table   | Create Table                                                                                                                                                                       |
+---------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| student | CREATE TABLE `student` (
  `name` varchar(32) DEFAULT NULL,
  `gender` enum('male','famale') DEFAULT NULL,
  `age` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 |
+---------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql> show create table student\G;  # 使用\G可将其转换为一行显示
*************************** 1. row ***************************
       Table: student
Create Table: CREATE TABLE `student` (
  `name` varchar(32) DEFAULT NULL,
  `gender` enum('male','famale') DEFAULT NULL,
  `age` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1
1 row in set (0.00 sec)

ERROR:
No query specified

mysql> desc student;  # 查看表结构
+--------+-----------------------+------+-----+---------+-------+
| Field  | Type                  | Null | Key | Default | Extra |
+--------+-----------------------+------+-----+---------+-------+
| name   | varchar(32)           | YES  |     | NULL    |       |
| gender | enum('male','famale') | YES  |     | NULL    |       |
| age    | smallint(6)           | YES  |     | NULL    |       |
+--------+-----------------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

mysql>
```



## 修改表名字

使用`alter table 旧表名 rename 新表名;`可修改表名

以下示例将展示将`studnet`表名修改为`students`。

```sql
mysql> alter table student rename students;
Query OK, 0 rows affected (0.01 sec)

mysql> show tables;  # 查看当前库下所有表名
+------------------+
| Tables_in_school |
+------------------+
| students         |
+------------------+
1 row in set (0.00 sec)

mysql>
```



## 清空数据表

使用`truncate 表名`可将表中所有记录清空，并将部分结构进行重置（如自增字段会恢复至初始值）。

以下示例将演示创建出一张`temp`表并在其中插入一些数据后进行清空操作。

```sql
mysql> create table temp(id smallint);  # 新建temp表
Query OK, 0 rows affected (0.03 sec)

mysql> insert into temp values(1);  # 插入数据
Query OK, 1 row affected (0.00 sec)

mysql> insert into temp values(2);
Query OK, 1 row affected (0.00 sec)

mysql> select * from temp;
+------+
| id   |
+------+
|    1 |
|    2 |
+------+
2 rows in set (0.00 sec)

mysql> truncate temp;  # 清空操作
Query OK, 0 rows affected (0.03 sec)

mysql> select * from temp;
Empty set (0.00 sec)

mysql>
```



## 删除数据表

使用`drop table 表名;`可删除某一数据表，也可使用`drop tables 表名1,表名2,表名n`进行批量删除的操作。

以下示例将演示创建出一个`temp`表再将其进行删除的操作

```sql
mysql> create table temp(id smallint);  # 新建temp表
Query OK, 0 rows affected (0.03 sec)

mysql> show tables;  # 查看当前库下所有表名
+------------------+
| Tables_in_school |
+------------------+
| students         |
| temp             |
+------------------+
2 rows in set (0.00 sec)

mysql> drop table temp;  # 删除temp表
Query OK, 0 rows affected (0.01 sec)

mysql> show tables;  # 查看当前库下所有表名
+------------------+
| Tables_in_school |
+------------------+
| students         |
+------------------+
1 row in set (0.00 sec)

mysql>
```



# 复制表操作



## 结构复制

以下将演示只复制`mysql.user`表的结构，不复制记录

```sql
mysql> create table temp like mysql.user;
```

由于`mysql.user`表结构太多，故这里不进行展示



## 全部复制

又要复制表结构，又要复制表记录，则使用以下语句（不会复制主键，外键，索引）

```sql
create table temp select * from mysql.user;
```



## 选择复制

选择某一字段及其记录进行复制，可使用以下语句

```sql
mysql> create table temp select host,user from mysql.user;
Query OK, 3 rows affected (0.03 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> select * from temp;
+-----------+---------------+
| host      | user          |
+-----------+---------------+
| localhost | mysql.session |
| localhost | mysql.sys     |
| localhost | root          |
+-----------+---------------+
3 rows in set (0.00 sec)

mysql>
```



# 表字段操作

表字段是属于表结构的一部分，可以将他作为文档的标题。

其标题下的一行均属于当前字段下的数据。



## 新增字段

```sql
# ==== 增加多个字段  ====
     
      ALTER TABLE 表名
                          ADD 字段名  数据类型 [完整性约束条件…],
                          ADD 字段名  数据类型 [完整性约束条件…];
                          
# ==== 增加单个字段，排在最前面  ====

      ALTER TABLE 表名
                          ADD 字段名  数据类型 [完整性约束条件…]  FIRST;
                          
# ==== 增加单个字段，排在某一字段后面  ====

      ALTER TABLE 表名
                          ADD 字段名  数据类型 [完整性约束条件…]  AFTER 字段名;
```

以下示例将展示为`students`表新增一个名为`id`的非空字段，该字段放在最前面，并且在`age`字段后新增`class`字段。

```sql
mysql> alter table students
    ->         add id mediumint not null first,  # 非空，排在最前面
    ->         add class varchar(12) not null after age;  # 非空，排在age后面
Query OK, 0 rows affected (0.05 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc students;
+--------+-----------------------+------+-----+---------+-------+
| Field  | Type                  | Null | Key | Default | Extra |
+--------+-----------------------+------+-----+---------+-------+
| id     | mediumint(9)          | NO   |     | NULL    |       |
| name   | varchar(32)           | YES  |     | NULL    |       |
| gender | enum('male','famale') | YES  |     | NULL    |       |
| age    | smallint(6)           | YES  |     | NULL    |       |
| class  | varchar(12)           | NO   |     | NULL    |       |
+--------+-----------------------+------+-----+---------+-------+
5 rows in set (0.00 sec)

mysql>
```



## 修改字段

修改字段分为修改字段名或者修改其数据类型

```sql
# ==== MODIFY只能修改数据类型及其完整性约束条件 ====  

      ALTER TABLE 表名 
                          MODIFY  字段名 数据类型 [完整性约束条件…];
                          
# ==== CHANGE能修改字段名、数据类型及其完整性约束条件  ====  

      ALTER TABLE 表名 
                          CHANGE 旧字段名 新字段名 旧数据类型 [完整性约束条件…];
      ALTER TABLE 表名 
                          CHANGE 旧字段名 新字段名 新数据类型 [完整性约束条件…];
```

以下示例将展示修改`id`字段为自增主键，并将其名字修改为`stu_id`

```sql
mysql> alter table students
    ->         change id stu_id mediumint not null primary key auto_increment first;
Query OK, 0 rows affected (0.06 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc students;
+--------+-----------------------+------+-----+---------+----------------+
| Field  | Type                  | Null | Key | Default | Extra          |
+--------+-----------------------+------+-----+---------+----------------+
| stu_id | mediumint(9)          | NO   | PRI | NULL    | auto_increment |
| name   | varchar(32)           | YES  |     | NULL    |                |
| gender | enum('male','famale') | YES  |     | NULL    |                |
| age    | smallint(6)           | YES  |     | NULL    |                |
| class  | varchar(12)           | NO   |     | NULL    |                |
+--------+-----------------------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql>
```

如果不修改名字只修改其原本的类型或完整性约束条件，可使用`modify`进行操作。



## 删除字段

使用以下命令可删除某一字段

```sql
ALTER TABLE 表名 
                          DROP 字段名;
```

以下示例将展示删除`class`字段

```sql
mysql> alter table students drop class;
Query OK, 0 rows affected (0.07 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc students;
+--------+-----------------------+------+-----+---------+----------------+
| Field  | Type                  | Null | Key | Default | Extra          |
+--------+-----------------------+------+-----+---------+----------------+
| stu_id | mediumint(9)          | NO   | PRI | NULL    | auto_increment |
| name   | varchar(32)           | YES  |     | NULL    |                |
| gender | enum('male','famale') | YES  |     | NULL    |                |
| age    | smallint(6)           | YES  |     | NULL    |                |
+--------+-----------------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)

mysql>
```



# 其他操作



## 存储引擎

以下示例将展示如何将数据表`students`存储引擎修改为`memory`

```sql
mysql> alter table students engine='memory';
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0
```



## 字符编码

以下示例将展示如何将数据表`students`字符编码修改为`gbk`

```sql
mysql> alter table students charset="gbk";
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0
```
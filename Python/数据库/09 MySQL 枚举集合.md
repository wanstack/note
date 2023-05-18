[toc]

# ENUM

枚举类型从众多选项中提取出一个选项，类似于单选的概念，最大可指定65535个选项。

如果插入值不在其选项中，将会插入``。

```sql
mysql> create table user(  # 创建用户表
    ->         name char(12),
    ->         gender enum("male","famale","outher"),  # 性别使用枚举类型再合适不过
    ->         age tinyint
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> insert into user(name,gender,age) values
    ->         ("Yunya","male",18),
    ->         ("Baby","famale",18);
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from user;
+--------------+--------+------+
| name         | gender | age  |
+--------------+--------+------+
| Yunya        | male   |   18 |
| Baby         | famale |   18 |
+--------------+--------+------+
2 rows in set (0.00 sec)

mysql>
```



# SET

集合类型从众多选项中提取出多个选项，类似于多选的概念，最大可指定64个选项。

如果插入值中有一个不在其选项中，该插入值将为``，在其选项中的值将会正确插入。

```sql
mysql> create table user(  # 创建用户表
    ->         name char(12),
    ->         gender enum("male","famale","outher"),
    ->         age tinyint,
    ->         hobby set("basketball","football","music","playgame") # 爱好使用集合类型再合适不过
    -> );
Query OK, 0 rows affected (0.03 sec)

mysql> insert into user(name,gender,age,hobby) values
    ->         ("Yunya","male",18,"basketball,playgame"),
    ->         ("Baby","famale",18,"football,music");  # 插入时按照 "选项1，选项2" 的方式进行插入
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from user;
+--------------+--------+------+---------------------+
| name         | gender | age  | hobby               |
+--------------+--------+------+---------------------+
| Yunya        | male   |   18 | basketball,playgame |
| Baby         | famale |   18 | football,music      |
+--------------+--------+------+---------------------+
2 rows in set (0.00 sec)

mysql>
```
[toc]

# 创建表格

以下所有操作均在`user_temp`表中进行操作。

```sql
create table user_temp(
        id int primary key auto_increment,
        name char(5) not null,
        gender enum("男","女") default "男",
        age tinyint not null
);
```



# INSERT

`INSERT`用于插入一条记录

```sql
1. 插入完整数据（顺序插入）
    语法一：
    INSERT INTO 表名(字段1,字段2,字段3…字段n) VALUES(值1,值2,值3…值n);

    语法二：
    INSERT INTO 表名 VALUES (值1,值2,值3…值n);

2. 指定字段插入数据
    语法：
    INSERT INTO 表名(字段1,字段2,字段3…) VALUES (值1,值2,值3…);

3. 插入多条记录
    语法：
    INSERT INTO 表名 VALUES
        (值1,值2,值3…值n),
        (值1,值2,值3…值n),
        (值1,值2,值3…值n);
        
4. 插入查询结果
    语法：
    INSERT INTO 表名(字段1,字段2,字段3…字段n) 
                    SELECT (字段1,字段2,字段3…字段n) FROM 表2
                    WHERE …;
```

以下示例将演示使用指定字段进行数据插入。

```sql
insert into user_temp(name,gender,age) values
        ("云崖","男",18),
        ("贝拉","女",18),
        ("杰克","男",17);
        
mysql> select * from user_temp;
+----+--------+--------+-----+
| id | name   | gender | age |
+----+--------+--------+-----+
|  1 | 云崖   | 男     |  18 |
|  2 | 贝拉   | 女     |  18 |
|  3 | 杰克   | 男     |  17 |
+----+--------+--------+-----+
```



# UPDATE

`UPDATE`用于对记录做更新操作

```sql
语法：
    UPDATE 表名 SET
        字段1 = 值1,
        字段2 = 值2   # 注意，不要逗号
        WHERE CONDITION;
```

以下示例将演示更新指定字段。

```sql
update user_temp set 
        name = "云崖先生",
        age = 23
        where name = "云崖";
        
mysql> select * from user_temp;
+----+--------------+--------+-----+
| id | name         | gender | age |
+----+--------------+--------+-----+
|  1 | 云崖先生     | 男     |  23 |
|  2 | 贝拉         | 女     |  18 |
|  3 | 杰克         | 男     |  17 |
+----+--------------+--------+-----+
```



# DELETE

`DELETE`用于对记录做删除操作

```sql
语法：
    DELETE FROM 表名 
        WHERE 条件;
```

以下示例将演示删除指定字段。

```sql
delete from user_temp
        where name = "贝拉" and age = 18;

mysql> select * from user_temp;
+----+--------------+--------+-----+
| id | name         | gender | age |
+----+--------------+--------+-----+
|  1 | 云崖先生     | 男     |  23 |
|  3 | 杰克         | 男     |  17 |
+----+--------------+--------+-----+
```
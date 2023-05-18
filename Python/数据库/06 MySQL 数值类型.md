[toc]

# 整数类型

整数类型包含`TINYINT`、`SMALLINT`、`MEDIUMINT`、`INT BIGINT`等



## 存取范围

| 类型            | 存储大小 | 默认显示宽度（个） | 范围（有符号）                             | 范围（无符号）           |
| --------------- | -------- | ------------------ | ------------------------------------------ | ------------------------ |
| TINYINT(m)      | 1Byte    | m：4               | -128 - 127                                 | 0 - 255                  |
| SMALLINT(m)     | 2Byte    | m：6               | -32768 - 32767                             | 0 - 65535                |
| MEDIUMINT(m)    | 3Byte    | m：9               | -8388608 - 8388607                         | 0 - 16777215             |
| INT\|INTEGER(m) | 4Byte    | m：11              | -2147483648 - 2147483647                   | 0 - 4294967295           |
| BIGINT(m)       | 8Byte    | m：20              | -9233372036854775808 - 9223372036854775807 | 0 - 18446744073709551615 |

> `m`为其显示宽度，在为字段设置 `zerofill`约束条件时有效，否则将不会填充满整个显示宽度。



## 可选约束

unsigned：使用无符号存储

zerofill：显示宽度不够时使用0进行填充



## 显示宽度

使用一些数值类型时，指定其宽度均是为其指定显示宽度，并非存入的限制宽度。

以下示例将演示为`INT`类型设置显示宽度后，当宽度不够时将以指定字符进行填充。

```sql
mysql> create table temp (num int(5) unsigned zerofill);  # 创建temp表，显示宽度为5，有num字段，无符号整型，使用0进行宽度填充
Query OK, 0 rows affected (0.03 sec)

mysql> insert into temp (num) values
    ->         (1),
    ->         (9999999);
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from temp;
+---------+
| num     |
+---------+
|   00001 |  # 当显示宽度不够时使用0进行填充
| 9999999 |  # 由于指定的宽度是显示宽度，故该数值也能存入，这与存储宽度无关
+---------+
2 rows in set (0.00 sec)

mysql>
```



## 范围超出

当范围超出默认值时，将会按照最大值或最小值进行存入。

以下示例将演示`TINYINT`类型无符号存入-1与256后将会按照0与255进行存储。

> `MySQL5.7.30`版本中这样的操作将会抛出异常
>
> 但是在`MySQL5.6.X`版本中这样的操作是被允许的（非严格模式下）

```sql
mysql> create table temp(num tinyint);
mysql> insert into temp(num) values
    -> (-129),
    -> (128);
mysql> select * from temp;
+------+
| temp |
+------+
| -128 | #-129存成了-128
|  127 | #128存成了127
+------+
```



# 浮点类型

浮点类型包括`FLOAT`、`DOUBLE`、`DECIMAL`



## 存取范围

| 类型           | 存储大小            | 最大显示宽度（个） | 范围（有符号）                                               | 范围（无符号）                                               | 精确度       |
| -------------- | ------------------- | ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------ |
| FLOAT(m[,d])   | 4Bytes              | m：255，d：30      | (-3.402 823 466 E+38，-1.175 494 351 E-38) - 0               | 0 - (1.175 494 351 E-38，3.402 823 466 E+38)                 | 点七位以内   |
| DOUBLE(m[,d])  | 8Bytes              | m：255，d：30      | (-1.797 693 134 862 315 7 E+308，-2.225 073 858 507 201 4 E-308) - 0 | 0 - (2.225 073 858 507 201 4 E-308，1.797 693 134 862 315 7 E+308) | 点十五位以内 |
| DECIMAL(m[,d]) | m+2（如果m<d则d+2） | m：65，d：30       | 取决于m,d（m范围（1-65），d范围（0-30））                    | 取决于m,d（m范围（1-65），d范围（0-30））                    | 绝对精准     |

> `m`为其整数部分显示个数，`d`为其小数部分显示个数。
>
> `DECIMAL`底层由字符串进行存储，故精度不会出现偏差，也被称为定点类型。



## 精度问题

根据不同的需求，应当使用不同的浮点类型进行存储，一般来说使用`FLOAT`足以，但是对于一些精度非常高的数据则应该使用`DECIMAL`类型进行存储。

以下示例将演示使用不同的浮点类型进行值存储时会发生精度问题。

```sql
mysql> create table t1(num float(255,30));  # 指定显示宽度
Query OK, 0 rows affected (0.05 sec)

mysql> create table t2(num double(255,30)); # 指定显示宽度
Query OK, 0 rows affected (0.03 sec)

mysql> create table t3(num decimal(65,30)); # 指定显示宽度
Query OK, 0 rows affected (0.03 sec)

mysql> insert into t1(num) values(1.11111111111111111);
Query OK, 1 row affected (0.00 sec)

mysql> insert into t2(num) values(1.11111111111111111);
Query OK, 1 row affected (0.02 sec)

mysql> insert into t3(num) values(1.11111111111111111);
Query OK, 1 row affected (0.00 sec)

mysql> select * from t1;  # 点后7位以内
+----------------------------------+
| num                              |
+----------------------------------+
| 1.111111164093017600000000000000 |
+----------------------------------+
1 row in set (0.00 sec)

mysql> select * from t2;  # 点后15位以内
+----------------------------------+
| num                              |
+----------------------------------+
| 1.111111111111111200000000000000 |
+----------------------------------+
1 row in set (0.00 sec)

mysql> select * from t3;  # 绝对精确
+----------------------------------+
| num                              |
+----------------------------------+
| 1.111111111111111110000000000000 |
+----------------------------------+
1 row in set (0.00 sec)

mysql>
```



# 位类型

`BIT(M)`可以用来存放多位二进制数，`M`范围从1~64，如果不写默认为1位。

注意：对于位字段需要使用函数读取

`bin()`显示为二进制

`hex()`显示为十六进制

```sql
mysql> create table temp(num bit);  # 创建temp表，num字段为bit类型
Query OK, 0 rows affected (0.03 sec)

mysql> desc temp; # 默认显示宽度为1
+-------+--------+------+-----+---------+-------+
| Field | Type   | Null | Key | Default | Extra |
+-------+--------+------+-----+---------+-------+
| num   | bit(1) | YES  |     | NULL    |       |
+-------+--------+------+-----+---------+-------+
1 row in set (0.00 sec)

mysql> insert into temp(num) values(1);  # 插入记录，1
Query OK, 1 row affected (0.00 sec)

mysql> select * from temp;  # 直接查看是查看不到的
+------+
| num  |
+------+
|     |
+------+
1 row in set (0.00 sec)

mysql> select bin(num),hex(num) from temp;  # 需要转换为二进制或十六进制进行查看
+----------+----------+
| bin(num) | hex(num) |
+----------+----------+
| 1        | 1        |
+----------+----------+
1 row in set (0.00 sec)

mysql> alter table temp modify num bit(5);  # 修改num字段的显示宽度为5
Query OK, 1 row affected (0.06 sec)
Records: 1  Duplicates: 0  Warnings: 0

mysql> insert into temp values(8);  # 插入记录，8
Query OK, 1 row affected (0.02 sec)

mysql> select bin(num),hex(num) from temp; # 显示的是不同的进制
+----------+----------+
| bin(num) | hex(num) |
+----------+----------+
| 1        | 1        |
| 1000     | 8        |
+----------+----------+
2 rows in set (0.00 sec)

mysql>
```
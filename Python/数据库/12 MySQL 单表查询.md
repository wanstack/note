[toc]

# 准备数据

以下操作将在该表中进行

```sql
create table student (
        id int unsigned primary key auto_increment,
        name char(12) not null,
        gender enum("male","famale") default "male",
        age tinyint unsigned not null,
        hoc_group char(12) not null,
        html tinyint unsigned not null,
        css tinyint unsigned not null,
        js tinyint unsigned not null,
        sanction enum("大处分","小处分","无")
);

insert into student(name,gender,age,hoc_group,html,css,js,sanction) values
        ("Yunya","male",18,"first",88,93,76,"无"),
        ("Jack","male",17,"second",92,81,88,"无"),
        ("Bella","famale",17,"first",72,68,91,"小处分"),
        ("Dairis","famale",18,"third",89,54,43,"大处分"),
        ("Kyle","famale",19,"fifth",31,24,60,"大处分"),
        ("Alice","famale",16,"second",49,23,58,"无"),
        ("Ken","male",16,"third",33,62,17,"大处分"),
        ("Jason","male",21,"fourth",91,92,90,"无"),
        ("Tom","male",20,"fifth",88,72,91,"无"),
        ("Fiona","famale",19,"fourth",60,71,45,"无");
```



# 查询语法

```sql
SELECT DISTINCT(字段名1,字段名2...) FROM 表名
                  WHERE 条件
                  GROUP BY 字段名
                  HAVING 筛选
                  ORDER BY 字段名 asc/desc
                  LIMIT 限制条数;
```



# 执行顺序

虽然查询的书写语法是上面那样的，但是其内部执行顺序却有些不太一样。

> 1.通过`from`找到将要查询的表
>
> 2.`where`规定查询条件，在表记录中逐行进行查询并筛选出符合规则的记录
>
> 3.将查到的记录进行字段分组`group by`，如果没有进行分组，则默认为一组
>
> 4.将分组得到的结果进行`having`筛选，可使用聚和函数（`where`时不可使用聚合函数）
>
> 5.执行`select`准备打印
>
> 6.执行`distinct`对打印结果进行去重
>
> 7.执行`ordery by`对结果进行排序
>
> 8.执行`limit`对打印结果的条数进行限制



# select

`select`主要复负责打印相关的工作



## 全部查询

使用`select * from 表名`可拿到该表下全部的数据

以下示例将展示使用全部查询拿到`student`表中所有记录

```smalltalk
 select * from student;
 
+----+--------+--------+-----+-----------+------+-----+----+-----------+
| id | name   | gender | age | hoc_group | html | css | js | sanction  |
+----+--------+--------+-----+-----------+------+-----+----+-----------+
|  1 | Yunya  | male   |  18 | first     |   88 |  93 | 76 | 无        |
|  2 | Jack   | male   |  17 | second    |   92 |  81 | 88 | 无        |
|  3 | Bella  | famale |  17 | first     |   72 |  68 | 91 | 小处分    |
|  4 | Dairis | famale |  18 | third     |   89 |  54 | 43 | 大处分    |
|  5 | Kyle   | famale |  19 | fifth     |   31 |  24 | 60 | 大处分    |
|  6 | Alice  | famale |  16 | second    |   49 |  23 | 58 | 无        |
|  7 | Ken    | male   |  16 | third     |   33 |  62 | 17 | 大处分    |
|  8 | Jason  | male   |  21 | fourth    |   91 |  92 | 90 | 无        |
|  9 | Tom    | male   |  20 | fifth     |   88 |  72 | 91 | 无        |
| 10 | Fiona  | famale |  19 | fourth    |   60 |  71 | 45 | 无        |
+----+--------+--------+-----+-----------+------+-----+----+-----------+
```



## 字段查询

使用`select 字段名1，字段名2 from 表名`可拿到特定字段下相应的数据

以下示例将展示使用字段查询拿到每个学生的`HTML\CSS\JS`成绩

```sql
select name,html,css,js from student;

+--------+------+-----+----+
| name   | html | css | js |
+--------+------+-----+----+
| Yunya  |   88 |  93 | 76 |
| Jack   |   92 |  81 | 88 |
| Bella  |   72 |  68 | 91 |
| Dairis |   89 |  54 | 43 |
| Kyle   |   31 |  24 | 60 |
| Alice  |   49 |  23 | 58 |
| Ken    |   33 |  62 | 17 |
| Jason  |   91 |  92 | 90 |
| Tom    |   88 |  72 | 91 |
| Fiona  |   60 |  71 | 45 |
+--------+------+-----+----+
```



## as 别名

使用`select 字段名1 as 别名1, 字段名2 as 别名2 from 表名`可将查询到的记录字段修改一个别名

以下示例将展示修改`name`字段为`姓名`，修改`gender`字段为`性别`，修改`age`字段为`年龄`的操作

```smalltalk
select name as "姓名", gender as "性别", age as "年龄" from student;

+--------+--------+--------+
| 姓名   | 性别   | 年龄   |
+--------+--------+--------+
| Yunya  | male   |     18 |
| Jack   | male   |     17 |
| Bella  | famale |     17 |
| Dairis | famale |     18 |
| Kyle   | famale |     19 |
| Alice  | famale |     16 |
| Ken    | male   |     16 |
| Jason  | male   |     21 |
| Tom    | male   |     20 |
| Fiona  | famale |     19 |
+--------+--------+--------+
```



## distinct

使用`select distinct(字段名1, 字段名2) from 表名`可将查询到的记录做一个取消重复的操作

以下示例将展示使用去重功能来看有多少个小组

```smalltalk
select distinct(hoc_group) from student;

+-----------+
| hoc_group |
+-----------+
| first     |
| second    |
| third     |
| fifth     |
| fourth    |
+-----------+
```



## 四则运算

查询结果可进行四则运算，以下示例将展示拿到每个同学三科总分的操作

```sql
select name, html+css+js as 总成绩 from student;
+--------+-----------+
| name   | 总成绩    |
+--------+-----------+
| Yunya  |       257 |
| Jack   |       261 |
| Bella  |       231 |
| Dairis |       186 |
| Kyle   |       115 |
| Alice  |       130 |
| Ken    |       112 |
| Jason  |       273 |
| Tom    |       251 |
| Fiona  |       176 |
+--------+-----------+
```



## 显示格式

使用`concat()`可将查询结果与任意字符串进行拼接

使用`concat_ws()`可指定连接符进行拼接，第一个参数是连接符

```haskell
select concat("姓名->",name,"    ","性别->",gender) from student; # 合并成了一个字符串，注意用的空格分隔开的，不然会黏在一起

+--------------------------------------------------+
| concat("姓名->",name,"    ","性别->",gender)     |
+--------------------------------------------------+
| 姓名->Yunya    性别->male                        |
| 姓名->Jack    性别->male                         |
| 姓名->Bella    性别->famale                      |
| 姓名->Dairis    性别->famale                     |
| 姓名->Kyle    性别->famale                       |
| 姓名->Alice    性别->famale                      |
| 姓名->Ken    性别->male                          |
| 姓名->Jason    性别->male                        |
| 姓名->Tom    性别->male                          |
| 姓名->Fiona    性别->famale                      |
+--------------------------------------------------+
select concat_ws("|||",name,gender,age) from student;  # 使用|||为每个字段进行分割

+----------------------------------+
| concat_ws("|||",name,gender,age) |
+----------------------------------+
| Yunya|||male|||18                |
| Jack|||male|||17                 |
| Bella|||famale|||17              |
| Dairis|||famale|||18             |
| Kyle|||famale|||19               |
| Alice|||famale|||16              |
| Ken|||male|||16                  |
| Jason|||male|||21                |
| Tom|||male|||20                  |
| Fiona|||famale|||19              |
+----------------------------------+
```



# where

`where`条件是查询的第一道坎，能有效过滤出我们想要的任意数据



## 比较运算

使用比较运算符`> < >= <= !=`进行查询

以下示例将展示使用`where`过滤出`js`成绩大于80分的同学

```sql
select name, js from student where js > 80;

+-------+----+
| name  | js |
+-------+----+
| Jack  | 88 |
| Bella | 91 |
| Jason | 90 |
| Tom   | 91 |
+-------+----+
```



## 逻辑运算

使用`and or not`可进行逻辑运算与多条件查询

以下示例将展示使用`where`多条件查询过滤出各科成绩都大于80分的同学

```sql
select name, html, css, js from student where html > 80 and css > 80 and js > 80;

+-------+------+-----+----+
| name  | html | css | js |
+-------+------+-----+----+
| Jack  |   92 |  81 | 88 |
| Jason |   91 |  92 | 90 |
+-------+------+-----+----+
```



## 成员运算

`in`可以在特定的值中进行获取，如`in(80,90,100)`则代表只取80或者90或者100的这几条记录。

以下示例将展示只取第一组`first`以及第二组`second`学生的个人信息

```smalltalk
select name, gender, age, hoc_group from student where hoc_group in ("first","second");

+-------+--------+-----+-----------+
| name  | gender | age | hoc_group |
+-------+--------+-----+-----------+
| Yunya | male   |  18 | first     |
| Jack  | male   |  17 | second    |
| Bella | famale |  17 | first     |
| Alice | famale |  16 | second    |
+-------+--------+-----+-----------+
```



## between and

`between and`也是取区间的意思，

以下示例将展示使用`between and`过滤出`Js`成绩大于等于60并且小于80的同学

```sql
select name, js from student where js between 60 and 80;

+-------+----+
| name  | js |
+-------+----+
| Yunya | 76 |
| Kyle  | 60 |
+-------+----+
```



## like

`like`是模糊查询，其中`%`代表任意多个字符（类似于贪婪匹配的通配符`.*`），`_`代表任意一个字符（类似于非贪婪匹配的通配符`.*?`）。

以下示例将展示使用`like/%`匹配出姓名以`k`开头的所有同学的名字

```sql
select name from student where name like "k%";

+------+
| name |
+------+
| Kyle |
| Ken  |
+------+
```

以下示例将展示使用`like/_`匹配出姓名以`k`开头并整体长度为3的同学的名字

```sql
select name from student where name like "k__";

+------+
| name |
+------+
| Ken  |
+------+
```



## 正则匹配

使用`RegExp`可进行正则匹配，以下示例将展示使用正则匹配出名字中带有`k`的所有同学姓名

```sql
select name from student where name REGEXP "k+";

+------+
| name |
+------+
| Jack |
| Kyle |
| Ken  |
+------+
```



# group by

分组行为发生在`where`条件之后，我们可以将查询到的记录按照某个相同字段进行归类，一般分组都会配合聚合函数进行使用。

需要注意的是`select`语句是排在`group by`条件之后的，因此聚合函数也能在`select`语句中使用。



## 基本使用

以下示例将展示对`hoc_group`字段进行分组。

> 我们按照`hoc_group`字段进行分组，那么`select`查询的字段只能是`hoc_group`字段，想要获取组内的其他字段相关信息，需要借助函数来完成

```smalltalk
select hoc_group from student group by hoc_group;

+-----------+
| hoc_group |
+-----------+
| fifth     |
| first     |
| fourth    |
| second    |
| third     |
+-----------+
```

如果不使用分组，则会产生重复的信息

```smalltalk
mysql> select hoc_group from student;
+-----------+
| hoc_group |
+-----------+
| first     |
| second    |
| first     |
| third     |
| fifth     |
| second    |
| third     |
| fourth    |
| fifth     |
| fourth    |
+-----------+
```



## group_concat

用什么字段名进行分组，在`select`查询时就只能查那个用于分组的字段，查询别的字段会抛出异常，会提示`sql_mode`异常。

我们将`Js`成绩大于`80`分的同学筛选出来并且按照`gender`字段进行分组，此外我们还想查看其所有满足条件同学的名字。

以下这样操作会抛出异常。

```vbnet
mysql> select gender,name from student where js > 80 group by gender;

ERROR 1055 (42000): Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'school.student.name' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
```

必须借助`group_concat()`函数来进行操作才能使我们的需求圆满完成。

```sql
select gender, group_concat(name)  from student where js > 80 group by gender;

+--------+--------------------+
| gender | group_concat(name) |
+--------+--------------------+
| male   | Jack,Jason,Tom     |
| famale | Bella              |
+--------+--------------------+
```



## 分组模式

`ONLY_FULL_GROUP_BY`要求`select`中的字段是在与`group by`中使用的字段

> 如果`group by`是主键或`unique not null`时可以在`select`中列出其他字段

```csharp
#查看MySQL 5.7默认的sql_mode如下：
mysql> select @@global.sql_mode;
ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION

#设置sql_mole如下操作(我们可以去掉ONLY_FULL_GROUP_BY模式)：
mysql> set global sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
```



## 聚合函数

聚合函数可以在`where`执行后的所有语句中使用，比如`having`，`select`等。

聚合函数一般是同分组进行配套使用，以下是常用的聚合函数。

| 函数名                         | 作用                       |
| ------------------------------ | -------------------------- |
| COUNT()                        | 对组内成员某一字段求个数   |
| MAX()                          | 对组内成员某一字段求最大值 |
| MIN()                          | 对组内成员某一字段求最小值 |
| AVG()                          | 对组内成员某一字段求平均值 |
| SUM()                          | 对组内成员某一字段求和     |
| 注意：不使用分组，则默认为一组 |                            |

以下示例将展示求每组的成绩总和

```sql
select hoc_group, sum(js+html+css) from student group by hoc_group;

+-----------+-------------------+
| hoc_group | sum(js+html+css) |
+-----------+-------------------+
| fifth     |               366 |
| first     |               488 |
| fourth    |               449 |
| second    |               391 |
| third     |               298 |
+-----------+-------------------+
```

以下示例将展示整个班级的平均成绩及总成绩（`round()`用于四舍五入操作）

```sql
select round(avg(html+js+css)) as 平均分 ,sum(html+js+css) as 总分 from student;

+-----------+--------+
| 平均分    | 总分   |
+-----------+--------+
|       199 |   1992 |
+-----------+--------+
```

以下示例将展示打印出总科成绩最高分数

```sql
select max(js+css+html) from student;

+------------------+
| max(js+css+html) |
+------------------+
|              273 |
+------------------+
```

以下示例将展示查看本班有多少男生，多少女生

```sql
select gender, count(id) from student group by gender;

+--------+-----------+
| gender | count(id) |
+--------+-----------+
| male   |         5 |
| famale |         5 |
+--------+-----------+
```



# having

`having`也可用于过滤操作



## 区别差异

执行优先级从高到低：`where`> `group by` > `having`

`where`发生在分组`group by`之前，因而`where`中可以有任意字段，但是绝对不能使用聚合函数。

`having`发生在分组`group by`之后，因而`having`中可以使用分组的字段，无法直接取到其他字段，可以使用聚合函数



## 示例演示

以下示例将展示使用`having`过滤取出每组总分数大于400的小组

```sql
select hoc_group, sum(html+css+js) from student group by hoc_group having sum(html+css+js) > 400;

+-----------+------------------+
| hoc_group | sum(html+css+js) |
+-----------+------------------+
| first     |              488 |
| fourth    |              449 |
+-----------+------------------+
```

以下示例将展示使用`having`过滤取出有处分的同学。（可以使用分组的字段，但不能使用其他字段）

```sql
select sanction, group_concat(name) from student group by sanction having sanction != "无";

+-----------+--------------------+
| sanction  | group_concat(name) |
+-----------+--------------------+
| 大处分    | Dairis,Kyle,Ken    |
| 小处分    | Bella              |
+-----------+--------------------+
```



# ordery by

`ordery by`用于对查询结果进行排序

默认的排序是按照主键进行排序的



## asc

`asc`用于升序排列，以下示例将展示按照每位同学的年龄进行升序排列，如果年龄相同则依照总成绩进行升序排列。

```sql
select id, name, age, html+css+js as 总成绩 from student order by age, html+css+js asc;

+----+--------+-----+-----------+
| id | name   | age | 总成绩    |
+----+--------+-----+-----------+
|  7 | Ken    |  16 |       112 |
|  6 | Alice  |  16 |       130 |
|  3 | Bella  |  17 |       231 |
|  2 | Jack   |  17 |       261 |
|  4 | Dairis |  18 |       186 |
|  1 | Yunya  |  18 |       257 |
|  5 | Kyle   |  19 |       115 |
| 10 | Fiona  |  19 |       176 |
|  9 | Tom    |  20 |       251 |
|  8 | Jason  |  21 |       273 |
+----+--------+-----+-----------+
```



## desc

`desc`用于降序排列，以下示例将展示按照每位同学的年龄进行降序排列。

```sql
select id, name, age, html+css+js as 总成绩 from student order by age desc;

+----+--------+-----+-----------+
| id | name   | age | 总成绩    |
+----+--------+-----+-----------+
|  8 | Jason  |  21 |       273 |
|  9 | Tom    |  20 |       251 |
|  5 | Kyle   |  19 |       115 |
| 10 | Fiona  |  19 |       176 |
|  1 | Yunya  |  18 |       257 |
|  4 | Dairis |  18 |       186 |
|  2 | Jack   |  17 |       261 |
|  3 | Bella  |  17 |       231 |
|  6 | Alice  |  16 |       130 |
|  7 | Ken    |  16 |       112 |
+----+--------+-----+-----------+
```



# limit

`limit`用于控制显示的条数



## 示例演示

按照总成绩进行降序排序，只打印`1-5`名。

```sql
 select id, name, age, html+css+js as 总成绩 from student  order by html+css+js desc limit 5;
 
+----+-------+-----+-----------+
| id | name  | age | 总成绩    |
+----+-------+-----+-----------+
|  8 | Jason |  21 |       273 |
|  2 | Jack  |  17 |       261 |
|  1 | Yunya |  18 |       257 |
|  9 | Tom   |  20 |       251 |
|  3 | Bella |  17 |       231 |
+----+-------+-----+-----------+
```

按照总成绩进行降序排序，只打印`6-8`名。

```sql
select id, name, age, html+css+js as 总成绩 from student  order by html+css+js desc limit 5,3; # 从第五名开始，打印三条。 6，7，8

+----+--------+-----+-----------+
| id | name   | age | 总成绩    |
+----+--------+-----+-----------+
|  4 | Dairis |  18 |       186 |
| 10 | Fiona  |  19 |       176 |
|  6 | Alice  |  16 |       130 |
+----+--------+-----+-----------+
```
[toc]

# 准备数据

```sql
create table department (
        id int unsigned auto_increment primary key,
        name char(12) not null unique # 部门名称唯一
);

create table teacher(
        id int unsigned auto_increment primary key,
        name char(12) not null,
        gender enum("male","famale") not null default "male",
        age tinyint unsigned not null,
        coaching_age tinyint unsigned not null, # 教龄
        salary int unsigned not null,
        dep_id int unsigned not null
);


insert into department(id,name) values
        (100,"管理部"),
        (200,"教学部"),
        (300,"财务部"),
        (500,"教务部");

insert into teacher(name,gender,age,coaching_age,salary,dep_id) values 
        ("TeacherZhang","male",32,8,9000,200),
        ("TeacherLi","male",34,10,12000,200),
        ("TeacherYun","male",26,4,21000,100),
        ("TeacherZhou","famale",24,2,4000,300),
        ("TeacherZhao","famale",32,12,23000,100),
        ("TeacherYang","male",28,6,3000,300),
        ("TeacherWang","famale",22,1,3200,400);
        
```

数据说明：老师表中有个部门编号为`400`的`TeacherWang`老师，没有对应的部门。部门表中有个编号为`500`的`教务部`，其中没有包含老师。



# 查询语法

```sql
SELECT DISTINCT(字段名1,字段名2) FROM 左表名 连接类型 JOIN 右表名
	ON 连表条件
	WHERE 筛选条件
	GROUP BY 分组字段
	HAVING 过滤条件
	ORDER BY 排序字段 asc/desc
	LIMIT 限制条数;
```



# 执行顺序

在单表查询的基础上，多表查询多了一些查询的步骤，因此执行顺序也与单表查询有所不同。

> 1.通过`from`找到将要查询的表（左表以及右表），生成一张虚拟的笛卡尔积表
>
> 2.使用`on`来过滤出笛卡尔积虚拟表中需要保留的字段
>
> 3.根据`连接类型 join`来对虚拟表的记录进行外部行的添加
>
> 4.`where`规定查询条件，在虚拟表记录中逐行进行查询并筛选出符合规则的记录
>
> 5.将查到的记录进行字段分组`group by`，如果没有进行分组，则默认为一组
>
> 6.将分组得到的结果进行`having`筛选，可使用聚合函数（`where`时不可使用聚合函数）
>
> 7.执行`select`准备打印
>
> 8.执行`distinct`对打印结果进行去重
>
> 9.执行`ordery by`对结果进行排序
>
> 10.执行`limit`对打印结果的条数进行限制



# 笛卡尔积

将两张表同时进行查询时，会产生一张笛卡尔积表。

该表是连表查询的基础，但是有很多无用的数据。

> 左表的每一行记录都会与右表中的每一行记录做一次连接，如下左表`teacher`有7条记录，右表`department`有4条记录，那么总共就有4*7条记录。
>
> 每次查询出的表都是一张虚拟表，存放于内存之中

```smalltalk
select * from teacher,department;

+----+--------------+--------+-----+--------------+--------+--------+-----+-----------+
| id | name         | gender | age | coaching_age | salary | dep_id | id  | name      |
+----+--------------+--------+-----+--------------+--------+--------+-----+-----------+
|  1 | TeacherZhang | male   |  32 |            8 |   9000 |    200 | 500 | 教务部    |
|  1 | TeacherZhang | male   |  32 |            8 |   9000 |    200 | 200 | 教学部    |
|  1 | TeacherZhang | male   |  32 |            8 |   9000 |    200 | 100 | 管理部    |
|  1 | TeacherZhang | male   |  32 |            8 |   9000 |    200 | 300 | 财务部    |
|  2 | TeacherLi    | male   |  34 |           10 |  12000 |    200 | 500 | 教务部    |
|  2 | TeacherLi    | male   |  34 |           10 |  12000 |    200 | 200 | 教学部    |
|  2 | TeacherLi    | male   |  34 |           10 |  12000 |    200 | 100 | 管理部    |
|  2 | TeacherLi    | male   |  34 |           10 |  12000 |    200 | 300 | 财务部    |
|  3 | TeacherYun   | male   |  26 |            4 |  21000 |    100 | 500 | 教务部    |
|  3 | TeacherYun   | male   |  26 |            4 |  21000 |    100 | 200 | 教学部    |
|  3 | TeacherYun   | male   |  26 |            4 |  21000 |    100 | 100 | 管理部    |
|  3 | TeacherYun   | male   |  26 |            4 |  21000 |    100 | 300 | 财务部    |
|  4 | TeacherZhou  | famale |  24 |            2 |   4000 |    300 | 500 | 教务部    |
|  4 | TeacherZhou  | famale |  24 |            2 |   4000 |    300 | 200 | 教学部    |
|  4 | TeacherZhou  | famale |  24 |            2 |   4000 |    300 | 100 | 管理部    |
|  4 | TeacherZhou  | famale |  24 |            2 |   4000 |    300 | 300 | 财务部    |
|  5 | TeacherZhao  | famale |  32 |           12 |  23000 |    100 | 500 | 教务部    |
|  5 | TeacherZhao  | famale |  32 |           12 |  23000 |    100 | 200 | 教学部    |
|  5 | TeacherZhao  | famale |  32 |           12 |  23000 |    100 | 100 | 管理部    |
|  5 | TeacherZhao  | famale |  32 |           12 |  23000 |    100 | 300 | 财务部    |
|  6 | TeacherYang  | male   |  28 |            6 |   3000 |    300 | 500 | 教务部    |
|  6 | TeacherYang  | male   |  28 |            6 |   3000 |    300 | 200 | 教学部    |
|  6 | TeacherYang  | male   |  28 |            6 |   3000 |    300 | 100 | 管理部    |
|  6 | TeacherYang  | male   |  28 |            6 |   3000 |    300 | 300 | 财务部    |
|  7 | TeacherWang  | famale |  22 |            1 |   3200 |    400 | 500 | 教务部    |
|  7 | TeacherWang  | famale |  22 |            1 |   3200 |    400 | 200 | 教学部    |
|  7 | TeacherWang  | famale |  22 |            1 |   3200 |    400 | 100 | 管理部    |
|  7 | TeacherWang  | famale |  22 |            1 |   3200 |    400 | 300 | 财务部    |
+----+--------------+--------+-----+--------------+--------+--------+-----+-----------+
```



# where连表

笛卡尔积表的数据非常全面，我们可以针对笛卡尔积表做一些条件限制使其能够拿到我们想要的数据。

如下所示，经过`where`条件过滤后，拿到了很精确的一张表。

```smalltalk
select * from teacher,department where teacher.dep_id = department.id;

+----+--------------+--------+-----+--------------+--------+--------+-----+-----------+
| id | name         | gender | age | coaching_age | salary | dep_id | id  | name      |
+----+--------------+--------+-----+--------------+--------+--------+-----+-----------+
|  1 | TeacherZhang | male   |  32 |            8 |   9000 |    200 | 200 | 教学部    |
|  2 | TeacherLi    | male   |  34 |           10 |  12000 |    200 | 200 | 教学部    |
|  3 | TeacherYun   | male   |  26 |            4 |  21000 |    100 | 100 | 管理部    |
|  4 | TeacherZhou  | famale |  24 |            2 |   4000 |    300 | 300 | 财务部    |
|  5 | TeacherZhao  | famale |  32 |           12 |  23000 |    100 | 100 | 管理部    |
|  6 | TeacherYang  | male   |  28 |            6 |   3000 |    300 | 300 | 财务部    |
+----+--------------+--------+-----+--------------+--------+--------+-----+-----------+
```

虽然使用`where`确实可以做到连表条件过滤剔除无用数据，但是强烈不建议用这种做法。

`MySQL`中提供了专门用于连表操作的连表条件过滤语法`on`，我们不应该使用`where`来做连表的条件过滤。

并且`where`连表还有一个缺点，左表`teacher`中有一个`TeacherWang`拿不出来，这是因为`TeacherWang`的部门编号`400`不在右表中，右表`department`中有一个部门编号为`500`的部门拿不出来，这是因为该部门下没有任何老师。

所以，忘记`where`连表吧。



# 连接查询

连接查询是`MySQL`中提供的连表操作语法。

在连接查询中，连表过滤应该使用`on`，而不应该使用`where`



## inner join

内连接的特点是拿到左表和右表中共有的部分，这与上面的`where`连接很相似。

```smalltalk
select * from teacher inner join department on (teacher.dep_id = department.id);

+----+--------------+--------+-----+--------------+--------+--------+-----+-----------+
| id | name         | gender | age | coaching_age | salary | dep_id | id  | name      |
+----+--------------+--------+-----+--------------+--------+--------+-----+-----------+
|  1 | TeacherZhang | male   |  32 |            8 |   9000 |    200 | 200 | 教学部    |
|  2 | TeacherLi    | male   |  34 |           10 |  12000 |    200 | 200 | 教学部    |
|  3 | TeacherYun   | male   |  26 |            4 |  21000 |    100 | 100 | 管理部    |
|  4 | TeacherZhou  | famale |  24 |            2 |   4000 |    300 | 300 | 财务部    |
|  5 | TeacherZhao  | famale |  32 |           12 |  23000 |    100 | 100 | 管理部    |
|  6 | TeacherYang  | male   |  28 |            6 |   3000 |    300 | 300 | 财务部    |
+----+--------------+--------+-----+--------------+--------+--------+-----+-----------+
```



## left join

左连接的特点是可以拿到左表和右表共有的部分并且还可以拿到左表独有的部分。

这样就可以拿出`TeachWang`了。

```smalltalk
select * from teacher left join department on (teacher.dep_id = department.id);

+----+--------------+--------+-----+--------------+--------+--------+------+-----------+
| id | name         | gender | age | coaching_age | salary | dep_id | id   | name      |
+----+--------------+--------+-----+--------------+--------+--------+------+-----------+
|  1 | TeacherZhang | male   |  32 |            8 |   9000 |    200 |  200 | 教学部    |
|  2 | TeacherLi    | male   |  34 |           10 |  12000 |    200 |  200 | 教学部    |
|  3 | TeacherYun   | male   |  26 |            4 |  21000 |    100 |  100 | 管理部    |
|  4 | TeacherZhou  | famale |  24 |            2 |   4000 |    300 |  300 | 财务部    |
|  5 | TeacherZhao  | famale |  32 |           12 |  23000 |    100 |  100 | 管理部    |
|  6 | TeacherYang  | male   |  28 |            6 |   3000 |    300 |  300 | 财务部    |
|  7 | TeacherWang  | famale |  22 |            1 |   3200 |    400 | NULL | NULL      |
+----+--------------+--------+-----+--------------+--------+--------+------+-----------+
```



## right join

右连接的特点是可以拿到左表和右表共有的部分并且还可以拿到右表独有的部分。

这样就可以拿出部门编号为`500`的`教务部`了。

```smalltalk
select * from teacher right join department on (teacher.dep_id = department.id);

+------+--------------+--------+------+--------------+--------+--------+-----+-----------+
| id   | name         | gender | age  | coaching_age | salary | dep_id | id  | name      |
+------+--------------+--------+------+--------------+--------+--------+-----+-----------+
|    1 | TeacherZhang | male   |   32 |            8 |   9000 |    200 | 200 | 教学部    |
|    2 | TeacherLi    | male   |   34 |           10 |  12000 |    200 | 200 | 教学部    |
|    3 | TeacherYun   | male   |   26 |            4 |  21000 |    100 | 100 | 管理部    |
|    4 | TeacherZhou  | famale |   24 |            2 |   4000 |    300 | 300 | 财务部    |
|    5 | TeacherZhao  | famale |   32 |           12 |  23000 |    100 | 100 | 管理部    |
|    6 | TeacherYang  | male   |   28 |            6 |   3000 |    300 | 300 | 财务部    |
| NULL | NULL         | NULL   | NULL |         NULL |   NULL |   NULL | 500 | 教务部    |
+------+--------------+--------+------+--------------+--------+--------+-----+-----------+
```



## full outer join

全外连接的特点是拿到左右两表中共有的部分，并且还可以拿到各自独有的部分。

遗憾的是`MySQL`中并不支持这种用法。

```sql
select * from teacher full outer join department on (teacher.dep_id = department.id);
```



## union

`MySQL`中尽管不支持`full outer join`，但是我们可以使用`left join`与`right join`结合出`full outer join`的功能。

使用`union`可将多个查询结果进行连接，但是要保证每个查询返回的列的数量与顺序要一样。

> `union`会过滤重复的结果
>
> `union all`不过滤重复结果
>
> 列表字段由是第一个查询的字段

```smalltalk
select * from teacher left join department on (teacher.dep_id = department.id)
union
select * from teacher right join department on (teacher.dep_id = department.id);

+------+--------------+--------+------+--------------+--------+--------+------+-----------+
| id   | name         | gender | age  | coaching_age | salary | dep_id | id   | name      |
+------+--------------+--------+------+--------------+--------+--------+------+-----------+
|    1 | TeacherZhang | male   |   32 |            8 |   9000 |    200 |  200 | 教学部    |
|    2 | TeacherLi    | male   |   34 |           10 |  12000 |    200 |  200 | 教学部    |
|    3 | TeacherYun   | male   |   26 |            4 |  21000 |    100 |  100 | 管理部    |
|    4 | TeacherZhou  | famale |   24 |            2 |   4000 |    300 |  300 | 财务部    |
|    5 | TeacherZhao  | famale |   32 |           12 |  23000 |    100 |  100 | 管理部    |
|    6 | TeacherYang  | male   |   28 |            6 |   3000 |    300 |  300 | 财务部    |
|    7 | TeacherWang  | famale |   22 |            1 |   3200 |    400 | NULL | NULL      |
| NULL | NULL         | NULL   | NULL |         NULL |   NULL |   NULL |  500 | 教务部    |
+------+--------------+--------+------+--------------+--------+--------+------+-----------+
```



## 新手专区

如果你还是搞不懂内连接，左连接，外连接的区别，那么推荐你可以看一下`runoob.com`提供的这张图。

非常详细的举例了各种连接的差别

https://www.runoob.com/w3cnote/sql-join-image-explain.html



# 子查询

子查询是将一个查询语句嵌套在另一个查询语句中

因为每一次的查询结果都可以当作一个在内存中的临时表来进行看待，所以我们可以在这张临时表的基础上再次进行查询

子查询中可以包含：`IN`、`NOT IN`、`ANY`、`ALL`、`EXISTS`和 `NOT EXISTS`等关键字

还可以包含比较运算符：`=` 、`!=`、`>` 、`<`等

> 使用子查询先写子查询的内容



## 基本使用

查询管理部门的老师信息

```smalltalk
select * from teacher 
        where dep_id in
        (select id from department where name = "管理部");  # 先写下面，拿到管理部门的id号。实际上就等于 in（100）
        
+----+-------------+--------+-----+--------------+--------+--------+
| id | name        | gender | age | coaching_age | salary | dep_id |
+----+-------------+--------+-----+--------------+--------+--------+
|  3 | TeacherYun  | male   |  26 |            4 |  21000 |    100 |
|  5 | TeacherZhao | famale |  32 |           12 |  23000 |    100 |
+----+-------------+--------+-----+--------------+--------+--------+
```

查询薪资最高的部门，拿到部门名称

```sql
select * from department
        where id =
        (select dep_id from teacher group by dep_id having max(salary) limit 1);  # 先拿到薪资最高部门的id
        
+-----+-----------+
| id  | name      |
+-----+-----------+
| 100 | 管理部    |
+-----+-----------+
```

查询没人的部门的部门名称

```sql
select * from department
        where id not in
        (select dep_id from teacher);

+-----+-----------+
| id  | name      |
+-----+-----------+
| 500 | 教务部    |
+-----+-----------+
```

查询部门被撤销的老师（部门表中没这个部门）

```smalltalk
select * from teacher 
        where dep_id not in
        (select id from department);
        
+----+-------------+--------+-----+--------------+--------+--------+
| id | name        | gender | age | coaching_age | salary | dep_id |
+----+-------------+--------+-----+--------------+--------+--------+
|  7 | TeacherWang | famale |  22 |            1 |   3200 |    400 |
+----+-------------+--------+-----+--------------+--------+--------+        
```

写子查询就先写下面，再写上面。

![first](https://img2020.cnblogs.com/blog/1881426/202009/1881426-20200902004312871-30982633.gif)



## exists

这玩意儿是跟着`where`后面使用的，代表子查询结果是否为真

如果为真的话外边的查询才执行，否则将不执行

领导视察工作，如果教师平均薪资大于一万，则看一眼教师工资，如果不大于一万就不看。

```sql
select avg(salary) from teacher;  # 教师平均工资

+-------------+
| avg(salary) |
+-------------+
|  10742.8571 |
+-------------+

select name,salary from teacher
        where exists
        (select name from teacher having avg(salary) > 10000);
        
+--------------+--------+
| name         | salary |
+--------------+--------+
| TeacherZhang |   9000 |
| TeacherLi    |  12000 |
| TeacherYun   |  21000 |
| TeacherZhou  |   4000 |
| TeacherZhao  |  23000 |
| TeacherYang  |   3000 |
| TeacherWang  |   3200 |
+--------------+--------+
```



# 自连接

自连接`self join`是建立在子查询以及连接查询基础之上，即在上一次查询自己的记录中再连接并查询一次自己。

因为每次的查询都会建立一张虚拟表，所以我们可以用`as`为这张虚拟表取一个别名。

如下示例将展示查询每个部门中工资最少的教师信息。

```smalltalk
select * from teacher as t1   # 不仅仅可以给字段取别名，也可以为表取别名
	inner join
	(select min(salary) as min_salary from teacher group by (dep_id)) as t2  # 注意，虚拟表必须使用括号才能as取别名
	on t1.salary = t2.min_salary;

+----+--------------+--------+-----+--------------+--------+--------+------------+
| id | name         | gender | age | coaching_age | salary | dep_id | min_salary |
+----+--------------+--------+-----+--------------+--------+--------+------------+
|  1 | TeacherZhang | male   |  32 |            8 |   9000 |    200 |       9000 |
|  3 | TeacherYun   | male   |  26 |            4 |  21000 |    100 |      21000 |
|  6 | TeacherYang  | male   |  28 |            6 |   3000 |    300 |       3000 |
|  7 | TeacherWang  | famale |  22 |            1 |   3200 |    400 |       3200 |
+----+--------------+--------+-----+--------------+--------+--------+------------+
```

第一步：写子查询，拿到每组中最少的薪资，并且为这张虚拟表取名为`t2`

```sql
select min(salary) as min_salary from teacher group by (dep_id);

+------------+
| min_salary |
+------------+
|      21000 |
|       9000 |
|       3000 |
|       3200 |
+------------+
```

第二步：使用`inner join`进行连接查询，将物理表`t1`与虚拟表`t2`相连，拿到共有的部分，通过薪资来找到教师。

```smalltalk
select * from teacher as t1  
	inner join
	(select min(salary) as min_salary from teacher group by (dep_id)) as t2 
	on t1.salary = t2.min_salary;

+----+--------------+--------+-----+--------------+--------+--------+------------+
| id | name         | gender | age | coaching_age | salary | dep_id | min_salary |
+----+--------------+--------+-----+--------------+--------+--------+------------+
|  1 | TeacherZhang | male   |  32 |            8 |   9000 |    200 |       9000 |
|  3 | TeacherYun   | male   |  26 |            4 |  21000 |    100 |      21000 |
|  6 | TeacherYang  | male   |  28 |            6 |   3000 |    300 |       3000 |
|  7 | TeacherWang  | famale |  22 |            1 |   3200 |    400 |       3200 |
+----+--------------+--------+-----+--------------+--------+--------+------------+
```



# 三表查询

三表查询即多对多表关系查询，总体来说也不是很难。



## 准备数据

总有一些行业精英可以同时隶属于多个部门，而多个部门下也可能有多个人。

在此基础上建立多对多关系表格。

```sql
create table employee (
        id int auto_increment primary key,
        name char(12) not null,
        gender enum("male","famale") not null default "male",
        age tinyint unsigned not null,
        salary int unsigned not null
); -- 员工表

create table department (
        id int unsigned primary key,
        name char(12) not null
); -- 部门表

create table emp_dep(
        id int auto_increment primary key,
        emp_id int unsigned not null,
        dep_id int unsigned not null,
        unique(emp_id,dep_id)  # 应当设置联合唯一
); -- 关系表


insert into employee(name,gender,age,salary) values 
        ("Yunya","male",22,16000),
        ("Jack","male",25,18000),
        ("Bella","famale",24,12000),
        ("Maria","famale",22,8000),
        ("Tom","male",23,6000),
        ("Jason","male",28,32000),
        ("James","male",31,35000),
        ("Lisa","famale",36,28000);


insert into department(id,name) values
        (1001,"研发部"),
        (1002,"开发部"),
        (1003,"财务部"),
        (1004,"人事部");


insert into emp_dep(emp_id,dep_id) values 
        (1,1002),
        (2,1002),
        (3,1003),
        (4,1004),
        (5,1004),
        (6,1001),
        (6,1002),
        (7,1002),
        (7,1001),
        (7,1003),
        (8,1003),
        (8,1004);
```



## 思路解析

三表查询的思路很简单，先用左表与中间表进行查找，这时候就会得到一张虚拟的表。

```smalltalk
select * from employee 
        inner join emp_dep
        on employee.id = emp_dep.emp_id;

+----+-------+--------+-----+--------+----+--------+--------+
| id | name  | gender | age | salary | id | emp_id | dep_id |
+----+-------+--------+-----+--------+----+--------+--------+
|  1 | Yunya | male   |  22 |  16000 |  1 |      1 |   1002 |
|  2 | Jack  | male   |  25 |  18000 |  2 |      2 |   1002 |
|  3 | Bella | famale |  24 |  12000 |  3 |      3 |   1003 |
|  4 | Maria | famale |  22 |   8000 |  4 |      4 |   1004 |
|  5 | Tom   | male   |  23 |   6000 |  5 |      5 |   1004 |
|  6 | Jason | male   |  28 |  32000 |  6 |      6 |   1001 |
|  6 | Jason | male   |  28 |  32000 |  7 |      6 |   1002 |
|  7 | James | male   |  31 |  35000 |  9 |      7 |   1001 |
|  7 | James | male   |  31 |  35000 |  8 |      7 |   1002 |
|  7 | James | male   |  31 |  35000 | 10 |      7 |   1003 |
|  8 | Lisa  | famale |  36 |  28000 | 11 |      8 |   1003 |
|  8 | Lisa  | famale |  36 |  28000 | 12 |      8 |   1004 |
+----+-------+--------+-----+--------+----+--------+--------+
```

继续按照上面的思路，再将这将中间表与右表相连，就会得到完整的三表。

```smalltalk
select * from employee 
        inner join emp_dep
        on employee.id = emp_dep.emp_id
        inner join department 
        on department.id = emp_dep.dep_id;
        
+----+-------+--------+-----+--------+----+--------+--------+------+-----------+
| id | name  | gender | age | salary | id | emp_id | dep_id | id   | name      |
+----+-------+--------+-----+--------+----+--------+--------+------+-----------+
|  1 | Yunya | male   |  22 |  16000 |  1 |      1 |   1002 | 1002 | 开发部    |
|  2 | Jack  | male   |  25 |  18000 |  2 |      2 |   1002 | 1002 | 开发部    |
|  3 | Bella | famale |  24 |  12000 |  3 |      3 |   1003 | 1003 | 财务部    |
|  4 | Maria | famale |  22 |   8000 |  4 |      4 |   1004 | 1004 | 人事部    |
|  5 | Tom   | male   |  23 |   6000 |  5 |      5 |   1004 | 1004 | 人事部    |
|  6 | Jason | male   |  28 |  32000 |  6 |      6 |   1001 | 1001 | 研发部    |
|  6 | Jason | male   |  28 |  32000 |  7 |      6 |   1002 | 1002 | 开发部    |
|  7 | James | male   |  31 |  35000 |  9 |      7 |   1001 | 1001 | 研发部    |
|  7 | James | male   |  31 |  35000 |  8 |      7 |   1002 | 1002 | 开发部    |
|  7 | James | male   |  31 |  35000 | 10 |      7 |   1003 | 1003 | 财务部    |
|  8 | Lisa  | famale |  36 |  28000 | 11 |      8 |   1003 | 1003 | 财务部    |
|  8 | Lisa  | famale |  36 |  28000 | 12 |      8 |   1004 | 1004 | 人事部    |
+----+-------+--------+-----+--------+----+--------+--------+------+-----------+
```



## 实例练习

拿到`James`所在的部门，打印其部门名称。

```sql
select name
from department
where id in (
                select dep_id
                from emp_dep
                        inner join employee on emp_dep.emp_id = employee.id
                where employee.name = "James"
        );
        
+-----------+
| name      |
+-----------+
| 研发部    |
| 开发部    |
| 财务部    |
+-----------+
```

查询开发部的所有人员工资情况

```sql
select name,salary
from employee
where id in (
                select emp_id
                from emp_dep
                        inner join department on emp_dep.dep_id = department.id
                where department.id = 1002
);


+-------+--------+
| name  | salary |
+-------+--------+
| Yunya |  16000 |
| Jack  |  18000 |
| Jason |  32000 |
| James |  35000 |
+-------+--------+
```

查询平均工资大于三万的部门名称

第一步，先用中间表和员工表拿出部门`id`再说

```sql
select dep_id from emp_dep
        inner join employee
        on employee.id = emp_dep.emp_Id
        group by dep_id 
        having avg(employee.salary) > 30000;

+--------+
| dep_id |
+--------+
|   1001 |
+--------+
```

第二步，让这张虚拟表和部门表进行关联，查询一下其名称即可。

```sql
select name
from department
where id in (
                select dep_id
                from emp_dep
                        inner join employee on employee.id = emp_dep.emp_Id
                group by dep_id
                having avg(employee.salary) > 30000
        );
        
+-----------+
| name      |
+-----------+
| 研发部    |
+-----------+
```
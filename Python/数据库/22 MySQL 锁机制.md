[toc]

# 锁机制

`MySQL`支持多线程操作，这就会造成数据安全问题。

一个用户在修改记录数据时，如果另一个用户也修改相同的记录数据则可能造成数据不一致的问题。

为了解决这个问题，可以使用锁操作来完成，即一个用户修改某一条记录数据时，其他用户只能排队等待上一个用户修改完成。

这在网络购物的库存数量上尤为明显。



# 行锁表锁

行锁是指用户A修改表中一条记录且筛选条件为索引列时，该条记录不能被其他用户同时修改。

区间行锁是指用户A修改表中多条记录且筛选条件为索引列时，这些记录不能被其他用户同时修改。

表锁是指用户A修改表中一条记录且筛选条件不是索引列时，该表所有记录都不能被其他用户修改。

**行锁与表锁现象的产生一定是依据筛选条件而定的**

`InnoDB`引擎支持行锁，因此拥有更高的并发处理能力

> 行锁开销大，锁表慢
>
> 行锁高并发下可并行处理，性能更高
>
> 行锁是针对索引加的锁，在通过索引检索时才会应用行锁，否则使用表锁
>
> 在事务执行过程中，随时都可以执行锁定，锁在执行`COMMIT`或者`ROLLBACK`的时候释放



## 行锁现象

为了模拟并发场景，需要开启两个终端进行测试。

准备数据如下：

```sql
-- 创建库存表
CREATE TABLE stock(
        id INT PRIMARY KEY AUTO_INCREMENT,
        name CHAR(12) NOT NULL,
        num INT UNSIGNED NOT NULL
);

-- 插入数据
INSERT INTO stock(name,num) VALUES
        ("苹果手机",100),
        ("三星手机",200),
        ("小米手机",500),
        ("华为手机",50);
```

终端1开启事务，令`id`为1的商品库存数量减1但不提交。

> 注意：筛选条件必须是索引才会引发行锁！

```sql
-- 终端1
BEGIN;
UPDATE stock SET num = stock.num-1 where id = 1;
```

此时终端2也开启事务，再对`id`为1的记录进行操作时，将会引发行锁现象。

```sql
-- 终端2
BEGIN;
UPDATE stock SET num = stock.num-10 where id = 1;
-- 卡住
```

但是终端2操纵其他记录则是没有问题的。

```sql
-- 终端2
UPDATE stock SET num = stock.num-10 where id = 2;

Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

只有等到终端1进行`COMMIT`或`ROLLBACK`操作后，终端2对`id`为1的记录操作才会继续进行。



## 表锁现象

为了模拟并发场景，需要开启两个终端进行测试

```sql
-- 创建库存表
CREATE TABLE stock(
        id INT PRIMARY KEY AUTO_INCREMENT,
        name CHAR(12) NOT NULL,
        num INT UNSIGNED NOT NULL
);

-- 插入数据
INSERT INTO stock(name,num) VALUES
        ("苹果手机",100),
        ("三星手机",200),
        ("小米手机",500),
        ("华为手机",50);
```

终端1开启事务，令`name`为苹果手机的商品库存数量减1但不提交。

> 注意：筛选条件不是主键索引，此时会引发表锁！

```sql
-- 终端1
BEGIN;
UPDATE stock SET num = stock.num-1 where name = "苹果手机";
```

终端2也开启事务，此时终端2对该表中任何记录都不能进行操作（查询操作除外），必须等到终端1的事务提交或回滚之后才行。

```sql
-- 终端2
BEGIN;
UPDATE stock SET num = stock.num-1 where name = "华为手机";
-- 卡住
```



# 悲观锁

悲观锁是指用户A在修改某一条记录数据时，其他用户则不能对该条记录进行任何操作（包括查询）。

悲观锁与筛选条件无关！

准备数据：

```sql
-- 创建库存表
CREATE TABLE stock(
        id INT PRIMARY KEY AUTO_INCREMENT,
        name CHAR(12) NOT NULL,
        num INT UNSIGNED NOT NULL
);

-- 插入数据
INSERT INTO stock(name,num) VALUES
        ("苹果手机",100),
        ("三星手机",200),
        ("小米手机",500),
        ("华为手机",50);
```

终端1修改苹果手机的库存-1，并对该条记录设置悲观锁，在终端1执行提交或回滚操作之前其他终端都不能操纵该条记录

```sql
-- 终端1
BEGIN;
SELECT * FROM stock FOR UPDATE; -- 为该表添加悲观锁
UPDATE stock SET num = stock.num-1 where name = "华为手机"; -- 进行更新
```

终端2无法使用以`FOR UPDATE`结尾的所有命令（包括查询）

```sql
-- 终端2
BEGIN;
SELECT * FROM stock WHERE id=1 FOR UPDATE;
-- 阻塞
```



# 乐观锁

在每次去拿数据的时候认为别人不会修改，不对数据进行上锁，但是在提交更新的时候会判断在此期间数据是否被更改，如果被更改则提交失败。

乐观锁更像是一种思路上解决的方案，而并不是用某些内部功能提供解决。

准备数据：

```sql
-- 创建库存表
CREATE TABLE stock(
        id INT PRIMARY KEY AUTO_INCREMENT,
        name CHAR(12) NOT NULL,
        num INT UNSIGNED NOT NULL,
        version INT UNSIGNED NOT NULL -- 版本更迭号，默认都为0
);

-- 插入数据
INSERT INTO stock(name,num,version) VALUES
        ("苹果手机",100,0),
        ("三星手机",200,0),
        ("小米手机",500,0),
        ("华为手机",50,0);
```

终端1上对`id`为1的产品库存做出调整，并修改其版本号。

```sql
BEGIN;
UPDATE stock SET 
        num = stock.num - 10,
        version = stock.version + 1
        where version = 0 and id = 1;
```

终端2上也对`id`为1的产品库存做出调整，但由于版本号不对修改则会阻塞住。

```sql
BEGIN;
UPDATE stock SET 
        num = stock.num - 10,
        version = stock.version + 1
        where version = 0 and id = 1;
-- 阻塞
```



# 读锁写锁

针对一些不支持事务的存储引擎，可以使用读锁与写锁的方式来控制业务。



## 读锁

为表设置读锁后，当前会话和其他会话都不可以修改数据，但可以读取表数据。

```sql
LOCK TABLE 表名 READ; -- 设置读锁

	-- 业务逻辑

UNLOCK TABLES; -- 解除读锁
```



## 写锁

为表设置了写锁后，当前会话可以修改，查询表，其他会话将无法操作。

```sql
LOCK TABLE 表名 WRITE; -- 设置写锁

	-- 业务逻辑

UNLOCK TABLES; -- 解除写锁
```
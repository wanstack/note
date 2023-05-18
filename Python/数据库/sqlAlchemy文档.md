

[toc]



### 1. MySQL常见操作

- 创建数据库

　　　　create database fuzjtest

- 删除数据库

　　　　drop database fuzjtest

- 查询数据库

　　　　show databases

- 切换数据库

　　　　use databas 123123 ###用户授权

- 创建用户

　　　　create user '用户名'@'IP地址' identified by '密码';

- 删除用户

　　　　drop user '用户名'@'IP地址';

- 修改用户

　　　　rename user '用户名'@'IP地址'; to '新用户名'@'IP地址';;

- 修改密码

　　　　set password for '用户名'@'IP地址' = Password('新密码')

- 查看权限

　　　　 show grants for '用户'@'IP地址'

- 授权

　　　　grant 权限 on 数据库.表 to '用户'@'IP地址'

- 取消权限
  revoke 权限 on 数据库.表 from '用户'@'IP地址'

  PS：用户权限相关数据保存在mysql数据库的user表中，所以也可以直接对其进行操作（不建议）



**相关权限：**

```mysql
all privileges  除grant外的所有权限
select          仅查权限
select,insert   查和插入权限
...
usage                   无访问权限
alter                   使用alter table
alter routine           使用alter procedure和drop procedure
create                  使用create table
create routine          使用create procedure
create temporary tables 使用create temporary tables
create user             使用create user、drop user、rename user和revoke  all privileges
create view             使用create view
delete                  使用delete
drop                    使用drop table
execute                 使用call和存储过程
file                    使用select into outfile 和 load data infile
grant option            使用grant 和 revoke
index                   使用index
insert                  使用insert
lock tables             使用lock table
process                 使用show full processlist
select                  使用select
show databases          使用show databases
show view               使用show view
update                  使用update
reload                  使用flush
shutdown                使用mysqladmin shutdown(关闭MySQL)
super                   使用change master、kill、logs、purge、master和set global。还允许mysqladmin 调试登陆
replication client      服务器位置的访问
replication slave       由复制从属使用
```

**对数据库授权**

```mysql
用户名@IP地址         用户只能在改IP下才能访问
用户名@192.168.1.%   用户只能在改IP段下才能访问(通配符%表示任意)
用户名@%             用户可以再任意IP下访问(默认IP地址为%)
```

**对用户和IP**

```mysql
用户名@IP地址         用户只能在改IP下才能访问
用户名@192.168.1.%   用户只能在改IP段下才能访问(通配符%表示任意)
用户名@%             用户可以再任意IP下访问(默认IP地址为%)
```

**实例**

```mysql
grant all privileges on db1.tb1 TO '用户名'@'IP'
grant select on db1.* TO '用户名'@'IP'
grant select,insert on *.* TO '用户名'@'IP'
revoke select on db1.tb1 from '用户名'@'IP'
```

**表操作**

创建表:

```mysql
create table 表名(
    列名  类型  是否可以为空，
    列名  类型  是否可以为空
)
```

参数:

```mysql
1.是否可空，null表示空，非字符串
          not null    - 不可空
          null        - 可空

2.默认值，创建列时可以指定默认值，当插入数据时如果未主动设置，则自动添加默认值
          create table tb1(
              nid int not null defalut 2,
              num int not null
          )
3.自增，如果为某列设置自增列，插入数据时无需设置此列，默认将自增（表中只能有一个自增列）
          create table tb1(
              nid int not null auto_increment primary key,
              num int null
          )
          或
          create table tb1(
              nid int not null auto_increment,
              num int null,
              index(nid)
          )
          注意：1、对于自增列，必须是索引（含主键）。
               2、对于自增可以设置步长和起始值
                   show session variables like 'auto_inc%';
                   set session auto_increment_increment=2;
                   set session auto_increment_offset=10;

                   shwo global  variables like 'auto_inc%';
                   set global auto_increment_increment=2;
                   set global auto_increment_offset=10;

 4.主键，一种特殊的唯一索引，不允许有空值，如果主键使用单个列，则它的值必须唯一，如果是多列，则其组合必须唯一。
          create table tb1(
              nid int not null auto_increment primary key,
              num int null
          )
          或
          create table tb1(
              nid int not null,
              num int not null,
              primary key(nid,num)
          )

 5.外键，一个特殊的索引，只能是指定内容
          creat table color(
              nid int not null primary key,
              name char(16) not null
          )

          create table fruit(
              nid int not null primary key,
              smt char(32) null ,
              color_id int not null,
              constraint fk_cc foreign key (color_id) references color(nid)
          )
```

- 删除表

　　　drop table 表名

- 清空表

  ​	delete from 表名
  ​	truncate table 表名

- 修改表

  - 添加列：

　　　　　　alter table 表名 add 列名 类型

- - 删除列：

　　　　　　alter table 表名 drop column 列名

- - 修改列：
    alter table 表名 modify column 列名 类型; -- 类型
    alter table 表名 change 原列名 新列名 类型; -- 列名，类型
  - 添加主键：
  - 删除主键：
    alter table 表名 drop primary key;
    alter table 表名 modify 列名 int, drop primary key;

- - 添加外键：

　　　　　　alter table 从表 add constraint 外键名称（形如：FK_从表_主表） foreign key 从表(外键字段) references 主表(主键字段);

- - 删除外键：

　　　　　　alter table 表名 drop foreign key 外键名称

- - 修改默认值：

　　　　　　ALTER TABLE testalter_tbl ALTER i SET DEFAULT 1000;

- - 删除默认值：

　　　　　　ALTER TABLE testalter_tbl ALTER i DROP DEFAULT;

#### 基本操作

- 增

```mysql
insert into 表 (列名,列名...) values (值,值,值...)
insert into 表 (列名,列名...) values (值,值,值...),(值,值,值...)
insert into 表 (列名,列名...) select (列名,列名...) from 表
```

 

- 删

```mysql
delete from 表
delete from 表 where id＝1 and name＝'fuzj'
```



- 改

```mysql
 update 表 set name ＝ 'fuzj' where id>1
```

 

- 查

```
select * from 表
select * from 表 where id > 1
select nid,name,gender as gg from 表 where id > 1
```

 高级操作

- 条件

  ```
  select * from 表 where id > 1 and name != 'alex' and num = 12;
  
  select * from 表 where id between 5 and 16;
  
  select * from 表 where id in (11,22,33)
  select * from 表 where id not in (11,22,33)
  select * from 表 where id in (select nid from 表)
  ```

   

- 通配符

  ```
  select * from 表 where name like 'ale%' - ale开头的所有（多个字符串）
  select * from 表 where name like 'ale_' - ale开头的所有（一个字符）
  ```

   

- 限制

  ```
  select * from 表 limit 5; - 前5行
  select * from 表 limit 4,5; - 从第4行开始的5行
  select * from 表 limit 5 offset 4 - 从第4行开始的5行
  ```

   

- 排序

  ```
  select * from 表 order by 列 asc - 根据 “列” 从小到大排列
  select * from 表 order by 列 desc - 根据 “列” 从大到小排列
  select * from 表 order by 列1 desc,列2 asc - 根据 “列1” 从大到小排列，如果相同则按列2从小到大排序
  ```

   

- 分组

  ```
  select num from 表 group by num
  select num,nid from 表 group by num,nid
  select num,nid from 表 where nid > 10 group by num,nid order nid desc
  select num,nid,count(*),sum(score),max(score),min(score) from 表 group by num,nid
  
  select num from 表 group by num having max(id) > 10
  
  特别的：group by 必须在where之后，order by之前
  ```

   

- 连表

  ```
  无对应关系则不显示
  select A.num, A.name, B.name
  from A,B
  Where A.nid = B.nid
  
  无对应关系则不显示
  select A.num, A.name, B.name
  from A inner join B
  on A.nid = B.nid
  
  A表所有显示，如果B中无对应关系，则值为null
  select A.num, A.name, B.name
  from A left join B
  on A.nid = B.nid
  
  B表所有显示，如果B中无对应关系，则值为null
  select A.num, A.name, B.name
  from A right join B
  on A.nid = B.nid
  ```

   

- 组合

  ```
  组合，自动处理重合
  select nickname
  from A
  union
  select name
  from B
  
  组合，不处理重合
  select nickname
  from A
  union all
  select name
  from B
  ```



### 2. Python操作MySQL

python3中第三方模块pymysql，提供python对mysql的操作
pip3 install pymysql



执行sql语句:

```python
import pymysql

# 创建连接
conn = pymysql.connect(host='127.0.0.1', port=3306, user='fuzj', passwd='123123', db='fuzj')

# 创建游标
cursor = conn.cursor()

conn.set_charset('utf-8')
# 执行SQL，并返回收影响行数
effect_row = cursor.execute("create table user (id int not NULL auto_increment primary key  ,name char(16) not null) ")    #创建一个user表
print(effect_row)
# 执行SQL，并返回受影响行数，使用占位符 实现动态传参
cursor.execute('SET CHARACTER SET utf8;')
effect_row = cursor.execute("insert into user (name) values (%s) ", ('323'))
effect_row = cursor.executemany("insert into user (name) values (%s) ", [('123',),('456',),('789',),('0',),('1',),('2',),('3',)])

#print(effect_row)
# 执行多个SQL，并返回受影响行数，列表中每个元素都相当于一个条件
effect_row = cursor.executemany("update user set name = %s WHERE  id = %s", [("fuzj",1),("jeck",2)])
print(effect_row)
```

- 获取新创建数据自增ID

```
#使用游标的lastrowid方法获取
new_id = cursor.lastrowid
```

- 获取查询数据

```python
import pymysql

# 创建连接
conn = pymysql.connect(host='127.0.0.1', port=3306, user='fuzj', passwd='123123', db='fuzj')

# 创建游标
cursor = conn.cursor()


cursor.execute("select * from user")

# 获取第一行数据
row_1 = cursor.fetchone()
print(row_1)
# 获取前n行数据
row_2 = cursor.fetchmany(3)
print(row_2)
# 获取所有数据
row_3 = cursor.fetchall()
print(row_3)
conn.commit()
cursor.close()
conn.close()

import pymysql

# 创建连接
conn = pymysql.connect(host='127.0.0.1', port=3306, user='fuzj', passwd='123123', db='fuzj')

# 创建游标
cursor = conn.cursor()


cursor.execute("select * from user")

# 获取第一行数据
row_1 = cursor.fetchone()
print(row_1)
# 获取前n行数据
row_2 = cursor.fetchmany(3)
print(row_2)
# 获取所有数据，返回元组形式
row_3 = cursor.fetchall()
print(row_3)
conn.commit()
cursor.close()
conn.close()
```

 

输出：

```
(1, 'fuzj')
((2, 'jeck'), (3, '323'), (4, '123'))
((5, '456'), (6, '789'), (7, '0'), (8, '1'), (9, '2'), (10, '3'), (11, '323'), (12, '123'), (13, '456'), (14, '789'), (15, '0'), (16, '1'), (17, '2'), (18, '3'), (19, '323'), (20, '123'), (21, '456'), (22, '789'), (23, '0'), (24, '1'), (25, '2'), (26, '3'))
```

 

注：在fetch数据时按照顺序进行，可以使用cursor.scroll(num,mode)来移动游标位置，如：

cursor.scroll(1,mode='relative') # 相对当前位置移动
cursor.scroll(2,mode='absolute') # 相对绝对位置移动

- fetch数据类型

```
import pymysql

# 创建连接
conn = pymysql.connect(host='127.0.0.1', port=3306, user='fuzj', passwd='123123', db='fuzj')

# 创建游标
#cursor = conn.cursor()
cursor = conn.cursor(cursor=pymysql.cursors.DictCursor)

cursor.execute("select * from user")

row_1 = cursor.fetchone()
print(row_1)
# 获取前n行数据
row_2 = cursor.fetchmany(3)
print(row_2)
# 获取所有数据
row_3 = cursor.fetchall()
print(row_3)
conn.commit()
cursor.close()
conn.close()
```

输出结果：

```
{'id': 1, 'name': 'fuzj'}
[{'id': 2, 'name': 'jeck'}, {'id': 3, 'name': '323'}, {'id': 4, 'name': '123'}]
[{'id': 5, 'name': '456'}, {'id': 6, 'name': '789'}, {'id': 7, 'name': '0'}, {'id': 8, 'name': '1'}, {'id': 9, 'name': '2'}, {'id': 10, 'name': '3'}, {'id': 11, 'name': '323'}, {'id': 12, 'name': '123'}, {'id': 13, 'name': '456'}, {'id': 14, 'name': '789'}, {'id': 15, 'name': '0'}, {'id': 16, 'name': '1'}, {'id': 17, 'name': '2'}, {'id': 18, 'name': '3'}, {'id': 19, 'name': '323'}, {'id': 20, 'name': '123'}, {'id': 21, 'name': '456'}, {'id': 22, 'name': '789'}, {'id': 23, 'name': '0'}, {'id': 24, 'name': '1'}, {'id': 25, 'name': '2'}, {'id': 26, 'name': '3'}]
```

 

### 3. ORM 框架（sqlAlchemy）

SQLAlchemy是Python中常用的一个ORM，SQLAlchemy分成三部分：

- ORM，就是我们用类来表示数据库schema的那部分
- SQLAlchemy Core，就是一些基础的操作，例如 `update`, `insert` 等等，也可以直接使用这部分来进行操作，但是它们写起来没有ORM那么自然
- DBAPI，这部分就是数据库驱动

它们的关系如下(图片来自官网)：

![SQLAlchemy 架构](sqlAlchemy\sqla_arch.png)

在连接数据库前，需要使用到一些配置信息，然后把它们组合成满足以下条件的字符串：

```
dialect+driver://username:password@host:port/database
```

- dialect：数据库，如：sqlite、mysql、oracle等
- driver：数据库驱动，用于连接数据库的，本文使用pymysql
- username：用户名
- password：密码
- host：IP地址
- port：端口
- database：数据库



```
HOST = 'localhost'
PORT = 3306
USERNAME = 'root'
PASSWORD = '123456'
DB = 'myclass'

# dialect + driver://username:passwor@host:port/database
DB_URI = f'mysql+pymysql://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DB}'
```

我们先来看看一个简单的例子：

```python
import contextlib
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    DateTime,
    String,
)
from config import config  # config模块里有自己写的配置，我们可以换成别的，注意下面用到config的地方也要一起换

engine = create_engine(
    config.SQLALCHEMY_DATABASE_URI,  # SQLAlchemy 数据库连接串，格式见下面
    echo=bool(config.SQLALCHEMY_ECHO),  # 是不是要把所执行的SQL打印出来，一般用于调试
    pool_size=int(config.SQLALCHEMY_POOL_SIZE),  # 连接池大小
    max_overflow=int(config.SQLALCHEMY_POOL_MAX_SIZE),  # 连接池最大的大小
    pool_recycle=int(config.SQLALCHEMY_POOL_RECYCLE),  # 多久时间主动回收连接，见下注释
)
Session = sessionmaker(bind=engine)
Base = declarative_base(engine)


class BaseMixin:
    """model的基类,所有model都必须继承"""
    id = Column(Integer, primary_key=True)
    created_at = Column(DateTime, nullable=False, default=datetime.datetime.now)
    updated_at = Column(DateTime, nullable=False, default=datetime.datetime.now, onupdate=datetime.datetime.now, index=True)
    deleted_at = Column(DateTime)  # 可以为空, 如果非空, 则为软删


@contextlib.contextmanager
def get_session():
    s = Session()
    try:
        yield s
        s.commit()
    except Exception as e:
        s.rollback()
        raise e
    finally:
        s.close()


class User(Base, BaseMixin):
    __tablename__ = "user"

    Name = Column(String(36), nullable=False)
    Phone = Column(String(36), nullable=False, unique=True)
```

我们注意上面的几点：

- pool_recycle，设置主动回收连接的时长，如果不设置，那么可能会遇到数据库主动断开连接的问题，例如MySQL通常会为连接设置 最大生命周期为八小时，如果没有通信，那么就会断开连接。因此不设置此选项可能就会遇到 `MySQL has gone away` 的报错。

- engine，engine是SQLAlchemy 中位于数据库驱动之上的一个抽象概念，它适配了各种数据库驱动，提供了连接池等功能。其用法就是 如上面例子中，`engine = create_engine`(<数据库连接串>)，数据库连接串的格式是 `dialect+driver://username:password@host:port/database?参数`

  这样的，dialect 可以是 `mysql`, `postgresql`,`oracle`,`mssql`,`sqlite`，后面的 driver 是驱动，比如MySQL的驱动pymysql， 如果不填写，就使用默认驱动。再往后就是用户名、密码、地址、端口、数据库、连接参数了，我们来看几个例子：

  - MySQL: `engine = create_engine('mysql+pymysql://scott:tiger@localhost/foo?charset=utf8mb4')`
  - PostgreSQL: `engine = create_engine('postgresql+psycopg2://scott:tiger@localhost/mydatabase')`
  - Oracle: `engine = create_engine('oracle+cx_oracle://scott:tiger@tnsname')`
  - MS SQL: `engine = create_engine('mssql+pymssql://scott:tiger@hostname:port/dbname')`
  - SQLite: `engine = create_engine('sqlite:////absolute/path/to/foo.db')`
  - 详见：https://docs.sqlalchemy.org/en/13/core/engines.html

- Session，Session的意思就是会话，也就是说，是一个逻辑组织的概念，因此，这需要靠你的业务逻辑来划分哪些操作使用同一个Session， 哪些操作又划分为不同的业务操作，详见 [这里](https://docs.sqlalchemy.org/en/13/orm/session_basics.html#session-faq-whentocreate)。 举个简单的例子，以web应用为例，一个请求里共用一个Session就是一个好的例子，一个异步任务执行过程中使用一个Session也是一个例子。 但是注意，不能直接使用Session，而是使用Session的实例，借助上面的代码，我们可以直接这样写：

  ```python
  with get_session() as s:
      print(s.query(User).first())
  ```

  - Base，Base是ORM中的一个基类，通过集成Base，我们才能方便的使用一些基本的查询，例如 `s.query(User).filter_by(User.name="nick").first()`。
  - BaseMixin，BaseMixin是我自己定义的一些通用的表结构，通过Mixin的方式集成到类里，比如上面的定义，我们常见的表结构里，都会有 ID、创建时间，更新时间，软删除标志等等，我们把它作为一个独立的类，这样通过继承即可获得相关表属性，省得重复写多次。

#### 表的设计

表的设计通常就如 `User` 表一样：

```python
class User(Base, BaseMixin):
    __tablename__ = "user"

    Name = Column(String(36), nullable=False)
    Phone = Column(String(36), nullable=False, unique=True)
```

首先使用 `__tablename__` 自定义表名，接着写各个表中的属性，也就是对应在数据库表中的列(column)，常见的类型有：

```bash
$ egrep '^class ' ~/.pyenv/versions/3.6.0/lib/python3.6/site-packages/sqlalchemy/sql/sqltypes.py
class _LookupExpressionAdapter(object):
class Concatenable(object):
class Indexable(object):
class String(Concatenable, TypeEngine):
class Text(String):
class Unicode(String):
class UnicodeText(Text):
class Integer(_LookupExpressionAdapter, TypeEngine):
class SmallInteger(Integer):
class BigInteger(Integer):
class Numeric(_LookupExpressionAdapter, TypeEngine):
class Float(Numeric):
class DateTime(_LookupExpressionAdapter, TypeEngine):
class Date(_LookupExpressionAdapter, TypeEngine):
class Time(_LookupExpressionAdapter, TypeEngine):
class _Binary(TypeEngine):
class LargeBinary(_Binary):
class Binary(LargeBinary):
class SchemaType(SchemaEventTarget):
class Enum(Emulated, String, SchemaType):
class PickleType(TypeDecorator):
class Boolean(Emulated, TypeEngine, SchemaType):
class _AbstractInterval(_LookupExpressionAdapter, TypeEngine):
class Interval(Emulated, _AbstractInterval, TypeDecorator):
class JSON(Indexable, TypeEngine):
class ARRAY(SchemaEventTarget, Indexable, Concatenable, TypeEngine):
class REAL(Float):
class FLOAT(Float):
class NUMERIC(Numeric):
class DECIMAL(Numeric):
class INTEGER(Integer):
class SMALLINT(SmallInteger):
class BIGINT(BigInteger):
class TIMESTAMP(DateTime):
class DATETIME(DateTime):
class DATE(Date):
class TIME(Time):
class TEXT(Text):
class CLOB(Text):
class VARCHAR(String):
class NVARCHAR(Unicode):
class CHAR(String):
class NCHAR(Unicode):
class BLOB(LargeBinary):
class BINARY(_Binary):
class VARBINARY(_Binary):
class BOOLEAN(Boolean):
class NullType(TypeEngine):
class MatchType(Boolean):
```

#### 常见操作

我们来看看使用SQLAlchemy完成常见的操作，例如增删查改

##### 查询操作

- `SELECT * FROM user` 应该这样写：

```python
with get_session() as s:
    print(s.query(User).all())
```

- `SELECT * FROM user WHERE name='nick'` 应该这样写：

```python
with get_session() as s:
    print(s.query(User).filter_by(User.name='nick').all())
    print(s.query(User).filter(User.name == 'nick').all())  # 这样写是等同效果的
```

- `SELECT * FROM user WHERE name='nick' LIMIT 1` 应该这样写：

```python
with get_session() as s:
    print(s.query(User).filter_by(User.name='nick').first())
```

如果需要加判定，例如确保只有一条数据，那就把 `first()` 替换为 `one()`，如果确保一行或者没有，那就写 `one_or_none()`。

- `SELECT * FROM user ORDER BY id DESC LIMIT 1` 应该这样写：

```python
with get_session() as s:
    print(s.query(User).order_by(User.id.desc()).first())
```

- `SELECT * FROM user ORDER BY id DESC LIMIT 1 OFFSET 20` 应该这样写：

```python
with get_session() as s:
    print(s.query(User).order_by(User.id.desc()).offset(20).first())
```

##### 删除操作

- `DELETE FROM user` 应该这样写：

```python
with get_session() as s:
    s.query(User).delete()
```

- `DELETE FROM user WHERE name='nick'`：

```python
with get_session() as s:
    s.query(User).filter_by(User.name='nick').delete()
```

- `DELETE FROM user WHERE name='nick' LIMIT 1`：

```python
with get_session() as s:
    s.query(User).filter_by(User.name='nick').limit(1).delete()
```

##### 更新语句

- `UPDATE user SET name='nick'`：

```python
with get_session() as s:
    s.query(User).update({'name': 'nick'})
```

- `UPDATE user SET name='nick' WHERE id=1`：

```python
with get_session() as s:
    s.query(User).filter_by(User.id=1).update({'name': 'nick'})
```

也可以通过更改实例的属性，然后提交：

```python
with get_session() as s:
    user = s.query(User).filter_by(User.id=1).one()
    user.name = 'nick'
    s.commit()
```

##### 插入语句

这个就简单了，实例化对象，然后 `session.add`，最后提交：

```python
with get_session() as s:
    user = User()
    s.add(user)
    s.commit()
```

##### 连表

SQLAlchemy 中可以直接使用join语句：

```python
with get_session() as s:
    s.query(Customer).join(Invoice).filter(Invoice.amount == 8500)
```

可以是这么几种写法：

```python
query.join(Address, User.id==Address.user_id)    # explicit condition
query.join(User.addresses)                       # specify relationship from left to right
query.join(Address, User.addresses)              # same, with explicit target
query.join('addresses')                          # same, using a string
```

### 4. 数据库migration（Alembic）

Alembic 是一款轻量型的数据库迁移工具，它与  SQLAlchemy 一起共同为 Python 提供数据库管理与迁移支持。

Alembic 使用 SQLAlchemy 作为数据库引擎，为关系型数据提供创建、管理、更改和调用的管理脚本，协助开发和运维人员在系统上线后对数据库进行在线管理。

同任何 Python 扩展库一样，我们可以通过 pip 来快速的安装最新的稳定版 Alembic 扩展库 `pip install alembic`。

#### 创建 Alembic 迁移环境

在使用 Alembic 之前需要先建立一个 Alembic 脚本环境，通过在工程目录下输入 `alembic init alembic` 命令可以快速在应用程序中建立 Alembic 脚本环境，当在命令行看到以下输出时，表示 alembic 脚本环境创建完成。

```python
[root@controller alembic_test]# alembic init alembic
  Creating directory /opt/alembic_test/alembic ...  done
  Creating directory /opt/alembic_test/alembic/versions ...  done
  Generating /opt/alembic_test/alembic/README ...  done
  Generating /opt/alembic_test/alembic.ini ...  done
  Generating /opt/alembic_test/alembic/env.py ...  done
  Generating /opt/alembic_test/alembic/script.py.mako ...  done
  Please edit configuration/connection/logging settings in '/opt/alembic_test/alembic.ini' before proceeding.

```

你可以通过 -t 选项来选择一个初始化的模板，Alembic 目前支持三个初始化模板「通过 `alembic list_templates` 可以查看支持的模板类型」，默认情况下使用的是通用模板，在大多数情况下使用通用模板即可。

生成的迁移脚本目录如下：

- **alembic 目录**：迁移脚本的根目录，放置在应用程序的根目录下，可以设置为任意名称。在多数据库应用程序可以为每个数据库单独设置一个 Alembic 脚本目录。
- **README 文件**：说明文件，初始化完成时没有什么意义。
- [env.py](https://link.zhihu.com/?target=http%3A//env.py/)**文件**：一个 python 文件，在调用 Alembic 命令时该脚本文件运行。
- **script.py.mako 文件**：是一个 mako 模板文件，用于生成新的迁移脚本文件。
- **versions 目录**：用于存放各个版本的迁移脚本。初始情况下为空目录，通过 `revision` 命令可以生成新的迁移脚本。

> alembic 会在你的应用程序的根目录下生成一个 `alembic.ini` 的配置文件，在开始任何的操作之前需要先修改该文件中的 `sqlalchemy.url` 指向你自己的数据库地址。

#### 生成迁移脚本

当 Alembic 配置环境创建完成后，可以通过 Alembic 的子命令 revision 来生成新的迁移脚本。

```shell
[root@controller alembic_test]# alembic revision -m "first create script"
  Generating /opt/alembic_test/alembic/versions/feb6e508030a_first_create_script.py ...  done

```

初始的迁移脚本中并没有实际有效的内容，相当于一个空白的模板文件「增加了版本信息」。如果对整改工程的数据表进行修改后，再次运行 revision 子命令可以看到新生成的脚本文件中的内容增加了我们对数据表的改变内容。

```shell
[root@controller alembic_test]# alembic revision -m "add create date in user table"
  Generating /opt/alembic_test/alembic/versions/e1be569c1227_add_create_date_in_user_table.py ...  done

```

此时在 alembic 文件夹中可以看到以下文件:

```shell
[root@controller alembic_test]# tree alembic
alembic
├── env.py
├── README
├── script.py.mako
└── versions
    ├── e1be569c1227_add_create_date_in_user_table.py
    ├── feb6e508030a_first_create_script.py
    └── __pycache__
        ├── e1be569c1227_add_create_date_in_user_table.cpython-36.pyc
        └── feb6e508030a_first_create_script.cpython-36.pyc
```

可以看到在 versions 目录中生成了两个迁移脚本文件，但是此时的迁移脚本文件中没有任何的有效代码，文件内容如下：

```python
[root@controller alembic_test]# more /opt/alembic_test/alembic/versions/e1be569c1227_add_create_date_in_user_table.py
"""add create date in user table

Revision ID: e1be569c1227
Revises: feb6e508030a
Create Date: 2023-01-31 14:35:14.941476

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'e1be569c1227'
down_revision = 'feb6e508030a'
branch_labels = None
depends_on = None


def upgrade():
    pass


def downgrade():
    pass

```

在该文件中制定了当前版本号 `revision` 和父版本号 `down_revision` ，以及相应的升级操作函数 `upgrade` 和降级操作函数 `dwongrade`。在 `upgrade` 和 `dwongrade` 函数中通过相应的 API 来操作 op 和 sa 对象来完成对数据库的修改，以下代码完成了在数据库中新增一个 account 数据表的功能。

```python
def upgrade():
    op.create_table(
        'account',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('name', sa.String(50), nullable=False),
        sa.Column('description', sa.Unicode(200)),
    )
def downgrade():
    op.drop_table('account')
```

每次编写完代码还需要手动编写迁移脚本这并不是程序员所需要的，幸运的是 Alembic 的开发者为程序员提供了更美好的操作「自动生成迁移脚本」。自动生成迁移脚本无需考虑数据库相关操作，只需完成 ROM 中相关类的编写即可，通过 Alembic 命令即可在数据库中自动完成数据表的生成和更新。在 Alembic 中通过 revision 子命令的 --autogrenerate 选项参数来生成自动迁移脚本。

在使用自动生成命令之前，需要在 env.py 文件中修改 target_metadata 配置使其指向应用程序中的元数据对象。

```python
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)) +"/../")

...
from models import Base

# add your model's MetaData object here
# for 'autogenerate' support
# from myapp import mymodel
# target_metadata = mymodel.Base.metadata
# target_metadata = None
target_metadata = Base.metadata
```



models.py

```python
[root@controller alembic_test]# cat models.py 
import contextlib
import datetime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    DateTime,
    String,
)

Base = declarative_base() # SQLORM基类

class BaseMixin:
    """model的基类,所有model都必须继承"""
    id = Column(Integer, primary_key=True)
    created_at = Column(DateTime, nullable=False, default=datetime.datetime.now)
    updated_at = Column(DateTime, nullable=False, default=datetime.datetime.now, onupdate=datetime.datetime.now, index=True)
    deleted_at = Column(DateTime)  # 可以为空, 如果非空, 则为软删

class User(Base, BaseMixin):
    __tablename__ = "user"

    Name = Column(String(36), nullable=False)
    Phone = Column(String(36), nullable=False, unique=True)
    Age = Column(Integer, nullable=False, unique=False)
    hight = Column(Integer, nullable=False, unique=False)


```

在 user 数据表中新增 Age 数据列，然后使用自动生成迁移脚本命令，查看我们的配置是否完成。运行命令后可以看到以下信息：

```shell
[root@controller alembic_test]# alembic revision --autogenerate -m "add age column"
INFO  [alembic.runtime.migration] Context impl MySQLImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
ERROR [alembic.util.messaging] Target database is not up to date.
  FAILED: Target database is not up to date.
```

出现该错误的原因是没有使用 Alembic 更新数据库，如果你没有手动创建数据表可以使用 `alembic upgrade head` 命令消除该错误，如果你已经通过命令行或其他方式创建了数据表，可以使用 `alembic stamp head` 命令来设置 Alembic 的状态。

```shell
[root@controller alembic_test]# alembic revision --autogenerate -m "add age column"
INFO  [alembic.runtime.migration] Context impl MySQLImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
INFO  [alembic.autogenerate.compare] Detected added column 'user.Age'
  Generating /opt/alembic_test/alembic/versions/ec6805a97544_add_age_column.py ...  done
  
[root@controller alembic_test]# tree alembic
alembic
├── 1.py
├── env.py
├── __pycache__
│   └── env.cpython-36.pyc
├── README
├── script.py.mako
└── versions
    ├── e1be569c1227_add_create_date_in_user_table.py
    ├── ec6805a97544_add_age_column.py
    ├── feb6e508030a_first_create_script.py
    └── __pycache__
        ├── e1be569c1227_add_create_date_in_user_table.cpython-36.pyc
        ├── ec6805a97544_add_age_column.cpython-36.pyc
        └── feb6e508030a_first_create_script.cpython-36.pyc

其中的 e1be569c1227 revision 在testabc数据库中的 alembic_version 表中可以查找到
MariaDB [testabc]> select * from testabc.alembic_version;
+--------------+
| version_num  |
+--------------+
| e1be569c1227 |
+--------------+


```

生成的迁移脚本文件内容如下：

```python
[root@controller alembic_test]# more /opt/alembic_test/alembic/versions/ec6805a97544_add_age_column.py
"""add age column

Revision ID: ec6805a97544
Revises: e1be569c1227
Create Date: 2023-01-31 16:47:33.341959

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'ec6805a97544'
down_revision = 'e1be569c1227'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('user', sa.Column('Age', sa.Integer(), nullable=False))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('user', 'Age')
    # ### end Alembic commands ###
```

#### 变更数据库

Alembic 最重要的功能是自动完成数据库的迁移「变更」，所做的配置以及生成的脚本文件都是为数据的迁移做准备的，数据库的迁移主要用到 `upgrade` 和 `downgrade` 子命令。

数据看的变更主要用到以下命令：

- **`alembic upgrade head`**：将数据库升级到最新版本。
- **`alembic downgrade base`**：将数据库降级到最初版本。
- **`alembic upgrade <version>`**：将数据库升级到指定版本。
- **`alembic downgrade <version>`**：将数据库降级到指定版本。
- **`alembic upgrade +2`**：相对升级，将数据库升级到当前版本后的两个版本。
- **`alembic downgrade +2`**：相对降级，将数据库降级到当前版本前的两个版本。

以上所有的升降级方式都是在线方式实时更新数据库文件，实际环境中总会存在一些环境无法在线升级，Alembic 提供了生成 SQL 脚本的形式，已提供离线升降级的功能。

```text
alembic upgrade <version> --sql > migration.sql
```

或

```text
alembic downgrade <version> --sql > migration.sql
```

随着项目的进展，项目下不可避免的会生成很多版本的迁移脚本，此时可以使用 `current` 来查看线上数据库处于什么版本，也可以通过 `history` 来查看项目目录中的迁移脚本信息。

```shell
[root@controller alembic_test]# alembic current
INFO  [alembic.runtime.migration] Context impl MySQLImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
e1be569c1227
[root@controller alembic_test]# alembic history --verbose
Rev: 7f4a175cc17e (head)
Parent: ec6805a97544
Path: /opt/alembic_test/alembic/versions/7f4a175cc17e_add_hight_column.py

    add hight column
    
    Revision ID: 7f4a175cc17e
    Revises: ec6805a97544
    Create Date: 2023-01-31 17:05:24.929598

Rev: ec6805a97544
Parent: e1be569c1227
Path: /opt/alembic_test/alembic/versions/ec6805a97544_add_age_column.py

    add age column
    
    Revision ID: ec6805a97544
    Revises: e1be569c1227
    Create Date: 2023-01-31 16:47:33.341959

Rev: e1be569c1227
Parent: feb6e508030a
Path: /opt/alembic_test/alembic/versions/e1be569c1227_add_create_date_in_user_table.py

    add create date in user table
    
    Revision ID: e1be569c1227
    Revises: feb6e508030a
    Create Date: 2023-01-31 14:35:14.941476

Rev: feb6e508030a
Parent: <base>
Path: /opt/alembic_test/alembic/versions/feb6e508030a_first_create_script.py

    first create script
    
    Revision ID: feb6e508030a
    Revises: 
    Create Date: 2023-01-31 14:31:14.530889
```



#### 举例

1. 在终端中，cd 到你的项目目录中，然后执行命令 alembic init alembic，创建一个名叫alembic的仓库。

2. 创建一个 models.py 模块，然后在里面定义你的模型类，示例代码如下：

```python
import contextlib
import datetime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    DateTime,
    String,
)

import conf

engine = create_engine(
    conf.config.SQLALCHEMY_DATABASE_URI,
    echo=bool(conf.config.SQLALCHEMY_ECHO),
    pool_size=int(conf.config.SQLALCHEMY_POOL_SIZE),
    max_overflow=int(conf.config.SQLALCHEMY_POOL_MAX_SIZE),
    pool_recycle=int(conf.config.SQLALCHEMY_POOL_RECYCLE),
)

Session = sessionmaker(bind=engine)
Base = declarative_base(engine) # SQLORM基类

class BaseMixin:
    """model的基类,所有model都必须继承"""
    id = Column(Integer, primary_key=True)
    created_at = Column(DateTime, nullable=False, default=datetime.datetime.now)
    updated_at = Column(DateTime, nullable=False, default=datetime.datetime.now, onupdate=datetime.datetime.now, index=True)
    deleted_at = Column(DateTime)  # 可以为空, 如果非空, 则为软删

class User(Base, BaseMixin):
    __tablename__ = "user"

    Name = Column(String(36), nullable=False)
    Phone = Column(String(36), nullable=False, unique=True)
    Age = Column(Integer(10), nullable=False, unique=False)

# Base.metadata.create_all()  # 将模型映射到数据库中
"""
@contextlib.contextmanager
def get_session():
    s = Session()
    try:
        yield s
        s.commit()
    except Exception as e:
        s.rollback()
        raise e
    finally:
        s.close()




with get_session() as s:
    print(s.query(User).first())
"""

```

和 models.py 同级目录下创建 conf.py 配置文件

```python
[root@controller alembic_test]# cat conf.py 
class config(object):
    SQLALCHEMY_DATABASE_URI = "mysql+pymysql://test:test@10.4.1.235:3306/testabc"
    SQLALCHEMY_ECHO = True
    SQLALCHEMY_POOL_SIZE = 10
    SQLALCHEMY_POOL_MAX_SIZE = 20
    SQLALCHEMY_POOL_RECYCLE = 16680


```



3. 修改配置文件

```shell
vim alembic.ini

sqlalchemy.url = sqlalchemy.url = mysql+pymysql://test:test@10.4.1.235/testabc
```

为了使用模型类更新数据库，需要在env.py文件中设置target_metadata，默认为target_metadata=None。使用sys模块把当前项目的路径导入到path中：

```python
import os 
import sys 

sys.path.append(os.path.dirname(os.path.abspath(__file__)) +"/../")

from models import Base 

...#省略代码

target_metadata = Base.metadata # 设置创建模型的元类

...#省略代码
```

4. 自动生成迁移文件

   使用 alembic revision --autogenerate -m "message"将当前模型中的状态生成迁移文件。

   ```shell
   [root@controller alembic_test]# alembic revision --autogenerate -m "add age column"
   INFO  [alembic.runtime.migration] Context impl MySQLImpl.
   INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
   ERROR [alembic.util.messaging] Target database is not up to date.
     FAILED: Target database is not up to date.
     
   
   ```

   出现该错误的原因是没有使用 Alembic 更新数据库，如果你没有手动创建数据表可以使用 `alembic upgrade head` 命令消除该错误，如果你已经通过命令行或其他方式创建了数据表，可以使用 `alembic stamp head` 命令来设置 Alembic 的状态。

   

   ```shell
   [root@controller alembic_test]# alembic revision --autogenerate -m "add age column"
   INFO  [alembic.runtime.migration] Context impl MySQLImpl.
   INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
   INFO  [alembic.autogenerate.compare] Detected added column 'user.Age'
     Generating /opt/alembic_test/alembic/versions/ec6805a97544_add_age_column.py ...  done
     
   [root@controller alembic_test]# tree alembic
   alembic
   ├── 1.py
   ├── env.py
   ├── __pycache__
   │   └── env.cpython-36.pyc
   ├── README
   ├── script.py.mako
   └── versions
       ├── e1be569c1227_add_create_date_in_user_table.py
       ├── ec6805a97544_add_age_column.py
       ├── feb6e508030a_first_create_script.py
       └── __pycache__
           ├── e1be569c1227_add_create_date_in_user_table.cpython-36.pyc
           ├── ec6805a97544_add_age_column.cpython-36.pyc
           └── feb6e508030a_first_create_script.cpython-36.pyc
   
   其中的 e1be569c1227 revision 在testabc数据库中的 alembic_version 表中可以查找到
   MariaDB [testabc]> select * from testabc.alembic_version;
   +--------------+
   | version_num  |
   +--------------+
   | e1be569c1227 |
   +--------------+
   
   MariaDB [testabc]> desc user;
   +------------+-------------+------+-----+---------+----------------+
   | Field      | Type        | Null | Key | Default | Extra          |
   +------------+-------------+------+-----+---------+----------------+
   | id         | int(11)     | NO   | PRI | NULL    | auto_increment |
   | created_at | datetime    | NO   |     | NULL    |                |
   | updated_at | datetime    | NO   | MUL | NULL    |                |
   | deleted_at | datetime    | YES  |     | NULL    |                |
   | Name       | varchar(36) | NO   |     | NULL    |                |
   | Phone      | varchar(36) | NO   | UNI | NULL    |                |
   +------------+-------------+------+-----+---------+----------------+
   6 rows in set (0.001 sec)
   
   可以看到此时数据库并未升级
   
   ```

   自动生成的升级和降级脚本:

   ```python
   [root@controller alembic_test]# more /opt/alembic_test/alembic/versions/ec6805a97544_add_age_column.py
   """add age column
   
   Revision ID: ec6805a97544
   Revises: e1be569c1227
   Create Date: 2023-01-31 16:47:33.341959
   
   """
   from alembic import op
   import sqlalchemy as sa
   
   
   # revision identifiers, used by Alembic.
   revision = 'ec6805a97544'
   down_revision = 'e1be569c1227'
   branch_labels = None
   depends_on = None
   
   
   def upgrade():
       # ### commands auto generated by Alembic - please adjust! ###
       op.add_column('user', sa.Column('Age', sa.Integer(), nullable=False))
       # ### end Alembic commands ###
   
   
   def downgrade():
       # ### commands auto generated by Alembic - please adjust! ###
       op.drop_column('user', 'Age')
       # ### end Alembic commands ###
   
   ```

   

5. 更新数据库

   使用alembic upgrade head将刚刚生成的迁移文件，真正映射到数据库中。同理，如果要降级，那么使用alembic downgrade head。

   ```shell
   [root@controller alembic_test]# alembic upgrade head
   INFO  [alembic.runtime.migration] Context impl MySQLImpl.
   INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
   INFO  [alembic.runtime.migration] Running upgrade e1be569c1227 -> ec6805a97544, add age column
   ```

   ```mysql
   MariaDB [testabc]> desc user;
   +------------+-------------+------+-----+---------+----------------+
   | Field      | Type        | Null | Key | Default | Extra          |
   +------------+-------------+------+-----+---------+----------------+
   | id         | int(11)     | NO   | PRI | NULL    | auto_increment |
   | created_at | datetime    | NO   |     | NULL    |                |
   | updated_at | datetime    | NO   | MUL | NULL    |                |
   | deleted_at | datetime    | YES  |     | NULL    |                |
   | Name       | varchar(36) | NO   |     | NULL    |                |
   | Phone      | varchar(36) | NO   | UNI | NULL    |                |
   +------------+-------------+------+-----+---------+----------------+
   6 rows in set (0.001 sec)
   
   MariaDB [testabc]> desc user;
   +------------+-------------+------+-----+---------+----------------+
   | Field      | Type        | Null | Key | Default | Extra          |
   +------------+-------------+------+-----+---------+----------------+
   | id         | int(11)     | NO   | PRI | NULL    | auto_increment |
   | created_at | datetime    | NO   |     | NULL    |                |
   | updated_at | datetime    | NO   | MUL | NULL    |                |
   | deleted_at | datetime    | YES  |     | NULL    |                |
   | Name       | varchar(36) | NO   |     | NULL    |                |
   | Phone      | varchar(36) | NO   | UNI | NULL    |                |
   | Age        | int(11)     | NO   |     | NULL    |                |
   +------------+-------------+------+-----+---------+----------------+
   7 rows in set (0.001 sec)
   
   对于两个数据库表结构表示升级成功。
   ```

   测试降级：

   ```shell
   [root@controller alembic_test]# alembic downgrade e1be569c1227
   INFO  [alembic.runtime.migration] Context impl MySQLImpl.
   INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
   INFO  [alembic.runtime.migration] Running downgrade 7f4a175cc17e -> ec6805a97544, add hight column
   INFO  [alembic.runtime.migration] Running downgrade ec6805a97544 -> e1be569c1227, add age column
   
   
   ```

   

6. 修改代码后，重复 4~5 步骤

### 5. Flask 中使用 Alembic

flask_migrate 是专门用来做 sqlalchemy 数据迁移的工具，当据模型发生变化的时可将修改后的模型重新映射到数据库中，这意味着数据库也将被修改。

本文介绍flask_migrate如何在flask项目中使用，所依赖的第三方库和版本信息如下:

```shell
pip install flask==1.1.4
pip install flask-script==2.0.6
pip install flask_migrate==2.7.0
pip install sqlalchemy==1.4.22
```



#### 1. 项目结构说明

本文用最小的项目结构来展示flask_migrate如何使用

![image-20230201090947104](sqlAlchemy\resize,m_fixed,w_1184)

一共有4个python需要编写，在project目录下有app.py, config.py，models.py， 和project同级目录下需要编写manager.py



config.py

```python

class Config():
    SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://test:test@10.4.1.235:3306/testabc"
    SQLALCHEMY_COMMIT_ON_TEARDOWN = True
    SECRET_KEY = 'secret key to protect from csrf'

    @staticmethod
    def init_app(app):
        pass
```

config.py 是flask项目的配置脚本，SQLALCHEMY_DATABASE_URI是数据的URI配置，sqlalchemy将根据这个配置选择用哪个第三方库作为引擎。

app.py

```python
from flask import Flask
from project.config import Config
from flask_sqlalchemy import SQLAlchemy


app = Flask(__name__)
app.config.from_object(Config)

db = SQLAlchemy()
Config.init_app(app)
db.init_app(app)

from project.models import *

@app.route('/')
def index():
    admin = db.session.query(User).filter(User.username =='admin').first()
    if admin is None:
        return {'status': 0, 'data': {}}
    else:
        print(admin.name_cn)
        return {'status': 1, 'data': {'username': admin.username, 'name_cn': admin.name_cn}}
```

app.py完成项目的初始化工作，同时提供了一个视图函数index，在index中将会返回管理员的信息。



models.py

```python
from project.app import db
from sqlalchemy import Column, String, Integer
from werkzeug.security import generate_password_hash


class User(db.Model):
    __tablename__ = 'user'
    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), nullable=False)
    password = Column(String(80), nullable=False)
    name_cn = Column(String(20), nullable=False)

    @classmethod
    def add_admin(cls):
        user = db.session.query(User).filter(User.username =='admin').first()
        if user is None:
            user = User(username='admin', password=generate_password_hash('123456'), name_cn='管理员')
            db.session.add(user)
            db.session.commit()
```

models.py 存放数据库模型，我只定义了一个user表，add_admin方法会向表中添加一个管理员。



manager.py

```python
from flask_script import Manager, Server
from flask_migrate import MigrateCommand, Migrate, upgrade
from project.app import app, db
from project.models import *

manager = Manager(app)
migrate = Migrate(app, db)
# 子命令  MigrateCommand 包含三个方法 init migrate upgrade
manager.add_command('db', MigrateCommand)
manager.add_command('start', Server(host="0.0.0.0", port=8000, use_debugger=True))  # 创建启动命令


@manager.command
def deploy():
    upgrade()
    User.add_admin()


if __name__ == '__main__':
    manager.run()
```

manager.py 负责管理项目，除了管理数据库，还有server的启动命令 start 和我自己创建的数据库部署命令deploy。



#### 2. 使用方法

flask_migrate 提供了很多命令，其中最为常用的是init, migrate, upgrade，第一次将数据模型映射到数据库中时，依次执行下面三个命令

```python
python manager.py db init
python manager.py db migrate
python manager.py db upgrade
```

在这以后，如果数据模型发生了变化，只需要执行migrate 和 upgrade。

执行完上述命令后，此时user表里还没有数据，执行命令

```shell
python manager.py deploy
```

会执行deploy函数，向user表中写入一条管理员数据，在项目初始阶段，个别的表需要预置一些数据，项目才能正常运行，这样做也可以方便测试。

最后执行命令

```shell
python manager.py start
```

会启动flask 服务，在浏览器里访问http://127.0.0.1:8000/ 得到如下响应

```python
{
  "data": {
    "name_cn": "\u7ba1\u7406\u5458", 
    "username": "admin"
  }, 
  "status": 1
}
```




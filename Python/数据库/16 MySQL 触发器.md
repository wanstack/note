[toc]

# 基础知识

触发器主要针对于用户对于数据表的**增删改**操作前以及操作后的行为。

触发器无法主动执行，必须由用户进行**增删改**操作后自动触发。

> 注意：没有查询



# 创建触发器

语法介绍：

```sql
# 插入前
CREATE TRIGGER 触发器名 BEFORE INSERT ON 表名 FOR EACH ROW
BEGIN
    ...
END

# 插入后
CREATE TRIGGER 触发器名 AFTER INSERT ON 表名 FOR EACH ROW
BEGIN
    ...
END

# 删除前
CREATE TRIGGER 触发器名 BEFORE DELETE ON 表名 FOR EACH ROW
BEGIN
    ...
END

# 删除后
CREATE TRIGGER 触发器名 AFTER DELETE ON 表名 FOR EACH ROW
BEGIN
    ...
END

# 更新前
CREATE TRIGGER 触发器名 BEFORE UPDATE ON 表名 FOR EACH ROW
BEGIN
    ...
END

# 更新后
CREATE TRIGGER 触发器名 AFTER UPDATE ON 表名 FOR EACH ROW
BEGIN
    ...
END
```



# 删除触发器

语法介绍：

```sql
drop trigger 触发器名;
```



# 示例演示

以下示例将演示当对`user`表进行插入与删除记录时，将会向`log`表中插入一条记录日志

> **NEW表示即将插入的数据行，OLD表示即将删除的数据行。**

```sql
-- 创建需要操作的表

CREATE TABLE user(
        id INT PRIMARY KEY auto_increment,
        name CHAR(32) not null,
        age tinyint not null,
        gender enum("famale","male"),
        role CHAR(64) default "user"
);

-- 创建日志表
CREATE TABLE log(
        id INT PRIMARY KEY auto_increment,
        username CHAR(32),
        message CHAR(64)
);


delimiter $ -- delimiter是指自定义结束符，mysql中以;号结束，使用自定义结束符后则以自定义结束符为准

        -- 创建触发器,插入之后
        CREATE TRIGGER user_after_insert AFTER INSERT ON user FOR EACH ROW  -- EACH ROW 代表每一行
        BEGIN
                IF NEW.role = "user" THEN -- 如果插入的角色是普通用户  NEW代表即将插入的行
                        INSERT INTO log(username,message) values
                                (NEW.name,"新增一位普通用户");
                ELSE 
                        INSERT INTO log(username,message) values
                                (NEW.name,"新增一位管理员用户");
                END IF; -- 结束必须加分号
        END $

        -- 创建触发器，删除之后
        CREATE TRIGGER user_after_delete AFTER DELETE ON user FOR EACH ROW 
        BEGIN
                IF OLD.role = "user" THEN -- 如果删除的角色是普通用户 OLD代表即将删除的行
                        INSERT INTO log(username,message) values 
                                (OLD.name,"删除一位普通用户");
                ELSE
                        INSERT INTO log(username,message) values
                                (OLD.name,"删除一位管理员用户");
                END IF;
        END $

delimiter ;
```
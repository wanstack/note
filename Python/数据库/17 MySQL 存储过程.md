[toc]

# 基础知识

存储过程包含一系列可执行的`SQL`语句，存储过程须存放于`MySQL`中，通过对存储过程名字的调用可执行其内部的`SQL`语句。

> 1.存储过程用于替代程序书写的`SQL`语句，以实现程序与`SQL`的解耦合
>
> 2.如果是基于网络传输，远程直接输入执行存储过程的名字即可，数据传输量较小
>
> 3.存储过程的缺点在于部门间沟通不便导致可扩展性降低



# 无参示例

存储过程是对一系列`SQL`语句的封装。在执行这一组`SQL`语句时，可使用名字进行调用。

```sql
delimiter $ -- delimiter是指自定义结束符，mysql中以;号结束，使用自定义结束符后则以自定义结束符为准
        CREATE PROCEDURE p1() -- 创建存储过程
        BEGIN 
                -- 书写程序逻辑
                SELECT * FROM t1;
                -- 其他逻辑
        END $
delimiter ;

-- MySQL调用
call p1();
```



# 有参示例

存储过程中的参数及返回值必须在传入时设置类型

返回值亦是如此

> in 仅用于传入的参数
>
> out 仅用于返回值使用
>
> inout 即可作为传入值也可传入返回值

```sql
delimiter $ -- delimiter是指自定义结束符，mysql中以;号结束，使用自定义结束符后则以自定义结束符为准

        CREATE PROCEDURE p2(in n1 int, out res int) -- 创建存储过程 参数1，传入参数，int类型，参数2，返回值，int类型
        BEGIN 
                -- 书写程序逻辑
                select id from t1 where id = n1;
                set res = 1;  -- 设置返回值
                -- 逻辑完毕
        END $ -- 存储过程创建完毕

delimiter ;


-- MySQL调用
set @res = 0; -- 先将接受返回值的变量进行定义

call p2(1,@res); -- 参数1，传入值，参数2，返回值

select @res; -- 查看返回值
```



# 删除语法

> drop procedure 存储过程名字;



# 异常处理

存储过程中可使用异常处理，但是`MySQL`的异常处理并不是太完善。

```sql
delimiter $ -- delimiter是指自定义结束符，mysql中以;号结束，使用自定义结束符后则以自定义结束符为准

        CREATE PROCEDURE p2(in n1 int, out res int) -- 创建存储过程 参数1，传入参数，int类型，参数2，返回值，int类型
        BEGIN 

                
                DECLARE EXIT HANDLER FOR SQLWARNING,NOT FOUND,SQLEXCEPTION  -- 异常捕捉 ， SQLWARNING：01开头的异常码，NOT FOUND:02开头的异常码，SQLEXCEPTION：其他数字开头的异常码
                BEGIN 
                        -- 异常逻辑书写区域
                        select "错误了";
                        set res = 0;
                END; 

                -- 书写正常逻辑，当出现异常时跑到上面执行异常的处理逻辑
                select * from nohavetable; -- 抛出异常，显示错误了。res为0
                select "正常了";

                set res = 1;

        END $ -- 存储过程创建完毕

delimiter ;


-- MySQL调用
set @res = 0; -- 先将接受返回值的变量进行ding'yi

call p2(1,@res); -- 参数1，传入值，参数2，返回值

select @res; -- 查看返回值
```

 
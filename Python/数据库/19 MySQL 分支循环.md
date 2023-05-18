[toc]

# 流程分支

```sql
delimiter $
        CREATE PROCEDURE proc_if () -- 创建存储过程
        BEGIN
        
                declare i int default 0;  -- 声明变量
                if i = 1 THEN
                        SELECT 1;
                ELSEIF i = 2 THEN
                        SELECT 2;
                ELSE
                        SELECT 7;
                END IF;

        END $
delimiter ;
```



# 循环介绍



## while循环

```delphi
delimiter $
        CREATE PROCEDURE proc_while () -- 创建存储过程
        BEGIN

                DECLARE num INT ;  -- 声明变量
                SET num = 0 ;  -- 初始值为0
                WHILE num < 10 DO
                        SELECT
                        num ;
                        SET num = num + 1 ;
                END WHILE ;

        END $
delimiter ;
```



## repeat循环

```delphi
delimiter $
        CREATE PROCEDURE proc_repeat () -- 创建存储过程
        BEGIN

                DECLARE i INT ;  -- 声明变量
                SET i = 0 ;
                repeat
                        select i; 
                        set i = i + 1;
                        until i >= 5
                end repeat;

        END $
delimiter ;
```



## loop循环

```delphi
delimiter $
        CREATE PROCEDURE proc_loop () -- 创建存储过程
        BEGIN
        
                declare i int default 0; -- 声明变量
                loop_label: loop
                        
                        set i=i+1;
                        if i<8 then
                        iterate loop_label;
                        end if;
                        if i>=10 then
                        leave loop_label;
                        end if;
                        select i;
                end loop loop_label;

        END$
delimiter ;
```
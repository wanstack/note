[toc]

# Navicat

`Navicat`是一款非常强大的可视化工具，可以让我们更加方便快捷的管理数据库，并且它是跨平台的，这意味着你可以在任何平台上使用它。

# 连接数据库

在下载完`Navicat`之后，我们需要对数据库进行连接，连接完成之后就可以做相应的操作了。

![image-20200903125611140](mysql_images/1881426-20200903142544796-2059438156.png)

`Navicat`中新建数据库十分简单，但是在创建时需要注意字符集的指定。

![image-20200903125806582](mysql_images/1881426-20200903142544130-741722333.png)

## 主键单表

所有的操作都是可视化的，使用十分便捷。

![image-20200903131251632](mysql_images/1881426-20200903142543531-2045329468.png)

也可以进行`SQL`预览来查看它的`SQL`语句

![image-20200903131314105](mysql_images/1881426-20200903142542982-1637227831.png)

最后记得使用`crtl+s`进行保存，并为你的数据表取一个名字。

接下来我们再来创建一张`emp`表。

![image-20200903131602475](mysql_images/1881426-20200903142542493-494955327.png)

## 外键多表

想让`dep`和`emp`表进行外键约束，我们可以使用设计表的功能。

当然这是在`emp`表上进行外键关联。

![image-20200903131857665](mysql_images/1881426-20200903142541867-347880335.png)

相当于添加了这一句。

```sql
ALTER TABLE `emp` ADD CONSTRAINT `fk_dep` FOREIGN KEY (`dep_id`) REFERENCES `dep` (`dep_id`) ON DELETE CASCADE ON UPDATE CASCADE;
```

# 记录操作

记录操作也都是可视化的，

![image-20200903133330682](mysql_images/1881426-20200903142541162-1042617614.png)

# 备份数据库

`Navicat`最强大的地方莫过于备份数据库。

![image-20200903133447137](mysql_images/1881426-20200903142540511-187930028.png)

使用提取`SQL`来看看它保存的信息，会依据`psc`生成一个`sql`文件

![image-20200903134619965](mysql_images/1881426-20200903142539744-1694785446.png)

![image-20200903134922431](mysql_images/1881426-20200903142539168-946971848.png)

该文档内部全是`SQL`语句。

![image-20200903134946842](mysql_images/1881426-20200903142538499-1895487360.png)

# 恢复数据库

我们只需要保存好原本的`psc`文件，将该文件保存到一个其他的地方。

需要恢复`db1`中的数据时，创建出`db1`数据库，再执行恢复选择`psc`文件即可完成恢复操作。
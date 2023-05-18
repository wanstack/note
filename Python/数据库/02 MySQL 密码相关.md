[toc]

# 登录用户

当`MySQL`客户端进行用户登陆之后，可以使用以下命令显示所登录的用户

```mysql
mysql> select user();
+----------------+
| user()         |
+----------------+
| root@localhost |
+----------------+
1 row in set (0.00 sec)

```

如果直接输入`mysql`命令而不指定用户名，则是以游客账户`ODBC@`进行登录

# 设置密码

初始的管理员`root`是没有密码的，我们可以使用以下命令为它设置密码，注意这个是在`CMD`环境下而不是登录到`MySQL`客户端之后才做的，语法格式为`mysqladmin -uroot -p旧密码 password新密码`

```bash
mysqladmin -uroot password "123"
mysqladmin -uroot -hcontroller -piAdBLsIQx4qSpVN password "123"
```

# 忘记密码

`MySQL`的`data`文件夹下默认会生成一个`mysql`数据库，其中有`user`表就是做登录授权验证的。

这使得`MySQL`必须先经过授权登录后才能进行一系列的操作，但是我们也可以通过一些技术手段绕过这个授权。

切记要使用管理员身份打开`CMD`

1.关闭需要授权登录的`MySQL`服务进程

```vbnet
net Stop MySQL
```

2.开启`MySQL`免授权登录的服务进程

```css
mysqld --skip-grant-tables
```

3.开启免授权登录的服务进程后可以再开启一个新的`CMD`命令终端，直接使用`root`用户进行登录而不用输入密码

```undefined
mysql -uroot
```

4.在`MySQL`登录状态下修改密码（使用`password()`函数进行加密，使得密码存储是以密文存储）

```sql
update mysql.user set authentication_string=password('yunya') where user = 'root' and host="localhost";
```

如果上述命令失效或抛出异常，可使用以下命令（我这里的环境是5.7版本，5.7以下的版本可尝试使用以下命令）

```sql
update mysql.user set password=password('yunya') where user = 'root' and host="localhost" and host="localhost";
```

5.立即刷新到磁盘

```lua
flush privileges；
```

6.退出

```bash
exit
```

7.关闭免授权的服务进程，重新启动需要授权登录的服务进程

```dos
tskill mysqld
net start MySQL  # 这里就是重新启动需要授权登录的服务进程
```

8.效果验证，登录成功

```shell
mysql -uroot -pyunya
```
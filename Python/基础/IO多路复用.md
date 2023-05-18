[toc]

# IO多路复用
## 1. 定义

同时监控多个IO事件，当哪个IO事件准备就绪就执行哪个IO事件。以此形成可以同时处理多个IO的行为，避免一个IO阻塞造成；

其他IO均无法执行，提高了IO执行效率。

## 2. 具体方案

    【1】select方法 ： windows linux unix
    
    【2】poll方法： linux unix
    
    【3】epoll方法： linux



### select 方法

    rs, ws, xs=select(rlist, wlist, xlist[, timeout])
    
    功能: 监控IO事件，阻塞等待IO发生
    
    参数：rlist 列表 存放关注的等待发生的IO事件
         wlist 列表 存放关注的要主动处理的IO事件
         xlist 列表 存放关注的出现异常要处理的IO
         timeout 超时时间
         
    返回值： rs 列表 rlist中准备就绪的IO
    		ws 列表 wlist中准备就绪的IO
            xs 列表 xlist中准备就绪的IO

select 实现tcp服务

    【1】 将关注的IO放入对应的监控类别列表
    【2】通过select函数进行监控
    【3】遍历select返回值列表，确定就绪IO事件
    【4】处理发生的IO事件
    注意
        wlist中如果存在IO事件，则select立即返回给ws
        处理IO过程中不要出现死循环占有服务端的情况
        IO多路复用消耗资源较少，效率较高

示例：

```python
"""
select tcp 服务
1.将关注的IO放入对应的监控类别列表
2.通过select函数进行监控
3.遍历select返回值列表，确定就绪IO事件
4.处理发生的IO事件
"""
 
from socket import *
from select import select
 
# 创建监听套接字作为关注IO
s = socket()
s.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
s.bind(('0.0.0.0', 8888))
s.listen(3)
 
# 设置关注列表
rlist = [s]  # 等待客户端连接
wlist = []
xlist = []
 
# 监控IO发生
while True:
    rs, ws, xs = select(rlist, wlist, xlist)
    # 遍历等待处理类型的IO（等待客户端连接）
    for r in rs:
        if r is s:
            # 有客户端连接
            c, addr = r.accept()
            print("Connect from", addr)
            rlist.append(c)  # 客户端连接对象加入监控
        else:
            # 如果是客户端连接发来信息
            data = r.recv(1024).decode()
            if not data:  # 断开连接
                rlist.remove(r)  # 取消对它关注
                r.close()
                continue
            print(data)
            # 将立即发送回复消息的IO添加到主动处理IO检测列表里会立即触发执行
            wlist.append(r)
 
    for w in ws:
        w.send(b'OK')
        wlist.remove(w)  # 从主动执行监控IO列表中移除
```

### poll方法

```python
p = select.poll()
功能 ： 创建poll对象
返回值： poll对象

p.register(fd,event)
功能: 注册关注的IO事件
参数：fd 要关注的IO
     event 要关注的IO事件类型
     常用类型：POLLIN 读IO事件（rlist）
             POLLOUT 写IO事件 (wlist)
			 POLLERR 异常IO （xlist）
			 POLLHUP 断开连接

比如：p.register(sockfd,POLLIN|POLLERR)


p.unregister(fd)
功能：取消对IO的关注
参数：IO对象或者IO对象的fileno


events = p.poll()
功能： 阻塞等待监控的IO事件发生
返回值： 返回发生的IO
        events格式 [(fileno,event),()....]
		每个元组为一个就绪IO，元组第一项是该IO的fileno，第二项为该IO就绪的事件类型

```

poll_server 步骤

```
【1】 创建套接字
【2】 将套接字register
【3】 创建查找字典，并维护
【4】 循环监控IO发生
【5】 处理发生的IO
```

```python
"""
    方法实现IO多路复用
【1】 创建套接字
【2】 将套接字register
【3】 创建查找字典，并维护
【4】 循环监控IO发生
【5】 处理发生的IO
"""
 
from socket import *
from select import *
 
# 创建套接字作为关注IO
s = socket()
s.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
s.bind(('0.0.0.0', 8888))
s.listen(3)
 
# 创建poll对象
p = poll()
 
# 建立查找字典，通过IO对象的fileno找到对象
# 字典内容与关注IO保持一直{fileno:io_obj}
fdmap = {s.fileno(): s}
 
# 关注s
p.register(s, POLLIN | POLLERR)
 
# 循环监控IO的发生
while True:
    events = p.poll()
    print(events)
    for fd, event in events:
        if fd == s.fileno():
            c, addr = fdmap[fd].accept()
            print("Connect from", addr)
            # 添加新的关注对象，同时维护字典
            p.register(c, POLLIN)
            fdmap[c.fileno()] = c
        elif event & POLLIN:
            data = fdmap[fd].recv(1024).decode()
            if not data:
                # 客户端退出
                p.unregister(fd)  # 取消关注
                fdmap[fd].close()
                del fdmap[fd]
                continue
            print(data)
            p.register(fd, POLLOUT)
        elif event & POLLOUT:
            fdmap[fd].send(b'OK')
            p.register(fd, POLLIN)
```



### epoll方法

```python
1. 使用方法 ：
	基本与poll相同
	生成对象改为 epoll()
	将所有事件类型改为EPOLL类型

 2. epoll特点：
	epoll 效率比select poll要高
	epoll 监控IO数量比select要多
	epoll 的触发方式比poll要多 （EPOLLET边缘触发）

```

```python
"""
    方法实现IO多路服用
【1】 创建套接字
【2】 将套接字register
【3】 创建查找字典，并维护
【4】 循环监控IO发生
【5】 处理发生的IO
"""
 
from socket import *
from select import *
 
# 创建套接字作为关注IO
s = socket()
s.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
s.bind(('127.0.0.1', 8888))
s.listen(3)
 
# 创建epoll对象
ep = epoll()
 
# 建立查找字典，通过IO对象的fileno找到对象
# 字典内容与关注IO保持一直{fileno:io_obj}
fdmap = {s.fileno(): s}
 
# 关注s
ep.register(s, EPOLLIN | EPOLLERR)
 
# 循环监控IO的发生
while True:
    events = ep.poll()
    print("你有新的IO需要处理哦：", events)
    for fd, event in events:
        if fd == s.fileno():
            c, addr = fdmap[fd].accept()
            print("Connect from", addr)
            # 添加新的关注对象，同时维护字典
            ep.register(c, EPOLLIN | EPOLLET)  # 边缘触发
            fdmap[c.fileno()] = c
        elif event & EPOLLIN:
            data = fdmap[fd].recv(1024).decode()
            if not data:
                # 客户端退出
                ep.unregister(fd)  # 取消关注
                fdmap[fd].close()
                del fdmap[fd]
                continue
            print(data)
            ep.unregister(fd)
            ep.register(fd, POLLOUT)
        elif event & POLLOUT:
            fdmap[fd].send(b'OK')
            ep.unregister(fd)
            ep.register(fd, POLLIN)
```




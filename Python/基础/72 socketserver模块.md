[toc]

# socketserver简介

在之前我们使用socket模块来构建服务器，但是使用该模块所编写的服务器处理请求都是串行的，即来一个处理一个，无疑这样的处理效率是十分低下的。

那么本篇文章将介绍socketserver模块的使用，它是对socket模块的更高级别封装，内部支持I/O多路复用机制，能够在最短的时间内处理更多的请求。

官方文档：[点我跳转](https://docs.python.org/zh-cn/3.6/library/socketserver.html)

# TCP/socketserver

下面是使用socketserver模块构建TCP服务器的基本格式：

```python
import socketserver


class Server(socketserver.BaseRequestHandler):

    def handle(self) -> None:
        # self.request == conn  ❶
        # self.client_address = clientAddr  ❷

        print("%s connect server" % self.client_address[0])

        while 1:
            try:
                data = self.request.recv(1024)

                if not data:
                    break

                print("receive client data : %s" % data.decode("u8"))
                self.request.send(data.upper())
            except ConnectionResetError as e:
                break

        print("%s close connect" % self.client_address[0])
        self.request.close()


if __name__ == "__main__":

    server = socketserver.ThreadingTCPServer(
        server_address=("localhost", 8888),
        RequestHandlerClass=Server
    )

    # run server
    server.serve_forever()

```

❶：self.request等同于双向链接通道conn

❷：self.client_address就是Client端的地址和端口信息

建立TCP/socketserver的步骤如下：

1. 导入socketserver模块
2. 创建一个新的类，并继承socketserver.BaseRequestHandler，重写其handle()方法，用于处理TCP请求
3. 写入交互逻辑
4. 防止客户端发送空信息以致双方卡死（针对Unix平台Client端异常关闭）
5. 防止客户端突然断开服务端抛出的ConnectionResetError异常（针对Windows平台Client端异常关闭）
6. 实例化socketserver.ThreadingTCPServer类，并传入自定义处理TCP请求的类和绑定ip+port
7. 调用socketserver.ThreadingTCPServer实例对象下的serve_forever()方法，启动服务

注意：socketserver模块实现的TCP服务器并不会提供粘包优化，所以需要自己手动实现。

可以看见，使用socketserver模块来构建TCP/socket服务器会简单很多，同时使用它创建的服务器还支持并发服务，而不再是串行服务。

# UDP/socketserver

下面是使用socketserver模块构建UDP服务器的基本格式：

```python
import socketserver

class Server(socketserver.BaseRequestHandler):
    
    def handle(self) -> None:
        # self.request == (message, server)  ❶
        # self.client_address = clientAddr  ❷
        
        data = self.request[0]
        server = self.request[1]
        
        print("receive client data : %s" % data.decode("u8"))
        server.sendto(data.upper(), self.client_address)
        
if __name__ == "__main__":

    server = socketserver.ThreadingUDPServer(
        server_address=("localhost", 8888),
        RequestHandlerClass=Server
    )

    # run server
    server.serve_forever()

```

❶：self.request和TCP的self.request不同，它不是双向链接通道conn，而是包含了信息与服务端本身

❷：self.client_address就是Client端的地址和端口信息

# TCP/socketserver解决粘包

使用socketserver模块来构建能够解决粘包的TCP服务器，以远程输入命令为例。

Server端代码如下：

```python
import json
import struct
import socketserver
import subprocess


class Server(socketserver.BaseRequestHandler):

    def handle(self) -> None:
        """
        处理通信
        """
        print("%s connect server" % self.client_address[0])
        while 1:
            try:
                command = self.request.recv(1024)
                if not command:
                    break
                self.main(command)
            except ConnectionResetError as e:
                break

        print("%s close connect" % self.client_address[0])
        self.request.close()

    def main(self, command):
        """
        通信处理的主体逻辑
        """
        dataBody = self.runCommand(command)
        sendData = self.encapsulate(dataBody)
        self.request.send(sendData)

    def runCommand(self, command):
        """
        运行命令，并返回结果
        Args:
            command string: 远程传入的命令
        Returns:
            string: 命令执行结果
        """
        result = subprocess.Popen(
            args=command.decode("u8"),
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        successOut = result.stdout.read()
        errorOut = result.stderr.read()

        return successOut or errorOut

    def encapsulate(self, dataBody):
        """
        对命令执行结果进行封装，自定义协议解决粘包问题
        Args:
            dataBody: 命令执行结果

        Returns:
            string: 封装完成的结果，格式是 '消息头长度 [消息头 {消息体长度} ] 消息体'
        """

        dataHeadDict = {
            "dataBodyLength": len(dataBody),
        }
        print("dataHeadDict: %r" %(dataHeadDict))

        dataHead = json.dumps(dataHeadDict).encode("u8")
        dataHeadLength = struct.pack("i", len(dataHead))

        sendData = dataHeadLength + dataHead + dataBody
        print("dataHead: %r" %dataHead)
        print("dataHeadLength: %r" %dataHeadLength)
        print("sendData: %r" %sendData)
        

        return sendData


if __name__ == "__main__":

    server = socketserver.ThreadingTCPServer(
        server_address=("localhost", 8888),
        RequestHandlerClass=Server
    )

    # run server
    server.serve_forever()

    
"""
        dataHeadDict: {'dataBodyLength': 471}
dataHead: b'{"dataBodyLength": 471}'
dataHeadLength: b'\x17\x00\x00\x00'
sendData: b'\x17\x00\x00\x00{"dataBodyLength": 471} \xc7\xfd\xb6\xaf\xc6\xf7 D \xd6\xd0\xb5\xc4\xbe\xed\xca\xc7 \xd0\xc2\xbc\xd3\xbe\xed\r\n \xbe\xed\xb5\xc4\xd0\xf2\xc1\xd0\xba\xc5\xca\xc7 0440-0059\r\n\r\n D:\\openstack_v\\source\\LearnPython \xb5\xc4\xc4\xbf\xc2\xbc\r\n\r\n2023/02/25  18:12    <DIR>          .\r\n2023/02/25  18:12    <DIR>          ..\r\n2023/02/25  18:12             1,126 client.py\r\n2023/02/25  17:30               956 firstlineconfig.sh\r\n2023/02/25  18:11             2,311 server.py\r\n2023/02/16  16:58    <DIR>          __pycache__\r\n               3 \xb8\xf6\xce\xc4\xbc\xfe          4,393 \xd7\xd6\xbd\xda\r\n               3 \xb8\xf6\xc4\xbf\xc2\xbc 41,191,809,024 \xbf\xc9\xd3\xc3\xd7\xd6\xbd\xda\r\n'

        """
```

Client端代码如下：

```python
import json
import struct

from socket import *

client = socket()
client.connect(("localhost", 8888))

while 1:
    command = input(">>>").strip()
    if not command:
        continue

    if command == "exit":
        break


    client.send(command.encode("u8"))

    # step01：接收数据头长度，也就是数据头字典的bufsize
    dataHeadLength = struct.unpack("i", client.recv(4))[0]

    # step02：提取数据头字典
    dataHeadDict = json.loads(client.recv(dataHeadLength))

    # step03：提取数据体长度和数据体类型
    dataBodyLength= dataHeadDict.get("dataBodyLength")

    print("dataHeadLength: %r" %(dataHeadLength))
    print("dataHeadDict: %r" %(dataHeadDict))
    print("dataBodyLength: %r" %(dataBodyLength))


    # step04：提取数据体
    dataBody = b""
    currentRecvDataBodyLength = 0
    while currentRecvDataBodyLength < dataBodyLength:
        currentRecvResult = client.recv(1024)
        dataBody += currentRecvResult
        currentRecvDataBodyLength += len(currentRecvResult)

    else:
        print(dataBody.decode("gbk"))


print("client close")
client.close()

"""
>>>dir
dataHeadLength: 23
dataHeadDict: {'dataBodyLength': 471}
dataBodyLength: 471
 驱动器 D 中的卷是 新加卷
 卷的序列号是 0440-0059

 D:\openstack_v\source\LearnPython 的目录

2023/02/25  18:12    <DIR>          .
2023/02/25  18:12    <DIR>          ..
2023/02/25  18:12             1,126 client.py
2023/02/25  17:30               956 firstlineconfig.sh
2023/02/25  18:11             2,311 server.py
2023/02/16  16:58    <DIR>          __pycache__
               3 个文件          4,393 字节
               3 个目录 41,191,809,024 可用字节
"""
```
[toc]

# os简介

os模块是 Python 内置模块，提供了各种使用Python对**操作系统**提供操纵的接口

以下举例部分常用方法和属性：

| 方法/属性                        | 描述                                                         |
| -------------------------------- | ------------------------------------------------------------ |
| os.curdir                        | 总是返回一个字符串，“.”，代指当前目录                        |
| os.pardir                        | 总是返回一个字符串，“…”，代指当前父级目录                    |
| os.sep                           | 返回当前平台下的路径分隔符，Windows下为“\”，Unix下为“/”      |
| os.linesep                       | 返回当前平台下的行终止符，Windows下为“\r\n”，Unix下为“\n”    |
| os.pathsep                       | 返回当前平台下的用于分割文件的分隔符，Windows下为“;”，Unix下为“:” |
| os.name                          | 返回当前平台的信息，Windows下为“nt”，Unix下为“posix”         |
| os.environ                       | 获取系统环境变量                                             |
| os.system(“command”)             | 运行shell命令                                                |
| os.listdir(“dirName”)            | 获取指定目录下的所有项目，相当于ls命令，以列表方式返回结果   |
| os.getcwd()                      | 获取当前脚本的工作目录，相当于pwd命令                        |
| os.chdir(“dirName”)              | 改变当前脚本的工作目录，相当于cd命令                         |
| os.makedir(“dirName”)            | 生成单级的空目录，相当于mkdir命令                            |
| os.makedirs(“dirName1/dirName2”) | 生成多层递归目录，相当于mkdir -p命令                         |
| os.rmdir(“dirName”)              | 删除单级的空目录                                             |
| os.removedirs(“dirName”)         | 删除多层递归目录，前提是该目录必须为空                       |
| os.remove(“fileName”)            | 删除一个文件                                                 |
| os.rename(“oldName”, “newName”)  | 重命名文件/目录                                              |
| os.path.abspath(“path”)          | 返回当前path的绝对路径                                       |
| os.path.split(“path”)            | 将path分为2部分，返回元组，索引0是路径，索引1是文件          |
| os.path.dirname(“path”)          | 返回path的路径部分，相当于上面方法的索引0                    |
| os.path.basename(“path”)         | 返回path的路径部分，相当于上面方法的索引1，如果path是以“/”或者“\”结尾，则返回None |
| os.path.join(“path1”, “path2”)   | 将多个path进行组合，相当于os.path.split()的反操作            |
| os.path.exists(“path”)           | 判断path是否存在，返回布尔值                                 |
| os.path.isabs(“path”)            | 判断path是否是绝对路径，返回布尔值                           |
| os.path.isfile(“path”)           | 判断path是否是一个文件路径，返回布尔值                       |
| os.path.isdir(“path”)            | 判断path是否是一个目录路径，返回布尔值                       |
| os.stat(“path”)                  | 获取path所指文件/目录的相关信息                              |
| os.path.getatime(“path”)         | 获取path所指文件/目录的最后存取时间                          |
| os.path.getmtime(“path”)         | 获取path所指文件/目录的最后修改时间                          |
| os.path.getsize(“path”)          | 获取path所指文件/目录的大小                                  |

# 平台信息

根据以下一些属性，可获取平台信息：

| 属性       | 描述                                                         |
| ---------- | ------------------------------------------------------------ |
| os.curdir  | 总是返回一个字符串，“.”，代指当前目录                        |
| os.pardir  | 总是返回一个字符串，“…”，代指当前父级目录                    |
| os.sep     | 返回当前平台下的路径分隔符，Windows下为“\”，Unix下为“/”      |
| os.linesep | 返回当前平台下的行终止符，Windows下为“\r\n”，Unix下为“\n”    |
| os.pathsep | 返回当前平台下的用于分割文件的分隔符，Windows下为“;”，Unix下为“:” |
| os.name    | 返回当前平台的信息，Windows下为“nt”，Unix下为“posix”         |
| os.environ | 获取系统环境变量                                             |

os.environ是一个全局字典，你可以将它当做普通字典进行操作。

```python
>>> os.environ
...
>>> os.environ["k1"] = "v1"
>>> os.environ.get("k1")
'v1'

```

此外，它是全局的，这意味着同一个项目之中任何地方都能随时获取到它，因此可以用它来存储一些较为私密的信息，如数据库链接IP+PORT+USER+PASSWORLD。

使用该字典时需要注意key必须是str类型，若是其他类型则会抛出异常。

# 目录操作

使用以下一些方法，可对目录做出操作：

| 方法                             | 描述                                                       |
| -------------------------------- | ---------------------------------------------------------- |
| os.system(“command”)             | 运行shell命令                                              |
| os.listdir(“dirName”)            | 获取指定目录下的所有项目，相当于ls命令，以列表方式返回结果 |
| os.getcwd()                      | 获取当前脚本的工作目录，相当于pwd命令                      |
| os.chdir(“dirName”)              | 改变当前脚本的工作目录，相当于cd命令                       |
| os.makedir(“dirName”)            | 生成单级的空目录，相当于mkdir命令                          |
| os.makedirs(“dirName1/dirName2”) | 生成多层递归目录，相当于mkdir -p命令                       |
| os.rmdir(“dirName”)              | 删除单级的空目录                                           |
| os.removedirs(“dirName”)         | 删除多层递归目录，前提是该目录必须为空                     |
| os.remove(“fileName”)            | 删除一个文件                                               |
| os.rename(“oldName”, “newName”)  | 重命名文件/目录                                            |

os.system()应该是一个比较常用的方法，它可以运行任何的shell命令：

```python
>>> os.system("tree .")
>>> os.system("ifconfig")
```

但是os.system()如果在Windows环境下的PyCharm中进行使用，则会抛出异常。

因为Windows平台执行命令的返回结果是采用GBK编码，而PyCharm中使用UTF8对结果进行解码就会产生乱码问题。

# 路径操作

路径操作应该是os模块中比较常用的：

| 方法                           | 描述                                                         |
| ------------------------------ | ------------------------------------------------------------ |
| os.path.abspath(“path”)        | 返回当前path的绝对路径                                       |
| os.path.split(“path”)          | 将path分为2部分，返回元组，索引0是路径，索引1是文件          |
| os.path.dirname(“path”)        | 返回path的路径部分，相当于上面方法的索引0                    |
| os.path.basename(“path”)       | 返回path的路径部分，相当于上面方法的索引1，如果path是以“/”或者“\”结尾，则返回None |
| os.path.join(“path1”, “path2”) | 将多个path进行组合，相当于os.path.split()的反操作            |
| os.path.exists(“path”)         | 判断path是否存在，返回布尔值                                 |
| os.path.isabs(“path”)          | 判断path是否是绝对路径，返回布尔值                           |
| os.path.isfile(“path”)         | 判断path是否是一个文件路径，返回布尔值                       |
| os.path.isdir(“path”)          | 判断path是否是一个目录路径，返回布尔值                       |

示例演示os.path.join()和os.path.split()：

```python
>>> dirName, fileName = os.path.split("/Users/yunya/document/os模块.md")
>>> dirName
'/Users/yunya/document'
>>> fileName
'os模块.md'
>>> newPath = os.path.join("/", "Users", "yunya", "document", "os模块.md")
>>> newPath
'/Users/yunya/document/os模块.md'
>>> 

```

# 信息获取

信息获取也有时候会用到：

| 方法                     | 描述                                |
| ------------------------ | ----------------------------------- |
| os.stat(“path”)          | 获取path所指文件/目录的相关信息     |
| os.path.getatime(“path”) | 获取path所指文件/目录的最后存取时间 |
| os.path.getmtime(“path”) | 获取path所指文件/目录的最后修改时间 |
| os.path.getsize(“path”)  | 获取path所指文件/目录的大小         |

# 项目模块查找

## 项目启动不了?

在之前介绍Python模块一章节中说到PyCharm和原生解释器在查找模块时的sys.path会有所不同。

PyCharm会自动的新增几行模块查找路径，而原生解释器则不会进行新增。

这样会产生一个问题，即项目上线后通过原生解释器进行启动项目时会发现找不到模块。

如，我们有一个下面结构的项目：

```python
Project
│
├── bin
│   └── run.py          # 入口文件
└── view
    ├── __init__.py
    └── views.py        # 视图层 定义了main()函数

```

当run.py进行执行后，Python工作目录就被定义在了Project/bin/run.py一层。

```python
from view.views import main

if __name__ == '__main__':
    main()

```

如果在PyCharm中执行run.py，则不会抛出异常，它能顺利的找到view模块，这是因为PyCharm将工作目录的上层、上上层也加入到了sys.path即模块查找路径中：

```python
[
'/Users/yunya/PycharmProjects/Project/bin', 
'/Users/yunya/PycharmProjects/Project', 
'...'
]


```

这样查找模块范围就会大很多：

```python
Project  # 上上层能找到
│
├── bin  # 上层找不到
│   └── run.py   # 本层找不到
└── view
    ├── __init__.py
    └── views.py    

```

但是如果在Python原生解释器环境下，调用执行run.py脚本，则会提示找不到view模块，因为view模块仅能在上上层被找到：

```python
Project  # 这里才能找到
│
├── bin       
│   └── run.py     # 找不到
└── view       
    ├── __init__.py
    └── views.py

```

如何解决这个问题？只需要在run.py脚本中将上上层路径加入至sys.path即可：

```python
import sys
import os
sys.path.append(os.path.abspath(os.path.dirname(os.path.dirname(__file__))))

from view.views import main


if __name__ == '__main__':
    main()

```

这样再次使用Python原生解释器通过run.py脚本启动项目，就不会发生任何问题了。

## OpenStack对路径的处理

在OpenStack中，对这种项目模块查找路径的处理采用了截然不同的方式：

```python
import os
import os, sys

print(os.path.abspath(__file__))
possible_topdir = os.path.normpath(os.path.join(  # ❶
    __file__,
    os.pardir,  # 上一级，相当于手动输入".."
    os.pardir,
))
print(possible_topdir)

```

❶：os.path.normpath()可以将一个不规范的路径变为规范路径

这样也能够达到相同的效果。

## Django3.x对路径的处理

Django3以前，对项目模块查找路径的处理采用了和我们相同的方式：

```python
BASE_DIR = os.path.dirname(os.path.dirname(__file__))
print(BASE_DIR)

```

在Django3之后，则使用pathlib模块代替了os模块，其实本质都是一样的：

```python
from pathlib import Path
root = Path(__file__)
res = root.parent.parent # ❶
print(res)

```

❶：取上层的上层

补充一点pathlib的知识，对于pathlib的路径拼接直接使用 / 符号即可，符号左边为Path对象，右边为str类型。

与os.path.join()拥有相同的效果。

```python
print(Path("User/YunYa") / r"a/b/c")

# User\YunYa\a\b\c

```

无论是os.path.join()还是pathlib的/进行路径拼接，都会选择出适合当前平台的路径分隔符。



# sys简介

sys模块是Python内置模块，提供了各种**系统相关**的参数和函数。

以下举例部分常用方法和属性：

| 方法/属性                          | 描述                                                         |
| ---------------------------------- | ------------------------------------------------------------ |
| sys.platform                       | 返回操作系统平台名称                                         |
| sys.version                        | 获取Python解释程序的版本信息                                 |
| sys.builtin_module_names           | 获取内置的所有模块名，元组形式返回                           |
| sys.modules                        | 返回以加载至内存之中的模块及路径                             |
| sys.path                           | 返回模块在硬盘中的搜索路径                                   |
| sys.stdin                          | Python标准输入通道，input()函数的底层实现                    |
| sys.stdout                         | Python标准输出通道，print()函数的底层实现                    |
| sys.stderr                         | Python标准输入错误通道                                       |
| sys.getrecursionlimit()            | 获取当前Python中最大递归层级                                 |
| sys.setrecursionlimit()            | 设置当前Python中最大递归层级                                 |
| sys._getframe(0).f_code.co_name    | 获取被调用函数的名称                                         |
| sys._getframe(1).f_code.co_name    | 获取被调用函数是被哪一个函数所嵌套调用的，若不是被嵌套调用则返回module |
| sys._getframe().f_back.f_lineno    | 获取被调用函数在被调用时所处代码行数                         |
| sys._getframe().f_code.co_filename | 获取被调用函数所在模块文件名                                 |
| sys.getrefcount()                  | 获取对象的引用计数                                           |
| sys.argv                           | 获取通过脚本调用式传递的数据                                 |

# 修改递归层级

修改递归层级已经介绍过一次了，默认Python的最大递归层级是1000层，我们可以对其进行修改：

```python
>>> sys
>>> sys.getrecursionlimit()
1000
>>> sys.setrecursionlimit(10000)
>>> sys.getrecursionlimit()
10000

```

# 函数栈帧信息

sys._getframe()能够获取到函数的栈帧对象，我们知道函数的栈帧对象中封存了一些函数运行时的信息。

那么通过下面这些属性就能拿到函数里栈帧的某些数据：

- sys._getframe(0).f_code.co_name：获取被调用函数的名称
- sys._getframe(1).f_code.co_name：获取被调用函数是被哪一个函数所嵌套调用的，若不是被嵌套调用则返回module
- sys._getframe().f_back.f_lineno：获取被调用函数在被调用时所处代码行数
- sys._getframe().f_code.co_filename：获取被调用函数所在模块文件名

```python
import sys


def test():
    print(sys._getframe(0).f_code.co_name)
    print(sys._getframe(1).f_code.co_name)
    print(sys._getframe().f_back.f_lineno)
    print(sys._getframe().f_code.co_filename)


def test2():
    test()


test2()

"""
test
test2
12
D:/openstack_v/source/LearnPython/test1.py
"""
```

# 脚本传入参数

我们都知道Python解释器可以通过以下方式进行.py文件的调用：

```shell
$ python3 demo.py

```

但是你可能不知道通过sys.argv属性可以获取通过脚本调用式传递的数据，如下启动.py脚本时传入了1、2、3：

```python
$ python3 demo.py  1 2 3

```

那么现在sys.argv就会接受到这3个数据，变成下面的格式：

```python
sys.argv = ["scriptPath", "1", "2", "3"]

```

基于这个特性，我们来做一个下载模拟器：

```python
import random
import sys
import time


def download():
    scale = 40
    print("开始下载文件:{0}".format(sys.argv[2]).center(scale + 10, '-'))
    totalSize = random.randint(1000, 2000)
    currentSize = totalSize / scale
    for i in range(scale + 1):
        a = '█' * i
        b = '_' * (scale - i)
        c = (i / scale) * 100
        print('''\r{0:^3.2f}% | {1}{2} | {3:.2f}/{4:.2f}(MB)'''.format(c, a, b, currentSize * i, totalSize), end="")
        time.sleep(0.1)
    print("\n" + "执行结束".center(scale + 10, '-'))


def main():
    try:
        runFunc = eval(sys.argv[1])
    except Exception:
        print("输入有误！", file=sys.stderr)
        exit()
    else:
        runFunc()


if __name__ == '__main__':
    main()

```

启动时输入参数：

```shell
 python3 ./bin/run.py download test.text

```
[toc]

# functools简介

functools是非常强大的内置模块，它提供了许多装饰器与函数，适用于对所有可调用对象的应用。

[官方文档](https://docs.python.org/zh-cn/3.6/library/functools.html)

这里主要着重介绍2种常用的函数与装饰器，它们适用于绝大部分的场景。

| 函数/装饰器 | 描述                                                         |
| ----------- | ------------------------------------------------------------ |
| partial()   | 冻结可调用对象的某些参数，因此该函数也被称为偏函数           |
| @lru_cache  | 为函数提供缓存功能，当某一函数的两次调用参数均一致，则直接返回前一次调用的结果 |

在该模块中，我们之前也已经接触过它所提供的redue()与@warps装饰器，所以这里不再进行举例。

# partial()

传入1个可调用对象和它的某一个或多个调用参数，返回1个新的可调用对象，并且该对象中的某些参数是被固定的。

函数签名如下：

```python
functools.partial(func, *args, **keywords)

```

官方文档实现：

```python
def partial(func, *args, **keywords):
    def newfunc(*fargs, **fkeywords):
        newkeywords = keywords.copy()
        newkeywords.update(fkeywords)
        return func(*args, *fargs, **newkeywords)
    newfunc.func = func
    newfunc.args = args
    newfunc.keywords = keywords
    return newfunc

```

示例演示：

```python
import functools


def add(x, y):
    return x + y


# newFunc = add(1, 2)
newFunc = functools.partial(add, 1, 2)
print(newFunc())

# 3

```

再来一个2进制转10进制的函数：

```python
import functools

binToDecimal = functools.partial(int, base=2)
print(binToDecimal("110"))

# 6

```

# @lru_cache

一个为函数提供缓存功能的装饰器，缓存maxsize组传入参数，在下次以相同参数调用时直接返回上一次的结果。用以节约高开销或I/O函数的调用时间。

由于使用了字典存储缓存，所以被装饰的函数固定参数和关键字参数必须是可哈希的。

函数签名如下：

```python
@functools.lru_cache(maxsize=128, typed=False)

```

参数释义：

- 如果maxsize设置为None，LRU功能将被禁用且缓存数量无上限。maxsize设置为2的幂时可获得最佳性能。
- 如果typed设置为true，不同类型的函数参数将被分别缓存。例如，f(3)和f(3.0)将被视为不同而分别缓存。

一个简单的例子：

- 第一次运行函数，传入参数1和2，计算结果为3，缓存这2个参数和结果
- 第二次运行函数，传入参数1和2，查询缓存，缓存有就直接获得结果，根本不运行函数，所以没有看到print()的打印效果
- 第三次运行函数，传入参数1.0和2，查询缓存，由于typed为True，故严格区分浮点型和整形，再次运行函数，结果计算为3.0

如下示例：

```python
import functools


@functools.lru_cache(maxsize=128, typed=True)
def add(x, y):
    print("add run...")
    return x+y


print(add(1, 2))
print(add(1, 2))
print(add(1.0, 2))

# add run...
# 3
# 3
# add run...
# 3.0

```

乍一看之下好像没什么作用，不就是缓存了一下嘛，实际上，在对递归函数上加上该装饰器，性能将会得到质的提升。

如下示例了加上该装饰器函数求解上楼梯问题和不加该装饰器函数求解上楼梯问题的总计运行时间。

对35阶梯楼梯的计算，加了该装饰器的运行几乎是瞬间完成，而不加该装饰器大概需要耗费十秒左右：

```python
import functools
import time


@functools.lru_cache(maxsize=256, typed=False)
def haveCache(n):
    if n == 1:
        return 1
    if n == 2:
        return 2
    return haveCache(n - 1) + haveCache(n - 2)


def dontHaveCache(n):
    if n == 1:
        return 1
    if n == 2:
        return 2
    return dontHaveCache(n - 1) + dontHaveCache(n - 2)


s = time.time()
haveCache(35)
print("HaveCache - >", time.time() - s)

s = time.time()
dontHaveCache(35)
print("dontHaveCache - >", time.time() - s)

# HaveCache - > 0.0
# dontHaveCache - > 11.06638216972351

```

如果最大缓存设为2，则运行时间会慢一点，但是32阶的上楼梯问题也是在短短0.2秒之内得到解决了：

```python
@functools.lru_cache(maxsize=2, typed=False)
...


# HaveCache - > 0.23421168327331543

```

# typing模块的作用

1. 类型检查，防止运行时出现参数和返回值类型不符合。
2. 作为开发文档附加说明，方便使用者调用时传入和返回参数类型。
3. 该模块加入后并不会影响程序的运行，不会报正式的错误，只有提醒。

注意：typing模块只有在python3.5以上的版本中才可以使用，pycharm目前支持typing检查

```python
from typing import List, Tuple, Dict


def add(a: int, string: str, f: float, b: bool) -> Tuple[List, Tuple, Dict, bool]:
    list1 = list(range(a))
    tup = (string, string, string)
    d = {"a": f}
    bl = b
    return list1, tup, d, bl


print(add(5, "hhhh", 2.3, False))
([0, 1, 2, 3, 4], ('hhhh', 'hhhh', 'hhhh'), {'a': 2.3}, False)

```

- 在传入参数时通过"参数名:类型"的形式声明参数的类型；
- 返回结果通过"-> 结果类型"的形式声明结果的类型。
- 在调用的时候如果参数的类型不正确pycharm会有提醒，但不会影响程序的运行。
- 对于如list列表等，还可以规定得更加具体一些，如："-> List[str]”,规定返回的是列表，并且元素是字符串。

```python
from typing import List


def func(a: int, string: str) -> List[int or str]:  # 使用or关键字表示多种类型
    list1 = []
    list1.append(a)
    list1.append(string)
    return list1


func(1, 'a')
[1, 'a']

```

## **typing常用类型**

- int、long、float：整型、长整形、浮点型
- bool、str：布尔型、字符串类型
- List、 Tuple、 Dict、 Set：列表、元组、字典、集合
- Iterable、Iterator：可迭代类型、迭代器类型
- Generator：生成器类型
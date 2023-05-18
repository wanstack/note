[toc]

# 集合

[Python](https://so.csdn.net/so/search?q=Python&spm=1001.2101.3001.7020)中的集合（set）内部存储也采用hash存储，所以说它也可以归类为映射容器类型之中。

集合与字典有很多类似之处，你可以将集合理解为没有value的字典（仅有key）。

集合本身是可变的数据类型，但是其内部数据项必须是不可变的，能被hash()的对象，这与字典的key特性相同。

## 集合特性

集合特性如下：

- 集合是一个可变的容器类型
- 集合中的数据项必须是不可变类型
- 集合更多的是用来操纵数据，而不是存储数据

嗯，再说一个冷门知识点，集合的速度比字典的存读速度更快！因为它的数据项仅有1部分，而字典的数据项拥有2部分，即key与value

## 基本声明

以下是使用类实例化的形式进行对象声明：

```python
s = set((1, 2, 3, 4, 5))
print("value : %r\ntype : %r" % (s, type(s)))

# value : {1, 2, 3, 4, 5}
# type : <class 'set'>

```

也可以选择使用更方便的字面量形式进行对象声明，使用{}对数据项进行包裹，每个数据项间用逗号进行分割：

```python
s = {1, 2, 3, 4, 5}
print("value : %r\ntype : %r" % (s, type(s)))

# value : {1, 2, 3, 4, 5}
# type : <class 'set'>

```

注意一个集合声明的陷阱，如果要声明一个空集合必须使用类实例的形式进行声明。

如果用一个空的{}进行字面量声明会生成一个字典。

声明集合时，千万注意数据项只能是不可变类型。

仅可以使用字符串（str），整形（int），浮点型（float），布尔型（bool），元组类型（tuple）等等，使用其他可变类型作为数据项加入至集合中会抛出TypeError异常。

## 续行操作

在Python中，集合中的数据项如果过多，可能会导致整个集合太长，太长的集合是不符合PEP8规范的。

- 每行最大的字符数不可超过79，文档字符或者注释每行不可超过72

Python虽然提供了续行符\，但是在集合中可以忽略续行符，如下所示：

```python
s = {
    1,
    2,
    3,
    4,
    5
}
print("value : %r\ntype : %r" % (s, type(s)))

# value : {1, 2, 3, 4, 5}
# type : <class 'set'>

```

## 类型转换

集合可以和布尔型、列表、元组、字符串类型进行转换：

```python
s = {1, 2, 3, 4, 5}
boolSet = bool(s)
strSet = str(s)
listSet = list(s)
tupleSet = tuple(s)

print("value : %r\ntype : %r" % (boolSet, type(boolSet)))
print("value : %r\ntype : %r" % (strSet, type(strSet)))
print("value : %r\ntype : %r" % (listSet, type(listSet)))
print("value : %r\ntype : %r" % (tupleSet, type(tupleSet)))

# value : True
# type : <class 'bool'>
# value : '{1, 2, 3, 4, 5}'
# type : <class 'str'>
# value : [1, 2, 3, 4, 5]
# type : <class 'list'>
# value : (1, 2, 3, 4, 5)
# type : <class 'tuple'>

```

## 无序特性

Python本身并未对集合新增顺序数组，因此集合不论是Python3还是Python2中都是无序的。

Python2.7.10示例：

```python
>>> {chr(i) for i in range(10)}
set(['\x01', '\x00', '\x03', '\x02', '\x05', '\x04', '\x07', '\x06', '\t', '\x08'])

```

Python3.6.8示例：

```python
>>> {chr(i) for i in range(10)}
{'\x07', '\x06', '\t', '\x02', '\x00', '\x05', '\x04', '\x03', '\x01', '\x08'}

```

## 去重特性

得益于内部hash存储方式，集合具有去处重复的特性，我们可以让其与列表结合，将列表中重复的数据项剔除：

```python
repeatList = [1, 1, 2, 2, 3, 4, 5, 1, 2]
newList = list(set(repeatList))
print(newList)

# [1, 2, 3, 4, 5]

```

# 集合中的数据项怎么拿出来

集合虽然是容器类型，但是更多的作用是操作数据项，存储非它所长（存了就不好取了）。

集合没有提供[]语法：

- 它没有key，无法像字典一样通过key来操作value
- 也没有index，因为它不是顺序存储的线性结构。

虽然set中没有提供单拿数据项的方法，但是我们可以将其转换为list后再通过index将某个数据项拿出来。

或者是通过遍历。

# 常用方法

常用的set方法一览，set有一部分方法可以进行符号操作：

| 方法名                 | 符号表示 | 返回值    | 描述                                                       |
| ---------------------- | -------- | --------- | ---------------------------------------------------------- |
| add()                  | 无       | None      | 为集合中新增数据项                                         |
| pop()                  | 无       | Data item | 弹出随机数据项                                             |
| remove()               | 无       | None      | 删除指定数据项，若不存在则抛出异常                         |
| discard()              | 无       | None      | 同上、但不存在不会抛出异常                                 |
| clear()                | 无       | None      | 清空集合                                                   |
| copy()                 | 无       | set       | 对集合进行浅拷贝                                           |
| update()               | 无       | None      | 原地更新集合                                               |
| intersection()         | &        | set       | 求a集合与b集合的交集，a,b 集合都有                         |
| difference()           | -        | set       | 求a集合与b集合的差集，set(a) - set(b) ，a有b没有           |
| union()                | \|       | set       | 求a集合与b集合的合集/并集，a,b 合并后去重                  |
| symmetric_difference() | ^        | set       | 求a集合与b集合的对称差集，返回两个集合中不重复(不同)的元素 |
| issuperset()           | >或者>=  | bool      | 判定a集合是否为b集合的父级                                 |
| issubset()             | <或者<=  | bool      | 判断a集合是否为b集合的子集                                 |
| isdisjoint()           | 无       | bool      | 判断两个集合是否完全独立没有共同部分返回                   |
| intersection_update()  | 无       | None      | 求出a集合与b集合的交集后并更新a集合                        |
| difference_update()    | 无       | None      | 求出a集合与b集合的差集后并更新a集合                        |

基础公用函数：

| 函数名 | 返回值  | 描述               |
| ------ | ------- | ------------------ |
| len()  | integer | 返回容器中的项目数 |

## 数据管理

示例演示：

```python
s1 = set()

# 增加数据项
s1.add(1)
print(s1)
# {1}

# 更新数据项
s1.update({2, 3, 4, 5})
print(s1)
# {1, 2, 3, 4, 5}

# 删除数据项， 不存在则抛出异常
s1.remove(2)
print(s1)
# {1, 3, 4, 5}

# 删除数据项， 即使不存在也不会抛出异常
s1.discard(2)
print(s1)
# {1, 3, 4, 5}

# 随机弹出数据项
print(s1.pop())
# 1
print(s1)
# {3, 4, 5}

# 浅拷贝
print(s1.copy())
# {3, 4, 5}

# 清空数据项
s1.clear()
print(s1)
# set()

```

## 关系图解

集合关系图示：

![image-20210514172109764](Python/6899003b8dd36d9c4a0f38c4db6c4537.png)

上面的图 1 中 结果是4，5

## 关系获取

示例演示：

```python
s1 = {1, 2, 3, 4, 5}
s2 = {4, 5, 6, 7, 8}

# 交集
print(s1 & s2)
print(set.intersection(s1, s2))
# {4, 5}

# 差集
print(s1 - s2)
print(set.difference(s1, s2))
# {1, 2, 3}

# 合集、并集
print(s1 | s2)
print(set.union(s1, s2))
# {1, 2, 3, 4, 5, 6, 7, 8}

# 对称差集
print(s1 ^ s2)
print(set.symmetric_difference(s1, s2))
# {1, 2, 3, 6, 7, 8}

# 父子集
s3 = {1, 2, 3}
s4 = {1,2}

# 父级
print(s3 > s4)
print(s3 >= s4)
print(set.issuperset(s3, s4))
# True

# 子集
print(s4 < s3)
print(s4 <= s3)
print(set.issubset(s4, s3))
# True

# 判断2个集合是否相互独立
print(set.isdisjoint(s1, s2))
# False

```

## 不可变的集合

frozenset()创建的集合拥有元组的特性，一旦集合创建完成后将不可以修改。

```python
fs = frozenset((1, 2, 3))
print(fs)

# frozenset({1, 2, 3})

```

可以与普通的set集合进行关系获取，但是不能够进行数据项管理（可以copy，copy也是绝对引用）。

# 2.3以前怎么办

Python2.3的set和frozenset首次以模块的形式加入到Python中。

并且在Python2.6之后，提升为内置模块。

在Python2.3以前，我们常用字典来进行与集合相同的操作，因为字典的key也具有去重的特性嘛！

```python
repeatList = [1, 1, 2, 2, 3, 4, 5, 1, 2]
newList = list(dict.fromkeys(repeatList, None).keys())
print(newList)

# [1, 2, 3, 4, 5]

```

如果是求交叉并集这种关系，则实现会更加复杂一点，这里不再举例。
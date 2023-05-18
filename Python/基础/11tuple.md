[toc]



Python中的元组容器序列（tuple）与列表容器序列（list）具有极大的相似之处，因此也常被称为不可变的列表。

但是两者之间也有很多的差距，元组侧重于数据的展示，而列表侧重于数据的存储与操作。

它们非常相似，虽然都可以存储任意类型的数据，但是一个元组定义好之后就不能够再进行修改。

### 元组特性

元组特性如下：

1. 元组属于线性容器序列
2. 元组属于不可变类型，即对象本身的属性不会根据外部变化而变化
3. 元组底层由顺序存储组成，而顺序存储是线性结构的一种

### 基本声明

以下是使用类实例化的形式进行对象声明：

```python
tpl = tuple((1, 2, 3, 4, 5))
print("value : %r\ntype : %r" % (tpl, type(tpl)))

# value : (1, 2, 3, 4, 5)
# type : <class 'tuple'>

```

也可以选择使用更方便的字面量形式进行对象声明，使用逗号对数据项之间进行分割：

```python
tpl = 1, 2, 3, 4, 5
print("value : %r\ntype : %r" % (tpl, type(tpl)))

# value : (1, 2, 3, 4, 5)
# type : <class 'tuple'>

```

为了美观，我们一般会在两侧加上()，但是要确定一点，元组定义是用逗号来分隔数据项，而并非是用()包裹数据项：

```python
tpl = (1, 2, 3, 4, 5)
print("value : %r\ntype : %r" % (tpl, type(tpl)))

# value : (1, 2, 3, 4, 5)
# type : <class 'tuple'>

```

### 多维元组

当一个元组中嵌套另一个元组，该元组就可以称为多维元组。

如下，定义一个2维元组：

```python
tpl = (1, 2, ("三", "四"))
print("value : %r\ntype : %r" % (tpl , type(tpl)))

# value : (1, 2, ('三', '四'))
# type : <class 'tuple'>

```

### 续行操作

在Python中，元组中的数据项如果过多，可能会导致整个元组太长，太长的元组是不符合PEP8规范的。

- 每行最大的字符数不可超过79，文档字符或者注释每行不可超过72

Python虽然提供了续行符\，但是在元组中可以忽略续行符，如下所示：

```python
tpl = (
    1,
    2,
    3,
    4,
    5
)
print("value : %r\ntype : %r" % (tpl, type(tpl)))

# value : (1, 2, 3, 4, 5)
# type : <class 'tuple'>

```

### 类型转换

元组支持与布尔型、字符串、列表、以及集合类型进行类型转换：

```python
tpl = (1, 2, 3)
bTpl = bool(tpl)
strTpl = str(tpl)
lstTpl = list(tpl)
setTpl = set(tpl)

print("value : %r\ntype : %r" % (bTpl, type(bTpl)))
print("value : %r\ntype : %r" % (strTpl, type(strTpl)))
print("value : %r\ntype : %r" % (lstTpl, type(lstTpl)))
print("value : %r\ntype : %r" % (setTpl, type(setTpl)))

# value : True
# type : <class 'bool'>
# value : '(1, 2, 3)'
# type : <class 'str'>
# value : [1, 2, 3]
# type : <class 'list'>
# value : {1, 2, 3}
# type : <class 'set'>

```

如果一个2维元组遵循一定的规律，那么也可以将其转换为字典类型：

```python
tpl = (("k1", "v1"), ("k2", "v2"), ("k3", "v3"))
dictTuple = dict(tpl)

print("value : %r\ntype : %r" % (dictTuple, type(dictTuple)))

# value : {'k1': 'v1', 'k2': 'v2', 'k3': 'v3'}
# type : <class 'dict'>

```

### 索引操作

元组由于是线性结构，故支持索引和切片操作

但只针对获取，不能对其内部数据项进行修改。

使用方法参照列表的索引切片一节。

### 绝对引用

元组拥有绝对引用的特性，无论是深拷贝还是浅拷贝，都不会获得其副本，而是直接对源对象进行引用。

但是列表没有绝对引用的特性，代码验证如下：

```python
>>> import copy
>>> # 列表的深浅拷贝均创建新列表...
>>> oldLi = [1, 2, 3]
>>> id(oldLi)
4542649096
>>> li1 = copy.copy(oldLi)
>>> id(li1)
4542648840
>>> li2 = copy.deepcopy(oldLi)
>>> id(li2)
4542651208
>>> # 元组的深浅拷贝始终引用老元组
>>> oldTup = (1, 2, 3)
>>> id(oldTup)
4542652920
>>> tup1 = copy.copy(oldTup)
>>> id(tup1)
4542652920
>>> tup2 = copy.deepcopy(oldTup)
>>> id(tup2)
4542652920

```

Python为何要这样设计？其实仔细想想不难发现，元组不能对其进行操作，仅能获取数据项。

那么也就没有生成多个副本提供给开发人员操作的必要了，因为你修改不了元组，索性直接使用绝对引用策略。

值得注意的一点：[:]也是浅拷贝，故对元组来说属于绝对引用范畴。

### 元组的陷阱

Leonardo Rochael在2013年的Python巴西会议提出了一个非常具有思考意义的问题。

我们先来看一下：

```python
>>> t = (1, 2, [30, 40])
>>> t[-1] += [50, 60]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: 'tuple' object does not support item assignment

```

现在，t到底会发生下面4种情况中的哪一种？

1. t 变成 (1, 2, [30, 40, 50, 60])。
2. 因为 tuple 不支持对它的数据项赋值，所以会抛出 TypeError 异常。
3. 以上两个都不是。
4. a 和 b 都是对的。

正确答案是4，t确实会变成 (1, 2, [30, 40, 50, 60])，但同时元组是不可变类型故会引发TypeError异常的出现。

```python
>>> t
(1, 2, [30, 40, 50, 60])

```

如果是使用extend()对t[-1]的列表进行数据项的增加，则答案会变成1。

我当初在看了这个问题后，暗自告诉自己了1件事情：

- tuple中不要存放可变类型的数据，如list、set、dict等…

元组更多的作用是展示数据，而不是操作数据。

举个例子，当用户根据某个操作获取到了众多数据项之后，你可以将这些数据项做出元组并返回。

用户对被返回的原对象只能看，不能修改，若想修改则必须创建新其他类型对象。

### 解构方法

元组的解构方法与列表使用相同。

使用方法参照列表的解构方法一节。

### 常用方法

常用的tuple方法一览表：

| 方法名  | 返回值  | 描述                                                         |
| ------- | ------- | ------------------------------------------------------------ |
| count() | integer | 返回数据项在T中出现的次数                                    |
| index() | integer | 返回第一个数据项在T中出现位置的索引，若值不存在，则抛出ValueError |
|         |         |                                                              |

基础公用函数：

| 函数名      | 返回值                                | 描述                                                         |
| ----------- | ------------------------------------- | ------------------------------------------------------------ |
| len()       | integer                               | 返回容器中的项目数                                           |
| enumerate() | iterator for index, value of iterable | 返回一个可迭代对象，其中以小元组的形式包裹数据项与正向索引的对应关系 |
| reversed()  | …                                     | 详情参见函数章节                                             |
| sorted()    | …                                     | 详情参见函数章节                                             |

### 获取长度

使用len()方法来获取元组的长度。

返回int类型的值。

```python
tpl = ("A", "B", "C", "D", "E", "F", "G")

print(len(tpl))

# 7

```

Python在对内置的数据类型使用len()方法时，实际上是会直接的从PyVarObject结构体中获取ob_size属性，这是一种非常高效的策略。

PyVarObject是表示内存中长度可变的内置对象的C语言结构体。

直接读取这个值比调用一个方法要快很多。

### 统计次数

使用count()方法统计数据项在该元组中出现的次数。

返回int：

```python
tpl = ("A", "B", "C", "D", "E", "F", "G", "A")

aInTupCount = tpl.count("A")

print(aInTupCount)

# 2

```

### 查找位置

使用index()方法找到数据项在当前元组中**首次**出现的位置索引值，如数据项不存在则抛出异常。

返回int。

```python
tpl = ("A", "B", "C", "D", "E", "F", "G", "A")

aInTupIndex = tpl.index("A")

print(aInTupIndex)

# 0

```

# 底层探究

## 内存开辟

Python内部实现中，列表和元组还是有一定的差别的。

元组在创建对象申请内存的时候，内存空间大小便进行了固定，后续不可更改（如果是传入了一个可迭代对象，例如tupe(range(100))，这种情况会进行扩容与缩容，下面的章节将进行详细研究）。

而列表在创建对象申请内存的时候，内存空间大小不是固定的，如果后续对其新增或删除数据项，列表会进行扩容或者缩容机制。元组创建

### 空元组

若创建一个空元组，会直接进行创建，然后将这个空元组丢到缓存free_list中。

元组的free_list最多能缓存 20 * 2000 个元组，这个在下面会进行讲解。

如图所示：

![image-20210513195140580](Python/8e3446afe0bb76fbcbeef803bd7692b7.png)

### 元组转元组

下面的代码会进行元组转元组：

```python
tup = tuple((1, 2, 3))

```

首先内部的参数本身就是一个元组（1， 2， 3），所以会直接将内部的这个元组拿出来并返回引用，并不会再次创建。

```python
>>> oldTpl = (1, 2, 3)
>>> id(oldTpl)
4384908128
>>> newTpl = tuple(oldTpl)
>>> id(newTpl)
4384908128
>>>

```

### 列表转元组

列表转元组会将列表中的每一个数据项都拿出来，然后放入至元组中：

```python
tpl = tuple([1, 2, 3])

```

所以你会发现，列表和元组中的数据项引用都是相同的：

```python
>>> lst = ["A", "B", "C"]
>>> tpl = tuple(lst)
>>> print(id(lst[0]))
4383760656
>>> print(id(tpl[0]))
4383760656
>>>

```

可迭代对象转元组
可迭代对象是没有长度这一概念的，如果是可迭代对象转换为元组，会先对可迭代对象的长度做一个猜想。

并且根据这个猜想，为元组开辟一片内存空间，用于存放可迭代对象的数据项。

然后内部会获取可迭代对象的迭代器，对其进行遍历操作，拿出数据项后放至元组中。

如果猜想的长度太小，会导致元组内部的内存不够存放下所有的迭代器数据项，此时该元组会进行内部的扩容机制，直至可迭代对象中的数据项全部被添加至元组中。

```c
rangeObject = range(1, 101)
tpl = tuple(rangeObject)

// 假如猜想的是9
// 第一步：+ 10 
// 第二步：+ (原长度+10) * 0.25
// 其实，就是增加【原长度*0.25 + 2.5】
// 即第一次新增4个槽位

```

如果猜想的长度太大，而实际上迭代器中的数据量偏少，则需要对该元组进行缩容。

## 切片取值

对元组进行切片取值的时候，会开辟一个新元组用于存放切片后得到的数据项。

```python
tpl = (1, 2, 3)
newSliceTpl = tpl[0:2]

```

当然，如果是[:]的操作，则参照绝对引用，直接返回被切片的元组引用。

```python
>>> id(tpl)
4384908416
>>> newSliceTpl = tpl[0:2]
>>> id(newSliceTpl)
4384904392

```

## 缓存机制

### free_list缓存

元组的缓存机制和列表的缓存机制不同。

元组的free_list会缓存0 - 19长度的共20种元组，其中每一种长度的元组通过单向链表横向扩展缓存至2000个，如下图所示：

![image-20210513200942411](Python/5eb957a3f2239b6aba90f30b2680a36e.png)

当每一次del操作有数据项的元组时，都会将该元组数据项清空并挂载至free_list单向链表的头部的位置。

```python
del (1, 2, 3)  --> (None, None, None) \
del (4, 5, 6)  --> (None, None, None)  ->  free_list 长度3的元组 ...
del (7, 8, 9)  --> (None, None, None) /

```

![image-20210513202009430](Python/06271fde557686101d8a7a299ca993af.png)

当要创建一个元组时，会通过创建元组的长度，从free_list单向链表的头部取出一个元组，然后将数据项存放进去。

前提是free_list单向链表中缓存的有该长度的元组。

```python
tup = (1, 2, 3)  # 长度为3，从free_list的长度为3的元组中取

```

![image-20210513202537264](Python/72044167ada9ad2b9c102133ee13017f.png)

### 空元组与非空元组的缓存

空元组的缓存是一经创建就缓存到free_list单向链表中。

而非空元组的缓存必须是del操作后才缓存到free_list单向链表中。

### 空元组的创建

第一次创建空元组后，空元组会缓存至free_list单向链表中。

以后的每一次空元组创建，返回的其实都是同一个引用，也就是说空元组在free_list单向链表中即使被引用了也不会被销毁。

```python
>>> t1 = ()
>>> id(t1)
4511088712
>>> t2 = ()
>>> id(t2)
4511088712

```

### 非空元组的创建

创建非空元组时，先检查free_list，当free_list单向链表中有相同长度的元组时，会进行引用并删除。

这个在上图中已经示例过了，就是这个：

![image-20210513202537264](Python/72044167ada9ad2b9c102133ee130117f.png)

```python
$ python3

Python 3.6.8 (v3.6.8:3c6b436a57, Dec 24 2018, 02:04:31)
[GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.57)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> v1 = (None, None, None)
>>> id(v1)
4384907696
>>> v2 = (None, None, None)
>>> id(v2)
4384908056
>>> del v1
>>> del v2   # ❶
>>> v3 = (None, None, None)
>>> id(v3)   # ❷
4384908056
>>> v4 = (None, None, None)
>>> id(v4)   # ❸
4384907696
>>>

```

❶：free_list num_free=3 单向链表结构：v2 —> v1

❷：创建了v3，拿出v2的空元组，填入v3数据项，故v2和v3的id值相等，证明引用同一个元组，此时free_list num_free=3 单向链表结构为：—> v1

❸：创建了v4，拿出v1的空元组，填入v4数据项，故v1和v4的id值相等，证明引用同一个元组

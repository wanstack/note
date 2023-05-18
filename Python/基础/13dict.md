[toc]



# 字典

Python 中的字典（dict）也被称为映射（mapping）或者散列（hash），是支持Python底层实现的重要数据结构。

同时，它也是应用最为广泛的数据结构，内部采用hash存储，存储方式为键值对。

字典本身属于可变容器类型，但键（key）必须为不可变类型，而值（value）可以是任意类型。

字典的优点是单点查找速度极快，但不能够支持范围查找，此外也比较占用内存。

## 字典特性

字典特性如下：

- 字典是一个可变的容器类型
- 字典内部由散列表组成
- 字典的单点读写速度很快，但是不支持范围查找
- 字典的key必须是不可变的，只有不可变对象才能被hash
- 字典在3.6之后变得有序了，这样做提升了遍历效率

## 基本声明

以下是使用类实例化的形式进行对象声明：

```python
userInfo = dict(name="YunYa", age=18, hobby=["football, music"])
print("value : %r\ntype : %r" % (userInfo, type(userInfo)))

# value : {'name': 'YunYa', 'age': 18, 'hobby': ['football, music']}
# type : <class 'dict'>

```

也可以选择使用更方便的字面量形式进行对象声明，使用{}对键值对进行包裹，键值对采用k:v的形式分割，多个键值对之间使用逗号进行分割：

```python
userInfo = {"name": "YunYa", "age": 18, "hobby": ["football, music"]}
print("value : %r\ntype : %r" % (userInfo, type(userInfo)))

# value : {'name': 'YunYa', 'age': 18, 'hobby': ['football, music']}
# type : <class 'dict'>

```

声明字典时，千万注意key只能是不可变类型。

如字符串（str），整形（int），浮点型（float），布尔型（bool），元组类型（tuple）等等均可设置为字典的key，但使用可变类型作为key时则会抛出异常。

## 续行操作

在Python中，字典中的键值对如果过多，可能会导致整个字典太长，太长的字典是不符合PEP8规范的。

- 每行最大的字符数不可超过79，文档字符或者注释每行不可超过72

Python虽然提供了续行符\，但是在字典中可以忽略续行符，如下所示

```python
userInfo = {
    "name": "YunYa",
    "age": 18,
    "hobby": ["football, music"]}
print("value : %r\ntype : %r" % (userInfo, type(userInfo)))

# value : {'name': 'YunYa', 'age': 18, 'hobby': ['football, music']}
# type : <class 'dict'>

```

## 多维嵌套

字典中可以进行多维嵌套，如字典套字典，字典套元组，字典套列表等：

```python
dic = {
    "k1": [1, 2, 3],
    "k2": (1, 2, 3),
    "k3": {
        "k3-1": 1,
        "k3-2": 2,
    },
}

```

## 类型转换

字典可以与布尔类型和字符串进行转换，这是最常用的：

```python
dic = {"k1": "v1", "k2": "v2"}
boolDict = bool(dic)  
strDict = str(dic)    

print("value : %r\ntype : %r" % (boolDict, type(boolDict)))
print("value : %r\ntype : %r" % (strDict, type(strDict)))

# value : True
# type : <class 'bool'>
# value : "{'k1': 'v1', 'k2': 'v2'}"
# type : <class 'str'>

```

如果要将字典转换为列表、元组、集合类型，直接转换只会拿到键，并不会拿到值。

尤其注意这一点，但是其实这样用的场景十分少见，记住就行了：

```python
dic = {"k1": "v1", "k2": "v2"}
listDict = list(dic)
tupleDict = tuple(dic)
setDict = set(dic)

print("value : %r\ntype : %r" % (listDict, type(listDict)))
print("value : %r\ntype : %r" % (tupleDict, type(tupleDict)))
print("value : %r\ntype : %r" % (setDict, type(setDict)))

# value : ['k1', 'k2']
# type : <class 'list'>
# value : ('k1', 'k2')
# type : <class 'tuple'>
# value : {'k1', 'k2'}
# type : <class 'set'>

```

## 重复key

一个字典中的key必须是唯一的，若不是唯一的则value可能面临被覆盖的危险：

```python
dic = {"name": "云崖", "age": 18, "name": "Yunya"}
print(dic)

# {'name': 'Yunya', 'age': 18}

```

同理，True和1，False和0也会彼此进行覆盖：

```python
dic = {True: "云崖", "age": 18, 1: "Yunya"}
print(dic)

# {True: 'Yunya', 'age': 18}

```

# []操作字典

由于字典并非线性结构，故不支持索引操作。

但是字典也提供了[]操作语法，它是根据key来操作value的。

## 增删改查

以下示例展示了如何使用[]对字典中的value进行操纵：

```python
dic = {"k1": "v1", "k2": "v2"}

# 增
dic["k3"] = "v3"
print(dic)
# {'k1': 'v1', 'k2': 'v2', 'k3': 'v3'}

# 删，如果没有该key，则抛出keyError
del dic["k2"]
print(dic)
# {'k1': 'v1', 'k3': 'v3'}

# 改，如果没有该key，则新增
dic["k3"] = "VV3"
print(dic)
# {'k1': 'v1', 'k3': 'VV3'}

# 查，如果没有该key，则抛出keyError
result = dic["k1"]
print(result)
# v1

```

## 多维操作

字典套列表的多维操作如下，首先需要拿到该列表：

```python
dic = {"k1": [1, 2, 3, 4]}

# 取出3
result = dic["k1"][2]
print(result)
# 3

# k1的列表，添加数据项 "A"
dic["k1"].append("A")
print(dic)
# {'k1': [1, 2, 3, 4, 'A']}

```

字典套字典的多维操作如下，首先需要拿到被操纵的字典：

```python
dic = {
    "k1":{
        "k1-1":{
            "k1-2":{
                "k1-3":"HELLO,WORLD",
            }
        }
    }
}

# 拿到 k1-3 对应的value
result = dic["k1"]["k1-1"]["k1-2"]["k1-3"]
print(result)
# HELLO,WORLD

```

# 解构语法

## **语法

**语法用于将字典中的k:v全部提取出来。

我们可以利用该语法的特性来对字典进行合并，将两个旧字典合并成一个新字典：

```python
dic_1 = {"d1k1": "A", "d1k2": "B"}
dic_2 = {"d2k1": "C", "d2k2": "D"}
result = {**dic_1, **dic_2}
print(result)
# {'d1k1': 'A', 'd1k2': 'B', 'd2k1': 'C', 'd2k2': 'D'}

```

## 解构赋值

字典支持平行变量赋值操作吗？当然可以！但是这样只会拿到字典的key：

```python
dic = {"k1": "v1", "k2": "v2"}

first, last = dic
print(first)
print(last)

# k1
# k2

```

有办法拿到value么？借助字典的values()方法即可做到，它的本质是将value全部提取出来，组成一个可迭代对象：

```python
dic = {"k1": "v1", "k2": "v2"}

first, last = dic.values()
print(first)
print(last)

# v1
# v2

```

你可以理解为，将value全部提取出来组成一个列表，类似于[“v1”, “v2”]，在Python2中的确是这样，但是到了Python3中做法改变了.

对于一些不想要的数据项，你也可以按照列表的解构赋值操作来进行，这里不再举例。

## 用法一：解包（Unpacking）

### 1.* 对容器类型list、tuple、dict、set解包

简单来说就是*可以把上面三种数据类型中的每个元素都扒掉外衣（有点粗鲁，但实际就是这样）

让我们来看下扒掉的效果：

```python
list1 = [1,2,3]
tup1 = (1,2,3)
set1 = {1,2,3}
dict1 = {'name':'Mogu134','age':19}

print([*list1]) # [1, 2, 3]
print({*list1}) # {1, 2, 3}
print(*tup1) # 1 2 3
print({*tup1}) # {1, 2, 3}
print([*set1]) # [1, 2, 3]
print(*dict1) # name age

```

### 2.**对容器dict解包

同样的，我们来看对dict解包会发生什么：

```python
>>> print(**dict1)
Traceback (most recent call last):
  File "<pyshell#54>", line 1, in <module>
    print(**dict1)
TypeError: 'name' is an invalid keyword argument for print()

```

这是个错误演示，因为print()函数没有关键字参数name、age所以报错，但是它返回的值实际上是这样的：

```
name = 'Mogu134',age = 19
```

那字典解包该怎么用呢，下面通过两个小栗子来说明：

```python
# 案例一 解包的元素作为参数传给定义的函数,实参
>>> def myfun(name,age):
	print(name,age)
>>> myfun(**dict1)
Mogu134 19

# 案例二 解包两个字典合为一个字典
>>> dict2 = {'nationality':'China','hobby':'eating'}
>>> print({**dict1,**dict2})
{'name': 'Mogu134', 'age': 19, 'nationality': 'China', 'hobby': 'eating'}

```

## 二、用法二：收集参数

### 1.* 收集元组

*args收集参数接受任意数量的位置实参，并把所有收集到的实参存入args元组中：

```python
>>> def test(*args):
	print(args)	
>>> test('晚上','操场','团建','班导','星空','草地','路灯','快速路','飞机')
('晚上', '操场', '团建', '班导', '星空', '草地', '路灯', '快速路', '飞机')

```

### 2.**收集字典

**kwargs收集参数接受任意数量的关键字实参，并把所有收集到的实参存入kwargs字典中：

```python
>>> def test(**kwargs):
	print(kwargs)	
>>> test(time='晚上',place='操场',activity='团建')
{'time': '晚上', 'place': '操场', 'activity': '团建'}

```



# 常用方法

## 方法一览

常用的dict方法一览：

| 方法名       | 返回值    | 描述                                                         |
| ------------ | --------- | ------------------------------------------------------------ |
| get()        | v or None | 取字典key对应的value，如果key不存在返回None                  |
| setdefault() | v         | 获取字典key对应的value，如该字典中不存在被获取的key则会进行新增k:v，并返回v |
| update()     | None      | 对原有的字典进行更新                                         |
| pop()        | v         | 删除该字典中的键值对，如果不填入参数key或者key不存在则抛出异常 |
| keys()       | Iterable  | 返回一个可迭代对象，该可迭代对象中只存有字典的所有key        |
| values()     | Iterable  | 返回一个可迭代对象，该可迭代对象中只存有字典的所有value      |
| items()      | Iterable  | 返回一个可迭代对象，该可迭代对象中存有字典中所有的key与value，类似于列表套元组 |
| clear()      | None      | 清空当前字典                                                 |


基础公用函数：

| 函数名 | 返回值  | 描述               |
| ------ | ------- | ------------------ |
| len()  | integer | 返回容器中的项目数 |

## 获取长度

使用len()方法来进行字典长度的获取。

返回int类型的值。

```python
dic = {"name": "云崖", "age": 18}
print(len(dic))

# 2 一组键值对被视为一个数据项，故2组键值对长度为2

```

Python在对内置的数据类型使用len()方法时，实际上是会直接的从PyVarObject结构体中获取ob_size属性，这是一种非常高效的策略。

PyVarObject是表示内存中长度可变的内置对象的C语言结构体。

直接读取这个值比调用一个方法要快很多。

## get()

使用get()方法获取字典key对应的value，相比于[]操作更加的人性化，因为[]一旦获取不存在的key则会抛出异常，而该方法则是返回None。

```python
dic = {"name": "云崖", "age": 18}
username = dic.get("name")
userhobby = dic.get("hobby")

print("用户姓名:",username)
print("用户爱好:",userhobby)

# 用户姓名: 云崖
# 用户爱好: None

```

## setdefault()

使用setdefault()方法来获取字典key对应的value，如该字典中不存在被获取的key则会进行新增k:v，并返回v。

返回字典原有的value或者新设置的k:v。

```python
dic = {"name": "云崖", "age": 18}

# 字典有name，则取字典里的name
username = dic.setdefault("name","云崖先生")   

# 字典没有hobby，则设置hobby的value为足球与篮球并返回
userhobby = dic.setdefault("hobby","足球与篮球")  

print("用户姓名:",username)
print("用户爱好:",userhobby)

# 用户姓名: 云崖
# 用户爱好: 足球与篮球

```

## update()

使用update()方法对原有的字典进行更新。

返回None。

```python
dic = {"name": "云崖", "age": 18}

dic.update(
    {"hobby": ["篮球", "足球"]}
)

print(dic)

# {'name': '云崖', 'age': 18, 'hobby': ['篮球', '足球']}

```

## pop()

使用pop()方法删除该字典中的键值对，如果不填入参数key或者key不存在则抛出KeyError异常。

返回被删除的value。

```python
dic = {"name": "云崖", "age": 18}

result = dic.pop("age")

print(result)
print(dic)

# 18
# {'name': '云崖'}

```

## keys()

返回一个可迭代对象，该可迭代对象中只存有字典的所有key。

Python2中返回的是列表，Python3中返回的是可迭代对象。

```python
dic = {"name": "云崖", "age": 18}

key_iter = dic.keys()

print(key_iter)

# dict_keys(['name', 'age'])

```

Python3中返回的对象被称为字典视图。它们提供了字典条目的一个动态视图，这意味着当字典改变时，视图也会相应改变。

```python
>>> keys = result.keys()
>>> keys
dict_keys(['d1k1', 'd1k2', 'd2k1', 'd2k2', 'k1'])
>>> result["a"] = "ab"
>>> keys			# keys 会随着result 字典的变化而改变
dict_keys(['d1k1', 'd1k2', 'd2k1', 'd2k2', 'k1', 'a'])

```

## values()

返回一个可迭代对象，该可迭代对象中只存有字典的所有value。

Python2中返回的是列表，Python3中返回的是可迭代对象。

```python
dic = {"name": "云崖", "age": 18}

value_iter = dic.values()

print(value_iter)

# dict_values(['云崖', 18])

```

Python3中返回的对象被称为字典视图。它们提供了字典条目的一个动态视图，这意味着当字典改变时，视图也会相应改变。

## items()

返回一个可迭代对象，该可迭代对象中存有字典中所有的key与value，类似于列表套元组。

Python2中返回的是二维列表，Python3中返回的是可迭代对象。

```python
dic = {"name": "云崖", "age": 18}

items_iter = dic.items()

print(items_iter)

# dict_items([('name', '云崖'), ('age', 18)])

```

Python3中返回的对象被称为字典视图。它们提供了字典条目的一个动态视图，这意味着当字典改变时，视图也会相应改变。

## clear()

清空当前字典。

返回None。

```python
dic = {"name": "云崖", "age": 18}

dic.clear()

print(dic)

# {}

```

## 其他方法

| 方法                 | 返回值 | 描述                                                         |
| -------------------- | ------ | ------------------------------------------------------------ |
| popitem()            | (k, v) | 随机删除一组键值对,并将删除的键值放到元组内返回              |
| fromkeys(iter,value) | dict   | 第一个参数是可迭代对象，其中每一个数据项都为新生成字典的key，第二个参数为同一的value值 |

```python
>>> a = [1,2,3,4]
>>> new_dict = result.fromkeys(a,10)
>>> new_dict
{1: 10, 2: 10, 3: 10, 4: 10}
>>> result
{'d1k1': 'A', 'd1k2': 'B', 'd2k1': 'C', 'd2k2': 'D', 'k1': None, 'a': 'ab'}

```

示例演示：

```python
dic1 = dict(k1="v1", k2="v2", k3="v3", k4="v4")
print(dic1.popitem())  
# ('k4', 'v4') 

dic2 = dict.fromkeys([1, 2, 3, 4], None)
print(dic2)  
# {1: None, 2: None, 3: None, 4: None}

```

# 底层探究

## 高效查找

为什么要有字典这种数据结构？

如果对一个无序的列表查找其中某一个value（前提是不能对列表进行排序），必须经过一个一个的遍历，速度会很慢。

```shell
[3, 2, 8, 9, 11, 13]

# 如果要获取数据项11，必须经过5次查找

```

有没有一种办法，能够让速度加快？

为了不违背不能排序的前提，我们只能在列表存入value的时候做文章

我们可以为每个value都造一个独一无二的身份标识，根据这个身份标识符计算出value需要插入到列表的索引位置。

在取的时候同理，通过身份标识符直接就可以拿到value所在列表的索引值，无疑速度会快很多。

一个小总结：

- 有一个身份标识，身份标识必须是唯一的
- 提供一个根据身份标识计算出插入位置的算法

回到字典的本质，字典的key就是value的身份标识，而根据key计算出插入位置的算法被封装在了hash()函数中，这个算法也被称之为hash算法。

为什么key必须是唯一的，参照下面这个示例：

```python
["k1", "k2", "k3", "k4", "k5", "k6"]
   ↓     ↓     ↓     ↓     ↓     ↓
[  3,    2,    8,    9,   11,   13]

```

- 假如k5变成了k6，那么就有2个k6对应2个不同的value
- 这么做的后果就是，使用k6获取value的时候，根本不知道你需要的value是哪一个

所以，干脆Python规定，key必须是不可变类型！如果有重复则新的覆盖旧的。

或者说，只有不可变对象才能被hash。

## hash过程

如何通过hash()函数，确定value的插入位置？

实际上每个键值对在存入字典之前，都会通过hash()函数对key计算出一个hash值（也被称为散列值）：

```python
>>> hash("k1")
7036545863130266253

```

而字典的底层结构是由一个2维数组嵌套组成的，也被称为散列表、hash表。

如下所示，每次创建字典的时候，字典都会初始化生成一个固定长度且内容全是空的2维数组，Python内部生成的散列表长度为8（可参见[dictobject.c](https://github.com/KahnDepot/cpython/blob/main/Objects/dictobject.c)结构体源码）：

```python
[
	 ①  ②  ③
	[空, 空, 空], index: 0
	[空, 空, 空], index: 1
	[空, 空, 空], index: 2
	[空, 空, 空], index: 3
	[空, 空, 空], index: 4
	[空, 空, 空], index: 5
	[空, 空, 空], index: 6
	[空, 空, 空]  index: 7
]

```

❶：存放根据key计算出的hash值

❷：存放key的引用

❸：存放value的引用

现在，我们要存储name:yunya的键值对，对name计算hash值：

```python
>>> hash("name")
3181345887314224636

```

用计算出的hash值与散列表长度进行求余运算：

```python
>>> 3181345887314224636 % 8
4

```

得到结果是4，就在散列表4的索引位置插入：

```python
[
	 ①  ②  ③
	[空, 空, 空], index: 0
	[空, 空, 空], index: 1
	[空, 空, 空], index: 2
	[空, 空, 空], index: 3
	[3181345887314224636, "name"的引用, "yunya"], index: 4
	[空, 空, 空], index: 5
	[空, 空, 空], index: 6
	[空, 空, 空]  index: 7
]

```

再次插入age:18，并用计算出的hash值与散列表长度进行求余运算:

```python
>>> hash("age")
7064862892218627464
>>> 7064862892218627464 % 8
0

```

得到的结果是0，就在散列表0的索引位置插入：

```python
[
	 ①  ②  ③
	[7064862892218627464, "age"的引用, 18], index: 0
	[空, 空, 空], index: 1
	[空, 空, 空], index: 2
	[空, 空, 空], index: 3
	[3181345887314224636, "name"的引用, "yunya"], index: 4
	[空, 空, 空], index: 5
	[空, 空, 空], index: 6
	[空, 空, 空]  index: 7
]

```

可以看见，这个2维数组不是按照顺序进行插入的，总有一些空的位置存在，因此该数组也被称为稀松数组。

由于数组是稀松的，所以dict不支持范围获取（能获取到空值），但单点存取的速度很快。

读取的时候也同理，但是Python的hash函数底层实现是否真的利用hash值对稀松数组长度进行简单的求余运算，这个还有待商榷。

因为hash算法的实现有很多种，长度求余只是最为简单的一种而已，这里用作举例，如果想具体了解其算法可以查看Python源码，[dictobject.c](https://github.com/KahnDepot/cpython/blob/main/Objects/dictobject.c)中的perturb。

## 散列冲突

现在，我们的这个散列表中0和4的索引位置都已经存在数据了。

如果现在存入一个teacher:wang，那么结果会是怎么样？

```python
>>> hash("teacher")
4789346189807557228
>>> 4789346189807557228 % 8
4

```

可以发现，teacher的hash值求余算结果也是4，这个时候就会发生散列冲突。

最常见的做法是，向后挪！因为索引5的位置是空的，我们可以将这个键值对插入到索引5的位置：

```python
[
	 ①  ②  ③
	[7064862892218627464, "age"的引用, 18], index: 0
	[空, 空, 空], index: 1
	[空, 空, 空], index: 2
	[空, 空, 空], index: 3
	[3181345887314224636, "name"的引用, "yunya"], index: 4
	[4789346189807557228, "teacher"的引用, "wang"], index: 5
	[空, 空, 空], index: 6
	[空, 空, 空]  index: 7
]

```

这种查找空位的方法叫做开放定址法（openaddressing），向后查找也被称为线性探测（linearprobing）。

如果此时又插入一个数据项，最后key的插入索引位置也是4，则继续向后查找空位，如果查找到7还是没有空位，又从0开始找。

上述方法是解决散列冲突的基础方案，当然也还有更多的其他解决方案，这里再说就过头了，放在后面数构一章中再进行介绍吧。

## 扩容机制

Python的dict会对散列表的容量做出判定。

当容量超过三分之二时，即进行扩容（resize）机制。

如果散列表大小为8，在即将插入第5个键值对时进行扩容，扩容策略为已有散列表键值对个数 * 2。

即散列表大小扩展为18 (5 * 2 + 8)。

如果整个散列表已有键值对个数达到了50000，则扩容策略为已有散列表键值对个数 * 4。

此外，dict只会进行扩容，不会进行缩容，如果删除了1个键值对，其内存空间占用的位置并不会释放。不同key的优化

### 整形是其本身

整形的hash值是其本身：

```python
>>> hash(1)
1
>>> hash(2)
2
>>> hash(3)
3
>>> hash(10000)
10000

```

### 加盐策略

在Python3.3开始，str、bytes、datetime等对象在计算散列值的时候会进行加盐处理。

这个盐引用内部的一个常量，该常量在每次CPython启动时会生成不同的盐值。

所以你会发现每次重启Python3.3以后的解释器，对相同字符串进行hash()求散列值得出的结果总是不一样的：

```python
$ python3
Python 3.6.8 (v3.6.8:3c6b436a57, Dec 24 2018, 02:04:31)
[GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.57)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> hash("k1")
8214688532022610754
>>> exit()

$ python3
Python 3.6.8 (v3.6.8:3c6b436a57, Dec 24 2018, 02:04:31)
[GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.57)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> hash("k1")
-7444020267993088839
>>> exit()

```

再看Python2.7，由于没有加盐策略，所以每次重启Python解释器后相同key得到的hash结果是相同的：

```python
$ python
Python 2.7.10 (default, Feb 22 2019, 21:55:15)
[GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.37.14)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> hash("k1")
13696082283123634
>>> exit()

$ python
Python 2.7.10 (default, Feb 22 2019, 21:55:15)
[GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.37.14)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> hash("k1")
13696082283123634
>>> exit()

```

## 有序字典

字典无序的观念似乎已经深入人心，但那已经都是过去式了。

在Python3.6之后，字典变的有序了。

2012年12月10日星期一的时候，R. David Murray向Python官方发送了一封邮件，提出建议让Python的字典变的有序。

这样的做法能够让Python字典的空间占用量更小，迭代速度更快，以下是邮件内容：

https://mail.python.org/pipermail/python-dev/2012-December/123028.html

我们先看看2.7中的字典

```python
>>> {chr(i) : i for i in range(10)}
{'\x01': 1, '\x00': 0, '\x03': 3, '\x02': 2, '\x05': 5, '\x04': 4, '\x07': 7, '\x06': 6, '\t': 9, '\x08': 8}

```

再来看3.6中的字典：

```python
>>> {chr(i) : i for i in range(10)}
{'\x00': 0, '\x01': 1, '\x02': 2, '\x03': 3, '\x04': 4, '\x05': 5, '\x06': 6, '\x07': 7, '\x08': 8, '\t': 9}

```

果然！它确实变的有序了，关于具体细节，可以参照这封邮件，已经表述的很清楚了，下面做一个简单的示例。

首先，以前的散列表就是一个单纯的稀松二维数组：

```python
[
	[空, 空, 空], index: 0
	[空, 空, 空], index: 1
	[空, 空, 空], index: 2
	...
]

```

键值对的读取顺序来源与填加顺序。

索引靠前的会被先遍历拿到，索引靠后只能后被遍历出来。

如果这个散列表长度为8，前7个都没有数据项存入，仅有8才有，那么遍历完整个散列表需要8次：

```python
[
	[空, 空, 空], index: 0
	[空, 空, 空], index: 1
	[空, 空, 空], index: 2
	...
	[hash值, key的引用, value的引用], index: 7
]

```

而Python3.6之后，又新增了一个顺序数组，该数组与散列表的长度相等，初始均为8，并且会跟随散列表的扩容而进行扩容，如下示例初始状态：

```python
[None, None, None, ...]

[
	[空, 空, 空], index: 0
	[空, 空, 空], index: 1
	[空, 空, 空], index: 2
	...
]

```

如果说第1个键值对，被插入到散列表索引1的位置，那么在顺序数组中，则在索引0处记录下该键值对被插入在散列表中的位置(1)，如下图所示：

```python
[1, None, None, ...]

[
	[空, 空, 空], index: 0
	[hash值, key的引用, value的引用], index: 1
	[空, 空, 空], index: 2
	...
]

```

如果第2个键值对，被插入到散列表索引0的位置，那么在顺序数组中，则在索引1处记录下该键值对被插入在散列表中的位置(0)，如下图所示：

```python
[1, 0, None, ...]

[
	[hash值, key的引用, value的引用], index: 0
	[hash值, key的引用, value的引用], index: 1
	[空, 空, 空], index: 2
	...
]

```

再插入一个键值对，该键值对被插到了索引7的位置，那么在顺序数组中，则在索引2处记录下该键值对被插入在散列表中的位置(7)，如下图所示：

```python
[1, 0, 7, None, None, None, None, None] # 顺序数组

[
	[hash值, key的引用, value的引用], index: 0
	[hash值, key的引用, value的引用], index: 1
	[空, 空, 空], index: 2
	...
	[hash值, key的引用, value的引用], index: 7
]

```

在遍历的时候，会遍历这个顺序数组，然后通过索引值拿到散列表中对应位置的数据项，如果遍历到的值为None就结束遍历，而不用遍历完整个散列表：

```python
hashTableOrderArray = [1, 0, 7, None, None, None, None, None]
hashTable = [
    ["hash", "k2", "v2"],
    ["hash", "k1", "v1"],
    [None, None, None],
    [None, None, None],
    [None, None, None],
    [None, None, None],
    [None, None, None],
    ["hash", "k3", "v3"],
]

n = 0

while n < len(hashTable):
    if hashTableOrderArray[n] is not None:
        print(hashTable[hashTableOrderArray[n]])
    else:
        break
    n += 1

```

这样只需遍历3次即可，而如果没有这个顺序数组，则要完整遍历整个散列表，即8次才能拿出所有的键值对。


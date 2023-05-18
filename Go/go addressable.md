# go addressable



对于一个对象`x`, 如果它的类型为`T`, 那么`&x`则会产生一个类型为`*T`的指针，这个指针指向`x`,  也是我们在开发过程中经常使用的一种获取对象指针的一种方式。



**addressable**

上面规范中的这段话规定， `x`必须是可寻址的， 也就是说，它只能是以下几种方式：

- 1、一个变量: `&x`
- 2、指针引用(pointer indirection): `&*x` 
- 3、slice索引操作(不管slice是否可寻址): `&s[1]`
- 4、可寻址`struct`的字段: `&point.X` 
- 5、可寻址数组的索引操作: `&a[0]` 
- 6、composite literal类型: `&struct{ X int }{1}`

下列情况`x`是不可以寻址的，你不能使用`&x`取得指针：

- 字符串中的字节:
- map对象中的元素
- 接口对象的动态值(通过type assertions获得)
- 常数
- literal值(非composite literal)
- package 级别的函数
- 方法method (用作函数值)
- 中间值(intermediate value):
  - 函数调用
  - 显式类型转换
  - 各种类型的操作 （除了指针引用pointer dereference操作 `*x`):
    - channel receive operations（通道接受操作）
    - sub-string operations（子字符串操作）
    - sub-slice operations（子切片操作）
    - 加减乘除等运算符

https://gfw.go101.org/article/unofficial-faq.html#unaddressable-values

请注意：`&T{}`在Go里是一个语法糖，它是`tmp := T{}; (&tmp)`的简写形式。 所以`&T{}`是合法的并不代表字面量`T{}`是可寻址的。

以下的值是可寻址的，因此可以被取地址：

- 变量
- 可寻址的结构体的字段
- 可寻址的数组的元素
- 任意切片的元素（无论是可寻址切片或不可寻址切片）
- 指针解引用（dereference）操作

**为什么映射元素不可被取地址？**

在Go中，映射的设计保证一个映射值在内存允许的情况下可以加入任意个条目。 另外为了防止一个映射中为其条目开辟的内存段支离破碎，官方标准编译器使用了哈希表来实现映射。 并且为了保证元素索引的效率，一个映射值的底层哈希表只为其中的所有条目维护一段连续的内存段。 因此，一个映射值随着其中的条目数量逐渐增加时，其维护的连续的内存段需要不断重新开辟来增容，并把原来内存段上的条目全部复制到新开辟的内存段上。 另外，即使一个映射值维护的内存段没有增容，某些哈希表实现也可能在当前内存段中移动其中的条目。 总之，映射中的元素的地址会因为各种原因而改变。 如果映射元素可以被取地址，则Go运行时（runtime）必须在元素地址改变的时候修改所有存储了元素地址的指针值。 这极大得增加了Go编译器和运行时的实现难度，并且严重影响了程序运行效率。 因此，目前，Go中禁止取映射元素的地址。

映射元素不可被取地址的另一个原因是表达式`aMap[key]`可能返回一个存储于`aMap`中的元素，也可能返回一个不存储于其中的元素零值。 这意味着表达式`aMap[key]`在`(&aMap[key]).Modify()`调用执行之后可能仍然被估值为元素零值。 这将使很多人感到困惑，因此在Go中禁止取映射元素的地址。

**为什么非空切片的元素总是可被取地址，即便对于不可寻址的切片也是如此？**

切片的内部类型是一个结构体，类似于

```go
struct {
	elements unsafe.Pointer // 引用着一个元素序列
	length   int
	capacity int
}
```

每一个切片间接引用一个元素序列。 尽管一个非空切片是不可取地址的，它的内部元素序列需要开辟在内存中的某处因而必须是可取地址的。 取一个切片的元素地址事实上是取内部元素序列上的元素地址。 因此，不可寻址的非空切片的元素也是可以被取地址的。



有几个点需要解释下：

- 常数为什么不可以寻址?： 如果可以寻址的话，我们可以通过指针修改常数的值，破坏了常数的定义。
- map的元素为什么不可以寻址？:两个原因，如果对象不存在，则返回零值，零值是不可变对象，所以不能寻址，如果对象存在，因为Go中map实现中元素的地址是变化的，这意味着寻址的结果是无意义的。
- 为什么slice不管是否可寻址，它的元素读是可以寻址的？:因为slice底层实现了一个数组，它是可以寻址的。
- 为什么字符串中的字符/字节又不能寻址呢：因为字符串是不可变的。

规范中还有几处提到了 `addressable`:

- 调用一个receiver为指针类型的方法时，使用一个addressable的值将自动获取这个值的指针
- `++`、`--`语句的操作对象必须是addressable或者是map的index操作
- 赋值语句`=`的左边对象必须是addressable,或者是map的index操作，或者是`_`
- 上条同样使用`for ... range`语句



`reflect.Value`的`CanAddr`方法和`CanSet`方法

在我们使用`reflect`执行一些底层的操作的时候， 比如编写序列化库、`rpc`框架开发、编解码、插件开发等业务的时候，经常会使用到`reflect.Value`的`CanSet`方法，用来动态的给对象赋值。 `CanSet`比`CanAddr`只加了一个限制，就是`struct`类型的`unexported`的字段不能`Set`，所以我们这节主要介绍`CanAddr`。

并不是任意的`reflect.Value`的`CanAddr`方法都返回`true`,根据它的`godoc`,我们可以知道：

> CanAddr reports whether the value's address can be obtained with Addr. Such values are called addressable. A value is addressable if it is an element of a slice, an element of an addressable array, a field of an addressable struct, or the result of dereferencing a pointer. If CanAddr returns false, calling Addr will panic.

也就是只有下面的类型`reflect.Value`的`CanAddr`才是`true`, 这样的值是`addressable`:

- slice的元素
- 可寻址数组的元素
- 可寻址struct的字段
- 指针引用的结果

与规范中规定的`addressable`, `reflect.Value`的`addressable`范围有所缩小， 比如对于栈上分配的变量， 随着方法的生命周期的结束， 栈上的对象也就被回收掉了，这个时候如果获取它们的地址，就会出现不一致的结果，甚至安全问题。

所以如果你想通过`reflect.Value`对它的值进行更新，应该确保它的`CanSet`方法返回`true`,这样才能调用`SetXXX`进行设置。

使用`reflect.Value`的时候有时会对`func Indirect(v Value) Value`和`func (v Value) Elem() Value`两个方法有些迷惑，有时候他们俩会返回同样的值，有时候又不会。

总结一下：

1. 如果`reflect.Value`是一个指针， 那么`v.Elem()`等价于`reflect.Indirect(v)`
2. 如果不是指针
   2.1 如果是`interface`, 那么`reflect.Indirect(v)`返回同样的值，而`v.Elem()`返回接口的动态的值
   2.2 如果是其它值, `v.Elem()`会panic,而`reflect.Indirect(v)`返回原值

下面的代码列出一些`reflect.Value`是否可以addressable, 你需要注意数组和struct字段的情况，也就是`x7`、`x9`、`x14`、`x15`的正确的处理方式。

```go
package main

import (
	"fmt"
	"reflect"
	"time"
)

func main() {
	checkCanAddr()
}

type S struct {
	X int
	Y string
	z int
}

func M() int {
	return 100
}

var x0 = 0

func checkCanAddr() {
	// 可寻址的情况
	v := reflect.ValueOf(x0)
	fmt.Printf("x0: %v \tcan be addressable and set: %t, %t\n", x0, v.CanAddr(), v.CanSet()) //false,false

	var x1 = 1
	v = reflect.Indirect(reflect.ValueOf(x1))
	fmt.Printf("x1: %v \tcan be addressable and set: %t, %t\n", x1, v.CanAddr(), v.CanSet()) //false,false

	var x2 = &x1
	v = reflect.Indirect(reflect.ValueOf(x2))
	fmt.Printf("x2: %v \tcan be addressable and set: %t, %t\n", x2, v.CanAddr(), v.CanSet()) //true,true

	var x3 = time.Now()
	v = reflect.Indirect(reflect.ValueOf(x3))
	fmt.Printf("x3: %v \tcan be addressable and set: %t, %t\n", x3, v.CanAddr(), v.CanSet()) //false,false

	var x4 = &x3
	v = reflect.Indirect(reflect.ValueOf(x4))
	fmt.Printf("x4: %v \tcan be addressable and set: %t, %t\n", x4, v.CanAddr(), v.CanSet()) // true,true

	var x5 = []int{1, 2, 3}
	v = reflect.ValueOf(x5)
	fmt.Printf("x5: %v \tcan be addressable and set: %t, %t\n", x5, v.CanAddr(), v.CanSet()) // false,false

	var x6 = []int{1, 2, 3}
	v = reflect.ValueOf(x6[0])
	fmt.Printf("x6: %v \tcan be addressable and set: %t, %t\n", x6[0], v.CanAddr(), v.CanSet()) //false,false

	var x7 = []int{1, 2, 3}
	v = reflect.ValueOf(x7).Index(0)
	fmt.Printf("x7: %v \tcan be addressable and set: %t, %t\n", x7[0], v.CanAddr(), v.CanSet()) //true,true

	v = reflect.ValueOf(&x7[1])
	fmt.Printf("x7.1: %v \tcan be addressable and set: %t, %t\n", x7[1], v.CanAddr(), v.CanSet()) //true,true

	var x8 = [3]int{1, 2, 3}
	v = reflect.ValueOf(x8[0])
	fmt.Printf("x8: %v \tcan be addressable and set: %t, %t\n", x8[0], v.CanAddr(), v.CanSet()) //false,false

	// https://groups.google.com/forum/#!topic/golang-nuts/RF9zsX82MWw
	var x9 = [3]int{1, 2, 3}
	v = reflect.Indirect(reflect.ValueOf(x9).Index(0))
	fmt.Printf("x9: %v \tcan be addressable and set: %t, %t\n", x9[0], v.CanAddr(), v.CanSet()) //false,false

	var x10 = [3]int{1, 2, 3}
	v = reflect.Indirect(reflect.ValueOf(&x10)).Index(0)
	fmt.Printf("x9: %v \tcan be addressable and set: %t, %t\n", x10[0], v.CanAddr(), v.CanSet()) //true,true

	var x11 = S{}
	v = reflect.ValueOf(x11)
	fmt.Printf("x11: %v \tcan be addressable and set: %t, %t\n", x11, v.CanAddr(), v.CanSet()) //false,false

	var x12 = S{}
	v = reflect.Indirect(reflect.ValueOf(&x12))
	fmt.Printf("x12: %v \tcan be addressable and set: %t, %t\n", x12, v.CanAddr(), v.CanSet()) //true,true

	var x13 = S{}
	v = reflect.ValueOf(x13).FieldByName("X")
	fmt.Printf("x13: %v \tcan be addressable and set: %t, %t\n", x13, v.CanAddr(), v.CanSet()) //false,false

	var x14 = S{}
	v = reflect.Indirect(reflect.ValueOf(&x14)).FieldByName("X")
	fmt.Printf("x14: %v \tcan be addressable and set: %t, %t\n", x14, v.CanAddr(), v.CanSet()) //true,true

	var x15 = S{}
	v = reflect.Indirect(reflect.ValueOf(&x15)).FieldByName("z")
	fmt.Printf("x15: %v \tcan be addressable and set: %t, %t\n", x15, v.CanAddr(), v.CanSet()) //true,false

	v = reflect.Indirect(reflect.ValueOf(&S{}))
	fmt.Printf("x15.1: %v \tcan be addressable and set: %t, %t\n", &S{}, v.CanAddr(), v.CanSet()) //true,true

	var x16 = M
	v = reflect.ValueOf(x16)
	fmt.Printf("x16: %p \tcan be addressable and set: %t, %t\n", x16, v.CanAddr(), v.CanSet()) //false,false

	var x17 = M
	v = reflect.Indirect(reflect.ValueOf(&x17))
	fmt.Printf("x17: %p \tcan be addressable and set: %t, %t\n", x17, v.CanAddr(), v.CanSet()) //true,true

	var x18 interface{} = &x11
	v = reflect.ValueOf(x18)
	fmt.Printf("x18: %v \tcan be addressable and set: %t, %t\n", x18, v.CanAddr(), v.CanSet()) //false,false

	var x19 interface{} = &x11
	v = reflect.ValueOf(x19).Elem()
	fmt.Printf("x19: %v \tcan be addressable and set: %t, %t\n", x19, v.CanAddr(), v.CanSet()) //true,true

	var x20 = [...]int{1, 2, 3}
	v = reflect.ValueOf([...]int{1, 2, 3})
	fmt.Printf("x20: %v \tcan be addressable and set: %t, %t\n", x20, v.CanAddr(), v.CanSet()) //false,false
}
```

https://studygolang.com/articles/12470
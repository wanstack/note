



Go语言是个强类型语言。Go语言要求不同的类型之间必须做显示的类型转换。而作为Go语言鼻祖的C语言是可以直接做隐式的类型转换的。

也就是说Go对类型要求严格，不同类型不能进行赋值操作。指针也是具有明确类型的对象，进行严格类型检查。不过Go语言也有例外在一些特殊类型存在隐式转换。

### 1. `unsafe.Pointer`

```go
type Pointer *ArbitraryType
type ArbitraryType int   // 自定义 ArbitraryType 类型
```

Pointer 是一个指向 `ArbitraryType` 类型的指针

- 任何类型的指针 都可以被转化为 Pointer
- Pointer 可以被转化为任何类型的指针
- `uintptr` 可以被转化为 Pointer
- Pointer 可以被转化为 `uintptr`

**`unsafe.Pointer` 是特别定义的一种指针类型（译注：类似C语言中的void类型的指针），它可以包含任意类型变量的地址。**当然，我们不可以直接通过 `*p`来获取 `unsafe.Pointer` 指针指向的真实变量的值，因为我们并不知道变量的具体类型。和普通指针一样，`unsafe.Pointer` 指针也是可以比较的，并且支持和nil常量比较判断是否为空指针。

什么叫 **`unsafe.Pointer` 是特别定义的一种指针类型（译注：类似C语言中的void类型的指针），它可以包含任意类型变量的地址。？？**

 **`unsafe.Pointer`** 转换的变量，该变量一定要是指针类型，否则编译会报错。如：

```go
	a := 1
	b := unsafe.Pointer(a)		// 报错
	c := unsafe.Pointer(&a)
```

 **一个普通的T类型 指针 可以被转化为 `unsafe.Pointer`类型指针，并且一个 `unsafe.Pointer` 类型指针也可以被转回普通的指针，被转回普通的指针类型并不需要和原始的T类型相同。**

 **说明：**

1. **`unsafe.Pointer` 转换的变量类型，一定是指针类型；**
2. **& 取址，\* 取值；**

**例1：**通过将 `float64` 类型指针转化为`uint64` 类型指针，我们可以查看一个浮点数变量的位模式。

```go
package main

import (
	"fmt"
	"reflect"
	"unsafe"
)

func float64ToUint64(f float64) uint64 {
	fmt.Println(reflect.TypeOf(unsafe.Pointer(&f)))					// unsafe.Pointer
	fmt.Println(reflect.TypeOf((*uint64)(unsafe.Pointer(&f))))		// *uint64
	return *(*uint64)(unsafe.Pointer(&f))							// 第一个 * 表示取值
}

func main() {
	fmt.Printf("%T, %v", float64ToUint64(1.0), float64ToUint64(1.0))
}

/*
unsafe.Pointer
*uint64
unsafe.Pointer
*uint64
uint64, 4607182418800017408


*(*uint64)(unsafe.Pointer(&f)) 分解：
1. unsafe.Pointer(&f) 转换变量指针 f 成 Pointer 类型
2. (*uint64)(unsafe.Pointer(&f))  将上述的 Pointer 类型转成 uint64 的指针类型
3. 在2的结果(指针类型)前加上*,就是获取该指针的变量值
 */

// 总结： 要获取指针类型的变量的值，只需要在变量前加 * 即可。
```

例子2：

```go
package main

func main() {

	v1 := uint(12)
	v2 := int(12)

	p := &v1
	p = &v2 	// cannot use &v2 (type *int) as type *uint in assignment
}

/*
&v1 先赋值给 p，所以 p 为 *uint 类型，指向 uint 类型的指针
&v2 为 *int 类型和 p 不是同一种类型，所以不能赋值给 p
*/
```

改进

```go
package main

import (
	"fmt"
	"unsafe"
)

func main() {

	v1 := uint(12)
	v2 := int(12)

	p := &v1
	p = (*uint)(unsafe.Pointer(&v2))		// &v2 转换为 *uint 类型
	fmt.Println(p)
}
```



### 2. `uintptr`

```go
// uintptr is an integer type that is large enough to hold the bit pattern of
// any pointer. Uintptr是一个足够大的整数类型，可以容纳任何指针的位模式。
type` `uintptr uintptr
```

`uintptr` 是 `golang` 的内置类型，是能存储指针的整型，在64位平台上底层的数据类型是，

```go
typedef unsigned long long int uint64;
typedef uint64     uintptr;
```

一个 `unsafe.Pointer` 指针也可以被转化为 `uintptr` 类型，然后保存到指针类型数值变量中（注：这只是和当前指针相同的一个数字值，并不是一个指针），然后用以做必要的指针数值运算。（`uintptr` 是一个无符号的整型数，足以保存一个地址）**这种转换虽然也是可逆的，但是将`uintptr`转为`unsafe.Pointer`指针可能会破坏类型系统，因为并不是所有的数字都是有效的内存地址**。

许多将 `unsafe.Pointer` 指针转为原生数字，然后再转回为 `unsafe.Pointer` 类型指针的操作也是不安全的。

比如下面的例子需要将变量 `x` 的地址加上`b `字段地址偏移量，然后转化为`*int16`类型指针，然后通过该指针更新`x.b`：

```go
package main

import (
	"fmt"
	"unsafe"
)

func main() {
	var x struct{
		a bool
		b int16
		c []int
	}

    // unsafe.Offsetof 函数的参数必须是一个字段 x.b, 然后返回 b 字段相对于 x 起始地址的偏移量,
	// 包括可能的空洞.

	// uintptr(unsafe.Pointer(&x)) + unsafe.Offsetof(x.b) 指针的运算
	// 和 pb := &x.b 等价
	//tmp1 := uintptr(unsafe.Pointer(&x))  // 使用 unsafe.Pointer 转换 &x 为 Pointer指针类型
	//tmp2 := unsafe.Offsetof(x.b)		// 返回 b 字段相对于 x 起始地址的偏移量,返回的是 uintptr 类型
	//pb := (*int16)(unsafe.Pointer(uintptr(tmp1) + tmp2))
	pb := (*int16)(unsafe.Pointer(uintptr(unsafe.Pointer(&x)) + unsafe.Offsetof(x.b)))
	*pb = 42
	fmt.Println(x.b)	// 42

}
```

上面的写法尽管很繁琐，但在这里并不是一件坏事，因为这些功能应该很谨慎地使用。不要试图引入一个`uintptr`类型的临时变量，因为它可能会破坏代码的安全性（注：这是真正可以体会unsafe包为何不安全的例子）。

**下面段代码是错误的**

```go
// NOTE: subtly incorrect!
tmp := uintptr(unsafe.Pointer(&x)) + unsafe.Offsetof(x.b)
pb := (*int16)(unsafe.Pointer(tmp))
*pb = 42
```

产生错误的原因很微妙。**有时候垃圾回收器会移动一些变量以降低内存碎片等问题。这类垃圾回收器被称为移动`GC`。当一个变量被移动，所有的保存改变量旧地址的指针必须同时被更新为变量移动后的新地址。从垃圾收集器的视角来看，一个`unsafe.Pointer`是一个指向变量的指针，因此当变量被移动是对应的指针也必须被更新；但是`uintptr`类型的临时变量只是一个普通的数字，所以其值不应该被改变。上面错误的代码因为引入一个非指针的临时变量`tmp`，导致垃圾收集器无法正确识别这个是一个指向变量x的指针。当第二个语句执行时，变量x可能已经被转移，这时候临时变量`tmp`也就不再是现在的`&x.b`地址。**第三个向之前无效地址空间的赋值语句将彻底摧毁整个程序！




### 6. 方法



#### 定义

方法是与对象实例绑定的特殊函数。

方法是面向对象编程的基本概念，用于维护和展示对象的自身状态。对象是内敛的，每个实例都有各自不同的独立特征，以属性和方法来暴露对外通信接口。普通函数则专注于算法流程，通过接收参数来完成特定逻辑运算，并返回最终结果。换句话说，方法是有关联状态的，而函数则没有。

方法和函数定义语句区别在于前者有前置实例接受参数（ receiver ），编译器以此确定方法所属类型。在某些语言里，尽管没有显示定义，但会在调用时隐式传递 this 实例参数。

可以为当前包，以及除接口和指针以外的任何类型定义方法。

```go
package main

import "fmt"

type N int

func (n N) toString() string {
	return fmt.Sprintf("%#x", n)
}

func main() {
	var a N = 25
	println(a.toString())
}
/*
0x19
 */
```

方法同样不支持重载（overload）。receiver 参数名没有限制，按惯例会选用简短有意义的名称（不推荐使用 this、 self）。如方法内部并不引用实例，可省略参数名，仅保留类型。

```go
package main

type N int

func (N) test() {
	println("hi!")
}
```

方法可看作特殊的函数，那么 receiver 的类型自然可以是基础类型或指针类型。这会关系到调用时对象实例是否被复制。

```go
package main

import "fmt"

type N int

func (n N) value() {					// func value(n N)
	n++
	fmt.Printf("v: %p, %v\n", &n,n)
}

func (n *N) pointer() {					// func pointer(n *N)
	(*n)++
	fmt.Printf("p: %p, %v\n", n, *n)
}

func main() {
	var a N = 25
	a.value()
	a.pointer()

	fmt.Printf("a: %p, %v\n", &a,a)
}
/*
v: 0xc00000a0d0, 26				reciver 被复制
p: 0xc00000a0b8, 26
a: 0xc00000a0b8, 26
 */

```

可使用实例值或指针调用方法，编译器会根据方法 receiver 类型自动在基础类型和指针类型间转换。

```go
package main

import "fmt"

type N int

func (n N) value() {					// func value(n N)
	n++
	fmt.Printf("v: %p, %v\n", &n,n)
}

func (n *N) pointer() {					// func pointer(n *N)
	(*n)++
	fmt.Printf("p: %p, %v\n", n, *n)
}

func main() {
	var a N = 25
	p := &a

	a.value()
	a.pointer()

	p.value()
	p.pointer()

	fmt.Printf("a: %p, %v\n", &a,a)
}
/*
v: 0xc00000a0d0, 26
p: 0xc00000a0b8, 26
v: 0xc00000a100, 27
p: 0xc00000a0b8, 27
a: 0xc00000a0b8, 27
 */

```

不能多级指针调用方法。

指针类型的 receiver 必须是合法指针（ 包括 nil ），或能获取实例地址。

```go
package main

type X struct {

}

func (x *X) test() {
	println("hi!", x)
}

func main() {
	var a *X
	a.test()			// 相当于 test(nil)
	X{}.test()			// 错误: cannot call pointer method on X{}
}
```

将方法看作普通函数，就能很容易理解 receiver 传参方式。



如何选择方法的 receiver 类型？

- 要修改实例状态，用 *T
- 无需修改状态的小对象或固定值，建议用 T
- 大对象建议用 *T，以减少复制成本
- 引用类型、字符串、函数等指针包装对象，直接用 T
- 若包含 `Mutex` 等同步字段，用 *T ，避免因复制造成锁操作无效
- 其他无法确定的情况，都用 *T

#### 匿名字段

可以像访问匿名字段成员那样调用其方法，由编译器负责查找。

```go
package main

import "sync"

type data struct {
	sync.Mutex
	buf [1024]byte
}

func main() {
	d := data{}
	d.Lock()					// 编译器会处理为 sync.(*Mutex).Lock() 调用
	defer d.Unlock()

}
```

方法也会有同名遮蔽问题。但利用这种特性，可实现类似覆盖（override）操作。

```go
package main

type user struct {}

type manager struct {
	user
}

func (user) toString() string {
	return "user"
}

func (m manager) toString() string {			// override user toString 方法,如果没有这个方法，下面的输出都是 user 字符串。这里实现了覆盖。
	return m.user.toString() + "; manager"
}

func main() {
	var m manager
	println(m.toString())
	println(m.user.toString())
}
/*
user; manager
user
 */
```

尽管能直接访问匿名字段的成员和方法，但他们依然不属于继承关系。



#### 方法集

类型有一个与之相关的方法集（ method set ），这决定了它是否实现了某个接口。

- 类型 T 方法集包含所有 receiver T 方法
- 类型 *T 方法集包含所有 receiver T + *T 方法
- 匿名嵌入 S ，T 方法集包含所有 receiver S 方法
- 匿名嵌入 *S， T 方法集包含所有 receiver S + *S 方法
- 匿名嵌入 S 或 `*S ，*T` 方法集包含所有 receiver S + *S 方法

可利用反射测试这些规则

```go
package main

import (
	"fmt"
	"reflect"
)

type S struct {}

type T struct {
	S									// 匿名嵌入字段
}

func (S) sVal() {}
func (*S) sPtr() {}
func (T) tVal() {}
func (*T) tPtr() {}

func methodSet(a interface{}) {			// 显示方法集里所有方法名字
	t := reflect.TypeOf(a)
	fmt.Println(t.NumMethod())
	for i,n := 0,t.NumMethod();i < n;i++ {
		m := t.Method(i)
		fmt.Println(m.Name, m.Type)
	}
}

func main() {
	var t T
	methodSet(t)						// 显示 T 方法集
	println("---------------")
	methodSet(&t)						// 显示 *T 方法集
}
```

上面的例子未测试出来？？？？



方法集仅影响接口实现和方法表达式转换，与通过实例或者实例指针调用方法无关。实例并不使用方法集，而是直接调用（或通过隐式字段名）。

很显然，匿名字段就是为方法集准备的。否则完全没必要为少些个字段名而大费周章。

面向对象的三大特征 "封装"， "继承"， "多态" , Go 仅实现了部分特征，它更倾向于 "组合优于继承" 这种思想。将模块分解成相互独立的更小单元，分别处理不同方面的需求，最终以匿名嵌入的方式组合到一起，共同实现对外接口。而且其简短一致的调用方式，更是隐藏了内部实现细节。

组合没有父子依赖，不会破坏封装。且整体和局部松耦合，可任意增加来实现扩展。各单元持有单一职责，互无关联，实现和维护更加简单。

接口也是多态的一种实现方式。



#### 表达式

方法和函数一样，除直接调用外，还可赋值给变量，或作为参数传递。依照具体引用方式不同，可分为 expression 和 value 两种状态。

**Method Expression**

通过类型引用的（类型直接调用方法） method expression 会被还原为普通函数样式，receiver 是第一参数，调用时须显式传参。至于类型，可以是 T 或者 *T ，只要目标方法存在于该类型方法集中即可。

```go
package main

import "fmt"

type N int

func (n N) test() {
	fmt.Printf("test.n: %p, %d\n", &n, n)
}

func main() {
	var n N = 25
	fmt.Printf("main.n: %p, %d\n", &n,n)

	f1 := N.test							// func(n N)
	f1(n)

	f2 := (*N).test							// func(n *N)
	f2(&n)									// 按方法集中的签名传递正确类型的参数
}

/*
main.n: 0xc000128058, 25
test.n: 0xc000128078, 25
test.n: 0xc000128090, 25
 */
```

尽管 *N 方法集包装的 test 方法 receiver 类型不同，但编译器会保证按原定义类型拷贝传值。

当然，也可以直接以表达式的方式调用。

```go
func main() {
	var n N = 25

	N.test(n)
	(*N).test(&n)			//	注意: *N 须使用括号，以免语法解析错误

}
```



**Method Value**

基于实例或指针引用的 method value ，参数签名不会改变，依旧按正常方式调用。

但当 method value 被赋值给变量或作为参数传递时，会立即计算并复制该方法执行所需的 receiver 对象，与其绑定，以便在稍后执行时，能隐式传入 receiver 对象。

```go
package main

import "fmt"

type N int

func (n N) test() {
	fmt.Printf("test.n: %p, %v\n", &n, n)
}

func main() {
	var n N = 100
	p := &n

	n++
	f1 := n.test				// 因为 test 方法的 receiver 是 N 类型，所以复制 n， 等于101

	n++
	f2 := p.test				// 复制 *p ，等于 102

	n++
	fmt.Printf("main.n: %p, %v\n", p,n)
	f1()
	f2()
}
/*
main.n: 0xc00000a0b8, 103
test.n: 0xc00000a0d8, 101
test.n: 0xc00000a0f0, 102
 */
```

编译器会为 method value 生成一个包装函数，实现间接调用。至于 receiver 复制，和 闭包的实现方法基本相同，打包成 `funcval` ，经由 `DX`寄存器传递。



当 method value 作为参数时，会复制含 receiver 在内的整个 method value

```go
package main

import "fmt"

type N int

func (n N) test() {
	fmt.Printf("test.n: %p, %v\n", &n, n)
}

func call(m func()) {
	m()
}

func main() {
	var n N = 100
	p := &n

	fmt.Printf("main.n: %p, %v\n",p,n)

	n++
	call(n.test)
	n++
	call(p.test)
}

/*
main.n: 0xc00000a0b8, 100
test.n: 0xc00000a0d8, 101
test.n: 0xc00000a0f0, 102
 */
```

当然，如果目标方法的 receiver 是指针类型，那么被复制的仅是指针。

```go
package main

import "fmt"

type N int

func (n *N) test() {
	fmt.Printf("test.n: %p, %v\n", n, *n)
}

func call(m func()) {
	m()
}

func main() {
	var n N = 100
	p := &n

	fmt.Printf("main.n: %p, %v\n",p,n)

	n++
	call(n.test)		// 因为 test 方法的 receiver 是 *N 类型，所以复制 &n
	n++
	call(p.test)		// 复制 p 指针
}

/*
main.n: 0xc0000ac058, 100
test.n: 0xc0000ac058, 101
test.n: 0xc0000ac058, 102
 */
```

只要 receiver 参数类型正确，使用 nil 同样可以执行。

```go
package main

type N int

func (N) value() {}
func (*N) pointer() {}

func main() {
	var p *N
	p.pointer()				// method value
	(*N)(nil).pointer()		// method value
	(*N).pointer(nil)		// method expression

	p.value()				// 错误: invalid memory address or nil pointer dereference
}
```







------

以下部分不是书籍内容:

#### 重写 （override）和 重载（overload）

以 Python 为例子



**重写**

**概念**：方法重写又称为方法覆盖，即子类不想原封不动的继承父类的方法，而是想做一定的修改，这就需要采用方法的重写。

**条件**

1. 参数列表必须完全和被重写方法参数列表一致（ Python 无此限制 ）
2. 返回值类型必须完全和被重写方法的返回值类型一致（ Python无此限制 ）
3. 访问修饰符的限制一定要大于被重写方法的访问修饰符（ 以 `java` 为例： public > protect > private , Python通过下划线控制访问权限 ）

Python 代码：

```python
class A(object):

    def fun(self, v):
        print(f"class_A:{v}")
        return "aa"


class B(A):
    # 重写 A 类 fun 方法
    def fun(self, **v):
        print(f"class_B:{v}")
        return 1

if __name__ == "__main__":
    b = B()
    print(b.fun(a="HELLO"))
    """
    output:
    class_B:{'a': 'HELLO'}
    1
    """
```



**重载**

**概念**：仅仅当两个函数除了参数类型和参数个数不同以外，其功能是完全相同的，此时才使用函数重载，函数重载主要是为了解决两个问题：**可变参数类型，可变参数个数**

**条件**

1. 一个类里面
2. 方法名字相同
3. 参数不同

情况1：

**情况 1 ：**
 函数功能相同，但是参数类型不同，python 如何处理？答案是根本不需要处理，因为 python 可以接受任何类型的参数，如果函数的功能相同，那么不同的参数类型在 python 中很可能是相同的代码，没有必要做成两个不同函数。
 **情况 2**
 函数功能相同，但参数个数不同，python 如何处理？大家知道，答案就是缺省参数。对那些缺少的参数设定为缺省参数即可解决问题。因为你假设函数功能相同，那么那些缺少的参数终归是需要用的。
 **结论：**鉴于情况 1 跟 情况 2 都有了解决方案，python 自然就不需要函数重载了。


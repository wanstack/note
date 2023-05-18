### 5. 数据

#### 字符串

字符串是不可变字节（ byte ）序列，其本身是一个复合结构。

```go
type stringStruct struct {
    str unsafe.Pointer
    len int
}
```

头部指针指向字节数组，但没有 NULL 结尾。默认以 UTF-8 编码存储 Unicode 字符，字面量里允许使用十六进制、八进制和 UTF 编码格式。

```go
package main

import "fmt"

func main() {
   s := "大师\x61\142\u0041"
   fmt.Println(s)
   fmt.Printf("%s\n", s)
   fmt.Printf("%x, len: %d\n", s,len(s))
}
/*
大师abA
大师abA
e5a4a7e5b888616241, len: 9
 */
```

内置函数 len 返回字节数组长度，cap 不接受字符串类型参数

字符串默认值不是 nil，而是 ""

使用 “ ` ” 反引号定义不做转移处理的原始字符串（ raw string ），支持跨行。

```go
package main

func main() {
   s := `line\r\n
line2`
   println(s)
}
/*
line\r\n
line2
 */
```

编译器不会解析原始字符串内的注释语句，且前置索引空格也属于字符串内容。

支持 " != 、==、< 、> 、+、+= " 操作符

```
package main

func main() {
   s := "ab" +                   // 跨行时，加法操作符必须在上一行结尾
      "cd"

   println(s == "abcd")
   println(s > "abc")
}
/*
true
true
 */
```

允许以索引号访问字节数组（ 非字符 ），但不能获取元素地址

```go
package main

func main() {
	s := "abc"
	println(s[1])
	println(&s[1])			// cannot take the address of s[1]
}
```

以切片语法（ 起始和结束索引号 ）返回子串时，其内部依旧指向原字节数组。

```go
package main

import (
	"fmt"
	"reflect"
	"unsafe"
)

func main() {
	s := "abcdefg"
	s1 := s[:3]				// 从头开始，仅指定结束索引位置
	s2 := s[1:4]			// 指定开始和结束位置，返回 [start, end]
	s3 := s[2:]				// 指定开始位置，返回后面全部内容

	println(s1,s2,s3)

	// 提示：
	// reflect.StringHeader 和 string 头结构相同
	// unsafe.Pointer 用于指针类型转换

	fmt.Printf("%#v\n", (*reflect.StringHeader)(unsafe.Pointer(&s)))
	fmt.Printf("%#v\n", (*reflect.StringHeader)(unsafe.Pointer(&s1)))
}
/*
&reflect.StringHeader{Data:0x80edfd, Len:7}
&reflect.StringHeader{Data:0x80edfd, Len:3}
abc bcd cdefg
 */
```

使用 for 遍历字符串时，分 byte 和 rune 两种方式。

```go
package main

import "fmt"

func main() {
	s := "士大"

	for i := 0; i < len(s); i++ {		// byte
		fmt.Printf("%d: [%c]\n", i, s[i])
	}

	for i,c := range s	{				// rune: 返回数组索引号, 以及 Unicode 字符
		fmt.Printf("%d, [%c]\n", i, c)
	}

}
/*
0: [å]
1: [£]
2: [«]
3: [å]
4: [¤]
5: [§]
0, [士]
3, [大]
 */
```



**转换**

要转换字符串，须将其转换为可变类型（ [ ]rune 或 [ ]byte ）, 待完成后再转换回来。但不管如何转换，都须重新分配内存，并赋值数据。

```go
package main

import (
	"fmt"
	"reflect"
	"unsafe"
)

func pp(format string, ptr interface{}) {
	p := reflect.ValueOf(ptr).Pointer()
	h := (*uintptr)(unsafe.Pointer(p))
	fmt.Printf(format, *h)
}

func main() {
	s := "hello, world!"
	pp("s: %x\n", &s)

	bs := []byte(s)
	s2 := string(bs)

	pp("string to []byte, bs: %x\n", &bs)
	pp("[]byte to string, s2: %x\n", &s2)

	rs := []rune(s)
	s3 := string(rs)

	pp("string to []rune, rs: %x\n", &rs)
	pp("[]rune to string, s3: %x\n", &s3)

}

/*
s: 92feb3
string to []byte, bs: c00000a100
[]byte to string, s2: c00000a110
string to []rune, rs: c000010280
[]rune to string, s3: c00000a130

注: 关于反射内容有专门章节讲解，这个仅作为测试上面说法是否正确
 */
```

某些时候，转换操作会拖累算法性能，可尝试用 “ 非安全 ” 方法进行改善。

```go
package main

import (
	"fmt"
	"unsafe"
)

func toString(bs []byte) string {
	return *(*string)(unsafe.Pointer(&bs))
}

func main() {
	bs := []byte("hello, world!")
	s := toString(bs)

	fmt.Printf("bs: %x\n", &bs)
	fmt.Printf("s: %x\n", &s)
}
```

该方法利用了 []byte 和 string 头结构 " 部分相同 " ，以非安全的指针类型来实现类型  " 变更 "， 从而避免的底层数组复制。在很多 Web Framework 中都能看到此类做法，在高并发压力下，此种做法能有效改善执行性能。只是使用 unsafe 存在一定风险，须小心谨慎。



用 append 函数，可将 string 直接追加到 []byte 内。

```go
package main

import "fmt"

func main() {
	var bs []byte
	bs = append(bs, "abc"...)
	fmt.Println(bs)
}
/*
[97 98 99]
 */
```

考虑到字符串只读特征，转换时复制数据到新分配内存是可以理解的。当然性能同样重要，编译器会为某些场合进行专门优化，避免额外分配和复制操作：

	- 将 []byte 转换为 string key，去 map[string] 查询时
	- 将 string 转换为 []byte , 进行for range 迭代时，直接取字节赋值给局部变量。

用GDB 验证一下这种说法是否正确：

```go
[root@localhost 4]# cat 1.go 
package main

func main() {
	m := map[string]int {
		"abc": 123,
	}

	key := []byte("abc")
	x, ok := m[string(key)]

	print(x,ok)
}

[root@localhost 4]# go build -gcflags "-N -l" 1.go 		// 阻止优化
[root@localhost 4]# gdb 1
...
"Auto-loading safe path" section in the GDB manual.  E.g., run from the shell:
	info "(gdb)Auto-loading safe path"
(gdb) b 9												// 在第 9 行打上断点
Breakpoint 1 at 0x4562ce: file /opt/go/4/1.go, line 9.
(gdb) r
Starting program: /opt/go/4/1 

Breakpoint 1, main.main () at /opt/go/4/1.go:9
9		x, ok := m[string(key)]
(gdb) info locals 												// 显示局部变量
key = {array = 0xc00002e5fd "abc(\346\002", len = 3,cap = 3}// key 底层数组地址0xc00002e5fd 
m = 0xc00002e670
x = 824633910824
ok = false
(gdb) b runtime.mapaccess2_faststr							// 在 map 访问函数上打上断点
Breakpoint 2 at 0x40d7e0: file /usr/lib/golang/src/runtime/map_faststr.go, line 107.
(gdb) c
Continuing.

Breakpoint 2, runtime.mapaccess2_faststr (t=0x45c960, h=0xc00002e670, ky=...) at /usr/lib/golang/src/runtime/map_faststr.go:107
107	func mapaccess2_faststr(t *maptype, h *hmap, ky string) (unsafe.Pointer, bool) {
(gdb) info args								// 显示函数参数信息
t = 0x45c960
h = 0xc00002e670
ky = 0xc00002e5fd "abc"					// 和 key []byte 底层数组地址相同，证明没有分配和复制

```

**性能**

除类型转换外，动态构建字符串也容器造成性能问题。

用加法操作符拼接字符串时，每次都需重新分配内存。如此，在构建超大字符串时，性能就显得极差。

str.go

```go
package main


func test() string {
	var s string
	for i:=0;i<1000;i++ {
		s += "a"
	}
	return s
}
```

str_test.go

```go
package main

import "testing"

func BenchmarkTest(b *testing.B) {
	for i:=0; i<b.N; i++ {
		test()
	}
}
```

```shell
D:\go-module\5>go test -bench=. -run=none
goos: windows
goarch: amd64
pkg: 4/5
cpu: Intel(R) Core(TM) i7-10510U CPU @ 1.80GHz
BenchmarkTest-8             6442            164988 ns/op
PASS
ok      4/5     3.202s

"""
1. 使用 go test 命令，加上 -bench= 标记，接受一个表达式作为参数, .表示运行所有的基准测试
2. 因为默认情况下 go test 会运行单元测试，为了防止单元测试的输出影响我们查看基准测试的结果，可以使用-run=匹配一个从来没有的单元测试方法，过滤掉单元测试的输出，我们这里使用none，因为我们基本上不会创建这个名字的单元测试方法。
3. BenchmarkTest-8 这个 -8 表示运行时对应的GOMAXPROCS的值。
4. 接着的 6442 表示运行for循环的次数也就是调用被测试代码的次数.
5. 最后的 164988 ns/op表示每次需要花费 164988 纳秒。(执行一次操作花费的时间)
6. 以上是测试时间默认是1秒，也就是1秒的时间，调用 6442 次，每次调用花费 164988 纳秒

测试整个文件：$ go test -v hello_test.go
测试单个函数：$ go test -v hello_test.go -test.run TestHello
"""
```

改进思路是预分配足够的内存空间。常用的方法是 strings.Join 函数，它会统计所有参数长度，并一次性完成内存分配操作。

str.go

```go
package main

import (
	"bytes"
	"strings"
)

func test1() string {
	var s string
	for i:=0;i<1000;i++ {
		s += "a"
	}
	return s
}

func test2() string {
	s := make([]string, 1000)			// 分配足够的内存，避免中途扩张底层数组
	for i:=0;i<1000;i++ {
		s[i] = "a"
	}
	return strings.Join(s, "")
}

func test3() string {
	var b bytes.Buffer
	b.Grow(1000)				// 事先准备充足的内存，避免中途扩张

	for i:=0; i<1000; i++ {
		b.WriteString("a")
	}
	return b.String()
}

func main() {
	test2()
}

```

str_test.go

```go
package main

import "testing"

func BenchmarkTest1(b *testing.B) {
	for i:=0; i<b.N; i++ {
		test1()
	}
}

func BenchmarkTest2(b *testing.B) {
	for i:=0; i<b.N;i++ {
		test2()
	}
}

func BenchmarkTest3(b *testing.B) {
	for i:=0; i<b.N;i++ {
		test3()
	}
}


/*
D:\go-module\5>go test -bench=. -run=none
goos: windows
goarch: amd64
pkg: 4/5
cpu: Intel(R) Core(TM) i7-10510U CPU @ 1.80GHz
BenchmarkTest1-8            8586            148487 ns/op
BenchmarkTest2-8          106303             10223 ns/op
BenchmarkTest3-8          179726              7041 ns/op
PASS
ok      4/5     5.008s
*/
//  从上面结果可以看出 test2, test3 比 test1 效率更高， 其中 test3 效率最高
```

编译器对 " s1 + s2 + s3 " 这类表达式的处理方式和 string.Join 类似。

对于数量较少的字符串格式化拼接，可使用 fmt.Sprintf 、text/template 等方法。

字符串操作通常在堆上分配内存，这会对 Web 等高性能并发应用造成较大影响，会有大量字符串对象要做垃圾回收。建议使用 []byte 缓存池，或在栈上自行拼接等方式来实现 zero-garbage。



**Unicode**

类型 rune 专门用来存储 Unicode 码点（code point），它是 int32 的别名，相当于 UCS-4/UTF-32 编码格式。使用单引号的字面量，其默认类型就是 rune。

```go
package main

import "fmt"

func main() {
	r := '我'
	fmt.Printf("%T\n", r)
}
/*
int32
 */
```

除 []rune 外，还可以直接在 rune，byte，string 间进行转换。

```go
package main

import "fmt"

func main() {
	r := '我'

	s := string(r)		// rune to string
	b := byte(r)		// rune to byte

	s2 := string(b)		// byte to string
	r2 := rune(b)		// byte to rune

	fmt.Println(s,b,s2,r2)
}
/*
我 17  17
 */
```

要知道字符串存储的字节数组，不一定就是合法的 UTF-8 文本。

```go
package main

import (
	"fmt"
	"unicode/utf8"
)

func main() {
	s := "不是的"
	s = string(s[0:1] + s[3:4])			// 截取并拼接一个不合法的字符串

	fmt.Println(s, utf8.ValidString(s))
}
/*
�� false
 */
```

标准库 unicode 里提供了丰富的操作函数。除验证函数外，还可以用 RuneCountInString 代替 len 返回准确的 Unicode 字符数量。

```go
package main

import "unicode/utf8"

func main() {
	s := "士大夫"
	println(len(s), utf8.RuneCountInString(s))
}
/*
9 3
 */
```



#### 数组

定义数组类型时，数组长度必须是 **非负整型 常量** 表达式，长度是类型组成部分。也就是说，元素类型相同，但长度不同的数组不属于同一类型。

```go
package main

func main() {
	var d1 [3]int
	var d2 [2]int
	d1 = d2			// cannot use d2 (type [2]int) as type [3]int in assignment
}
```

灵活的初始化方式

```go
package main

import "fmt"

func main() {
	var a [4]int				// 元素自动初始化为零
	b := [4]int{2,5}			// 未提供初始化的元素自动初始化为零
	c := [4]int{5, 3:10}		// 可指定索引位置初始化
	d := [...]int{1,2,3,4,5}	// 编译器按初始化值数量确定数组长度
	f := [...]int{1,2, 3:10}	// 支持索引初始化，但注意数组长度与此有关

	fmt.Println(a,b,c,d,f)
}
/*
[0 0 0 0] [2 5 0 0] [5 0 0 10] [1 2 3 4 5] [1 2 0 10]
 */
```

对于结构等复合类型，可省略元素初始化类型标签

```go
package main

import "fmt"

func main() {
	type user struct {
		name string
		age byte
	}

	d := [...]user {
		{"Tom", 12},
		{"Marry", 13},
	}
	fmt.Printf("%#v\n", d)
}
/*
[2]main.user{main.user{name:"Tom", age:0xc}, main.user{name:"Marry", age:0xd}}
 */
```

在定义多为数组时，仅第一维度允许使用 "...", 二维数组又称为 数组的数组，即数组的类型是一个数组

```go
package main

import "fmt"

func main() {
	a := [2][3]int {		// 定义一个长度为2 ，类型(元素)为 [3]int 的数组
		{1,2,3},
		{4,5,6},
	}

	b := [...][2]int {		// 定义一个长度未知，类型(元素)为 [2]int 的数组
		{10,20},
		{30,40},
	}

	c := [...][2][2]int {	// 三维数组，定义一个长度未知，类型为 [2][2]int 的数组
		{
			{1,2},
			{3,4},
		},
		{
			{5,6},
			{7,8},
		},
	}

	fmt.Println(a)
	fmt.Println(b)
	fmt.Println(c)
}

/*
[[1 2 3] [4 5 6]]
[[10 20] [30 40]]
[[[1 2] [3 4]] [[5 6] [7 8]]]
 */
```

内置函数 len 和 cap 都返回第一维度长度

```go
package main

import "fmt"

func main() {
	a := [2]int{}
	b := [...][2]int {
		{1,2},
		{3,4},
		{5,6},
	}
	fmt.Println(len(a), cap(a))
	fmt.Println(len(b), cap(b))
	fmt.Println(len(b[1]), cap(b[1]))
}
/*
2 2
3 3
2 2
 */
```

如元素类型支持  ”== ，!= " 操作符，那么数组也支持此操作

```go
package main

func main() {
	var a,b [2]int
	println(a==b)

	c := [2]int{1,2}
	d := [2]int{0,1}
	println(c!=d)

	var e,f [2]map[string]int
	println(e==f)		// invalid operation: e == f ([2]map[string]int cannot be compared)
}

```



**指针**

要分清指针数组和数组指针的区别。

指针数组是指 元素为指针的数组；本质是一个数组

数组指针是指 获取数组变量的地址；本质是一个 指针

```go
package main

import "fmt"

func main() {
	x,y := 10,20
	a := [...]*int{&x,&y}				// 元素为指针的 指针数组
	p := &a								// 存储数组地址的指针

	fmt.Printf("%T, %v\n", a,a)
	fmt.Printf("%T, %v\n", p,p)
}
/*
[2]*int, [0xc00000a0b8 0xc00000a0d0]
*[2]*int, &[0xc00000a0b8 0xc00000a0d0]
 */
```

可获取任意元素地址

```go
package main

func main() {
	a := [...]int{1,2}
	println(&a, &a[0], &a[1])
}
/*
0xc00003ff68 0xc00003ff68 0xc00003ff70
 */
```

数组指针可直接用来操作数组元素

```go
package main

import "fmt"

func main() {
	a := [...]int{1,2}
	p := &a
	p[1] += 10
	fmt.Printf("%T, %#v\n", p,p)
	fmt.Printf("%T, %#v\n", p[1],p[1])
}
/*
*[2]int, &[2]int{1, 12}
int, 12
 */
```

可通过 unsafe.Pointer 转换不同长度的数组指针来实现越界访问，或使用参数  gcflags "-B" 阻止编译器插入检查指令。



**复制**

与 C 数组变量隐式作为指针使用不同，Go 数组是值类型，赋值和传参操作都会复制整个数组数据。

```go
package main

import "fmt"

func test(x [2]int) {
	fmt.Printf("x: %p, %v\n", &x,x)
}

func main() {
	a := [2]int{10,20}
	var b [2]int

	b = a
	fmt.Printf("a: %p, %v\n", &a, a)
	fmt.Printf("b: %p, %v\n", &b, b)
	test(a)
}
/*
a: 0xc00000a0d0, [10 20]
b: 0xc00000a0e0, [10 20]
x: 0xc00000a130, [10 20]
 */
```

如果需要，可改用指针或切片，以此避免数据复制。

```go
package main

import "fmt"

func test(x *[2]int) {
	fmt.Printf("x: %p, %v\n", x, *x)
	x[1] += 100
}

func main() {
	a := [2]int{10,20}
	test(&a)
	fmt.Printf("a: %p, %v\n", &a, a)
}
/*
x: 0xc00000a0d0, [10 20]
a: 0xc00000a0d0, [10 120]
 */
```



#### 切片

切片（slice） 本身并非动态数据或数据指针。它内部通过指针引用底层数组，设定相关属性将数据读写操作限定在指定区域内。

```go
type slice struct {
    array unsafe.Pointer
    len int
    cap int
}
```

切片本身是个只读对象，其工作机制类似数组指针的一种包装。

可基于数组或数组指针创建切片，以开始和结束索引位置确定所引用的数组片段。不支持反向索引，实际范围是一个右半开区间。

```shell
x := [...]int{0,1,2,3,4,5,6,7,8,9}

expression		slice						len		cap
--------------+---------------------------+-------+--------------------------
x[:]			[0,1,2,3,4,5,6,7,8,9]		10		10		// low=0,hight=10,max=10
x[2:5]			[2,3,4]						3		8		// low=2,hight=5,max=10	
x[2:5:7]		[2,3,4]						3		5		// low=2,hight=5,max=7
x[4:]			[4,5,6,7,8,9]				6		6		// low=4,hight=10,max=10
x[:4]			[0,1,2,3]					4		10		// low=0,hight=4,max=10
x[:4:6]			[0,1,2,3]					4		6		// low=0,hight=4,max=6 
	
```

属性示意图：

```shell
			low:2		hight:5	max:7
			|			|		|						len = hight - low
			|			|		|						cap = max - low
	+---+---+---+---+---+---+---+---+---+---+			+-----+---+---+
x	| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |			| ptr | 3 | 5 |	x[2:5:7]
	+---+---+---+---+---+---+---+---+---+---+			+-----+---+---+
			|			|		|						   |
			|<-- len -->|		|						   |
			|					|						   |
			|<------ cap ------>| 						   |
			|											   |	
			|<----------------- array pointer <------------+
```

属性 cap 表示切片所引用数组片段的真实长度，len 用于限定可读可写的元素数量。另外，数组必须 addressable（可寻址），否则会引发错误。

```go
package main

import "fmt"

func main() {
	m := map[string][2]int {
		"a": {1,2},
	}
	s := m["a"][:]				// invalid operation m["a"][:] (slice of unaddressable value)
	fmt.Println(s)
}
```

和数组一样，切片同样使用索引号访问元素内容。起始索引为 0，而非对应的底层数组真实索引位置。

```go
package main

func main() {
	a := [...]int{0,1,2,3,4,5,6,7,8,9}
	s := a[2:5]

	for i:=0; i<len(s);i++ {
		println(s[i])
	}
}
/*
2
3
4
 */
```

可直接创建切片对象，无须预先准备数组。因为是引用类型，须使用 make 函数或显式初始化语句，它会自动完成底层数组内存分配。

```go
package main

import "fmt"

func main() {
	s1 := make([]int, 3,5)		//	 指定len，cap，底层数组初始化为 零值
	s2 := make([]int,3)			//   省略 cap，和 len相等
	s3 := []int{10,20,5:30}		//   按初始化元素分配底层数组，并设置 len，cap

	fmt.Println(s1, len(s1),cap(s1))
	fmt.Println(s2, len(s2),cap(s2))
	fmt.Println(s3, len(s3),cap(s3))
}
/*
[0 0 0] 3 5
[0 0 0] 3 3
[10 20 0 0 0 30] 6 6
 */
```

注意下面两种定义方式的区别。前者仅定义了一个 []int 类型的变量，并未执行初始化操作，而后者则用初始化表达式完成了全部创建过程。

```go
package main

func main() {
	var a []int
	b := []int{}

	println(a==nil,b==nil)
}
/*
true false
 */
```

通过输出更详细的信息，我们可以看到这两者的差异。

```go
package main

import (
	"fmt"
	"reflect"
	"unsafe"
)

func main() {
	var a []int
	b := []int{}

	fmt.Printf("a: %#v\n", (*reflect.SliceHeader)(unsafe.Pointer(&a)))
	fmt.Printf("b: %#v\n", (*reflect.SliceHeader)(unsafe.Pointer(&b)))
	fmt.Printf("a size: %d\n", unsafe.Sizeof(a))
}
/*
a: &reflect.SliceHeader{Data:0x0, Len:0, Cap:0}
b: &reflect.SliceHeader{Data:0x26ce00, Len:0, Cap:0}
a size: 24
 */
```

变量 b 的内部指针被赋值，尽管它指向 runtime.zerobase , 但它依然完成了初始化操作。另外 a==nil, 仅表示它是个未初始化的切片对象，切片本身依然会分配所需内存。可以直接对 nil 切片执行 slice[:] 操作，同样返回 nil。

不支持比较操作，就算元素类型支持也不行，仅能判断是否为 nil。

```go
package main

func main() {
	a := make([]int, 1)
	b := make([]int, 1)
	println(a==b)			// invalid operation: a == b (slice can only be compared to nil)
}
```

可获取元素地址，但不能像数组那样直接用指针访问元素内容。

```go
package main

import "fmt"

func main() {
	s := []int {0,1,2,3,4}

	p := &s							// 获取 header 地址
	p0 := &s[0]						// 获取 array[0]的地址
	p1 := &s[1]
	fmt.Println(p,p0,p1)

	//s[0] += 100						// [100 1 2 3 4]
	(*p)[0] += 100						// [100 1 2 3 4], *[]int 不支持索引操作，须先返回 []int 对象
	*p1 += 100
	fmt.Println(s)
}

/*
&[0 1 2 3 4] 0xc00000c360 0xc00000c368
[0 101 2 3 4]
 */
```

如果元素类型也是切片，那么就可以实现类似交错数组功能（jagged array）。

```go
package main

import "fmt"

func main() {
	x := [][]int {
		{1,2},
		{10,20,30},
		{100},
	}
	fmt.Println(x[1])
	x[2] = append(x[2], 200,300)
	fmt.Println(x[2])
}
/*
[10 20 30]
[100 200 300]
 */
```

很显然，切片是很小的结构体对象，用来代替数组传参可避免复制开销。还有，make 函数允许在运行期动态指定数组长度，绕开了数组类型必须使用编译期常量的限制。意思是 make 函数可以让切片在运行期间动态扩容，而数组则需要在运行之前就需要确定数组大小，不能动态扩缩容。

并非所有时候都适合用切片代替数组，因为切片底层数组可能会在堆上分配内存。而且小数组在栈拷贝上的消耗比 make 要小。

1_test.go

```go
package main

import "testing"

func array() [1024]int {
	var x [1024]int
	for i:=0;i<len(x);i++ {
		x[i] = i
	}

	return x
}

func slice() []int {
	x := make([]int, 1024)
	for i:=0;i<len(x);i++ {
		x[i] = i
	}

	return x
}

func BenchmarkArray(b *testing.B) {
	for i:=0;i<b.N;i++ {
		array()
	}
}

func BenchmarkSlice(b *testing.B) {
	for i:=0;i<b.N;i++ {
		slice()
	}
}


```

```shell
D:\go-module\5>go test -v 1_test.go -bench=. -run=none
goos: windows
goarch: amd64
cpu: Intel(R) Core(TM) i7-10510U CPU @ 1.80GHz
BenchmarkArray
BenchmarkArray-8         2831780               416.1 ns/op
BenchmarkSlice
BenchmarkSlice-8         4193329               275.3 ns/op
PASS
ok      command-line-arguments  4.329s

# 测试结果 还是 slice 比较省时间
```



**reslice**

根据切片创建新的切片对象，不能超出 cap ，但是不受 len 影响。

```shell
	+---+---+---+---+---+---+---+---+---+---+
	| 0 | 1 | 2 | 3 | 4 | 5 | 6 |   |   |   |			s			len=6,cap=10
	+---+---+---+---+---+---+---+---+---+---+
	0			3					8		10
				+---+---+---+---+---+---+---+
				| 3 | 4 | 5 | 6 | 0 |   |   |			s1=s[3:8]	len=5,cap=7
				+---+---+---+---+---+---+---+
				0		2		4		6
						+---+---+---+---+
						| 5 | 6 | 0 | 0 |				s2=s1[2:4:6] len=2,cap=4
						+---+---+---+---+
						0	1
	
						+---+---+---+---+---+
						| 5 |   |   |   |  |			s3=s2[:1:5]	error: out of range
						+---+---+---+---+---+
```

新建切片对象依旧指向原底层数组，也就是说修改对所有关联切片可见。

```go
package main

import "fmt"

func main() {
	d := [...]int{0,1,2,3,4,5,6,7,8,9}

	s1 := d[3:7]				// [3,4,5,6,,,]  len=4, cap=7
	s2 := s1[1:3]				// [4,5,,,,], len=2, cap=6

	for i := range s2 {
		s2[i] += 100
	}

	fmt.Println(d,len(d), cap(d))
	fmt.Println(s1,len(s1), cap(s1))
	fmt.Println(s2,len(s2), cap(s2))
}
/*
[0 1 2 3 104 105 6 7 8 9] 10 10
[3 104 105 6] 4 7
[104 105] 2 6
 */
```

利用 `reslice` 操作，很容易就能实现一个栈式数据结构

```go
package main

import (
	"errors"
	"fmt"
)

func main() {
	// 栈最大容量 5
	stack := make([]int,0,5)

	// 入栈
	push := func(x int) error {
		n := len(stack)
		if n == cap(stack) {		// 栈满
			return errors.New("stack is full")
		}

		stack = stack[:n+1]
		stack[n] = x
		return nil
	}

	// 出栈
	pop := func() (int,error) {
		n := len(stack)
		if n == 0 {				// 栈空
			return 0,errors.New("stack is empty")
		}

		x := stack[n-1]
		stack = stack[:n-1]
		return x,nil
	}

	// 入栈测试
	for i:=0; i<7;i++ {
		fmt.Printf("push %d: %v, %v\n", i, push(i), stack)
	}

	// 出栈测试
	for i:=0;i<7;i++ {
		x,err := pop()
		fmt.Printf("pop: %d, %v,%v\n", x,err,stack)
	}
}

/*
push 0: <nil>, [0]
push 1: <nil>, [0 1]
push 2: <nil>, [0 1 2]
push 3: <nil>, [0 1 2 3]
push 4: <nil>, [0 1 2 3 4]
push 5: stack is full, [0 1 2 3 4]
push 6: stack is full, [0 1 2 3 4]
pop: 4, <nil>,[0 1 2 3]
pop: 3, <nil>,[0 1 2]
pop: 2, <nil>,[0 1]
pop: 1, <nil>,[0]
pop: 0, <nil>,[]
pop: 0, stack is empty,[]
pop: 0, stack is empty,[]
 */
```

**append**

向切片尾部 （ `slice[len]` ）添加数据, 返回新的切片对象。

```go
package main

import "fmt"

func main() {
	s := make([]int,0,5)

	s1 := append(s, 10)
	s2 := append(s1, 20,30)		// 追加多个数据

	fmt.Println(s, len(s), cap(s))			// 不会修改原 slice 属性
	fmt.Println(s1, len(s1), cap(s1))
	fmt.Println(s2, len(s2), cap(s2))
}

/*
[] 0 5
[10] 1 5
[10 20 30] 3 5
 */
```

数据被追加到原底层数组。如果超出 cap 限制，则为新切片对象重新分配数组。

```go
package main

import "fmt"

func main() {
	s := make([]int, 0,100)
	s1 := s[:2:4]
	s2 := append(s1, 1,2,3,4,5)	// 超出 cap 限制，重新分配新底层数组

	fmt.Printf("s1: %p: %v\n", &s1[0], s1)
	fmt.Printf("s2: %p: %v\n", &s2[0], s2)

	fmt.Printf("s data: %v\n", s[:10])
	fmt.Printf("s1 cap: %d, s2 cap: %d\n", cap(s1), cap(s2))
}
/*
s1: 0xc000110000: [0 0]
s2: 0xc000010200: [0 0 1 2 3 4 5]	// 数组地址不同，确认重新分配
s data: [0 0 0 0 0 0 0 0 0 0]		// append 并未向原数组写入数据
s1 cap: 4, s2 cap: 8				// 新数组是原 cap 的2倍
 */
```

注意：

- 是超出切片的 cap 限制，而非底层数组长度限制，因为 cap 可能小于数组长度
- 新分配数组长度是原 cap 的2倍，而非原数组的 2 倍。

并非总是 2 倍，对于较大切片，会尝试扩容 1/4 ，以节约内存。

向 nil 切片追加数据时，会为其分配底层数组内存。

```go
package main

import "fmt"

func main() {
	var s []int
	s = append(s, 1,2,3)
	fmt.Println(s)
}
/*
[1 2 3]
 */
```

正因为存在重新分配底层数组的缘故，在某些场合建议预留足够多的空间，避免中途内存分配和数据复制开销。

**copy**

在两个切片对象间复制数据，允许指向同一底层数组，允许目标区间重叠。最终所复制长度以较短的切片长度（`len`）为准。

```go
package main

import "fmt"

func main() {
	s := []int{0,1,2,3,4,5,6,7,8,9}
	s1 := s[5:8]
	n := copy(s[4:], s1)		// 在同一底层数组的不同区间复制
	fmt.Println(s1)
	fmt.Println(s)
	fmt.Println(n)
	/*
	[6 7 7]
	[0 1 2 3 5 6 7 7 8 9]
	3
	 */

	s2 := make([]int,6)			// 在不同数组间复制
	n = copy(s2, s)
	fmt.Println(n,s2) 			// 6 [0 1 2 3 5 6]
}
```

还可以直接从字符串中复制数据到 []byte 

```go
package main

import "fmt"

func main() {
	b := make([]byte, 3)
	n := copy(b, "abcde")
	fmt.Println(n,b)
}
/*
3 [97 98 99]
 */
```

如果切片长时间引用大数组中很小的片段，那么建议新建独立切片，复制出所需数据，以便原数组内存可被及时回收。



#### 字典

字典（哈希表）是一种使用频率极高的数据结构。将其作为语言内置类型，从运行时层面进行优化，可获得更高的性能。

作为无序键值对集合，字典要求 key 必须是支持相等运算符（ ==，!= ）的数据类型，比如，数字、字符串、指针、数据、结构体，以及对应接口类型。

字典是引用类型，使用 make 函数或初始化表达语句来创建。

```go
package main

import "fmt"

func main() {
	m := make(map[string]int)
	m["a"] = 1
	m["b"] = 2

	m2 := map[int]struct{		// 值为匿名结构体
		x int
	}{
		1 : {x : 100},			// 可省略 key, value 类型标签
		2: {x: 200},
	}

	fmt.Println(m,m2)
}
/*
map[a:1 b:2] map[1:{100} 2:{200}]
 */
```

基本操作演示：

```go
package main

func main() {
	m := map[string]int {
		"a": 1,
		"b": 2,
	}

	m["a"] = 10						// 修改
	m["c"] = 30						// 新增

	if v,ok := m["d"]; ok {			// 查询，使用 ok-idiom 判断 key 是否存在，返回值
		println(v)
	}

	delete(m, "d")				// 删除键值对，不存在时，不会报错
}
```

访问不存在的键值，默认返回零值，不会引发错误。但推荐使用 `ok-idiom` 模式，毕竟通过零值无法判断键值是否存在，获取存储的 value 本身就是零。

对字典进行迭代，每次返回的键值次序都不相同。

```go
package main

func main() {
	m := make(map[string]int)

	for i:=0;i<8;i++ {
		m[string('a'+i)] = i
	}

	for i:=0; i<4;i++ {
		for k,v := range m {
			print(k, ":", v, " ")
		}
		println()			// 分隔符
	}
}
/*
f:5 g:6 h:7 a:0 b:1 c:2 d:3 e:4 
b:1 c:2 d:3 e:4 f:5 g:6 h:7 a:0 
e:4 f:5 g:6 h:7 a:0 b:1 c:2 d:3 
g:6 h:7 a:0 b:1 c:2 d:3 e:4 f:5 
 */
```

函数 `len` 返回当前键值对数量，`cap` 不接受字典类型。另外，因内存访问安全和哈希算法等缘故，字典被设计成 `no addressable` , 故不能直接修改 value 成员（结构体或数组）。

```go
package main

func main() {
	type user struct {
		name string
		age int
	}

	m := map[int]user {
		1: {"Tom", 19},
	}

	m[1].age += 1					// 错误 cannot assign to struct field m[1].age in map
}
```

正确的做法是返回整个 value，待修改后再设置字典键值，或直接用指针类型。

```go
package main

type user struct {
	name string
	age byte
}

func main() {
	m := map[int]user {
		1: {"Tom",19},
	}
	u := m[1]
	u.age += 1
	m[1] = u					// 设置整个 value

	m2 := map[int]*user {		// value 是指针类型
		1:&user{"Tom", 19},
	}
	m2[1].age += 1				// m2[1] 返回的是指针，可透过指针修改目标对象
}
```

同理，m[key]++ 相当于 m[key] = m[key] + 1, 是合法操作。

不能对 nil 字典进行写操作，但却能读。

```go
package main

func main() {
	var m map[string]int
	println(m)					// 返回零值
	m["a"] = 1					// panic: assignment to entry in nil map
}
```

注意，内容为空的字典和 nil 是不同的。

```go
package main

func main() {
	var m1 map[string]int			// 字典为 nil
	//m3 := map[string]int			// 语法错误
	m2 := map[string]int{}			// 已初始化，等同于 make 操作。
	println(m1==nil,m2==nil)
}
/*
true false
 */
```

**安全**

在迭代期间删除或新增键值是安全的。

```go
package main

import "fmt"

func main() {
	m := make(map[int]int)

	for i:=0;i<10;i++ {				// 新增
		m[i] = i + 10
	}

	for k := range m {				// 修改
		if k == 5 {
			m[100] = 1000
		}

		delete(m,k)					// 删除
		fmt.Println(k,m)
	}
}

/*
1 map[0:10 2:12 3:13 4:14 5:15 6:16 7:17 8:18 9:19]
2 map[0:10 3:13 4:14 5:15 6:16 7:17 8:18 9:19]
5 map[0:10 3:13 4:14 6:16 7:17 8:18 9:19 100:1000]
7 map[0:10 3:13 4:14 6:16 8:18 9:19 100:1000]
0 map[3:13 4:14 6:16 8:18 9:19 100:1000]
3 map[4:14 6:16 8:18 9:19 100:1000]
4 map[6:16 8:18 9:19 100:1000]
6 map[8:18 9:19 100:1000]
8 map[9:19 100:1000]
9 map[100:1000]
100 map[]
 */

// 因为 map 字典不排序，所以每次结果存在不一样
```

就此例而言，不能保证迭代操作会删除新增的键值。

运行时会对字典并发操作做出检测。如果某个任务正在对字典进行写操作，那么其他任务就不能对该字典执行并发操作（读，写，删除），否则会导致进程奔溃。

```go
package main

import "time"

func main() {
	m := make(map[string]int)

	go func() {
		for {
			m["a"] += 1							// 写操作
			println(m["a"])
			time.Sleep(time.Microsecond)
		}
	}()

	go func() {
		for {
			_ = m["b"]							// 读操作
			time.Sleep(time.Microsecond)
		}
	}()

	select {}									// 阻止进程退出
}

/*
fatal error: concurrent map read and map write
 */
```

可启用数据竞争（data race）检查此类问题，它会输出详细检测信息。

```go
D:\go-module\5>go run -race 1.go
1
==================
WARNING: DATA RACE
Read at 0x00c00001fd40 by goroutine 7:
  runtime.mapaccess1_faststr()
      D:/Go/src/runtime/map_faststr.go:12 +0x0
  main.main.func2()
      D:/go-module/5/1.go:18 +0x64

Previous write at 0x00c00001fd40 by goroutine 6:
  runtime.mapassign_faststr()
      D:/Go/src/runtime/map_faststr.go:202 +0x0
  main.main.func1()
      D:/go-module/5/1.go:10 +0xb3

Goroutine 7 (running) created at:
  main.main()
      D:/go-module/5/1.go:16 +0x7e

Goroutine 6 (running) created at:
  main.main()
      D:/go-module/5/1.go:8 +0x5c
==================
2
3
...

```

可用 `sync.RWMutex` 实现同步, 避免读写操作同时进行。

```go
package main

import (
	"sync"
	"time"
)

var lock sync.RWMutex							// 使用读写锁，以获得最佳性能

func main() {
	m := make(map[string]int)

	go func() {
		for {
			lock.Lock()							// 注意锁的粒度,写锁
			m["a"] += 1							// 写操作
			lock.Unlock()						// 不能使用 defer
			time.Sleep(time.Microsecond)
		}
	}()

	go func() {
		for {
			lock.RLock()						// 读锁
			_ = m["b"]							// 读操作
			lock.RUnlock()
			time.Sleep(time.Microsecond)
		}
	}()

	select {}									// 阻止进程退出
}

```



**性能**

字典对象本身就是指针包装，传参时无须再次取地址。

```go
package main

import (
	"fmt"
	"unsafe"
)

func test(x map[string]int) {
	fmt.Printf("x: %p\n",x)
}

func main() {
	m := make(map[string]int)
	test(m)
	fmt.Printf("m: %p, %d\n", m, unsafe.Sizeof(m))

	m2 := make(map[string]int)
	test(m2)
	fmt.Printf("m2: %p, %d\n", m2, unsafe.Sizeof(m2))
}
/*
x: 0xc0000c2390
m: 0xc0000c2390, 8
x: 0xc0000c23c0
m2: 0xc0000c23c0, 8
 */
```

在创建时预先准备足够空间有助于提升性能，减少扩张时的内存分配和重新哈希操作。

1_test.go

```go
package main

import "testing"

func test() map[int]int {
	m := make(map[int]int)
	for i:=0;i<1000;i++ {
		m[i] = i
	}

	return m
}

func test2() map[int]int {
	m := make(map[int]int,1000)			// 预先准备足够的空间
	for i:=0;i<1000;i++ {
		m[i] = i
	}

	return m
}

func BenchmarkTest(b *testing.B) {
	for i:=0;i<b.N;i++ {
		test()
	}
}

func BenchmarkTest2(b *testing.B) {
	for i:=0;i<b.N;i++ {
		test2()
	}
}

/*
D:\go-module\5>go test -bench=. -run=none
goos: windows
goarch: amd64
pkg: 4/5
cpu: Intel(R) Core(TM) i7-10510U CPU @ 1.80GHz
BenchmarkTest-8             8966            116523 ns/op
BenchmarkTest2-8           25608             41829 ns/op
PASS
ok      4/5     4.089s
*/

//  从上面输出可以看出 test2 性能测试 41829 ns/op 更小，性能更好
```

对于海量小对象，应直接用字典存储键值数据拷贝，而非指针。这有助于减少需要扫描的对象数量，大幅缩短垃圾回收时间。另外，字典不会收缩内存，所以适当替换成新对象是必要的。



#### 结构

结构体（`struct`）将多个不同类型命名字段（`field`）序列打包成一个复合类型。

字段名必须唯一，可用 "_" 补位，支持使用自身指针类型成员。字段名、排列顺序属类型组成部分。除对齐处理外，编译器不会优化、调整内存布局。

```go
package main

import "fmt"

type node struct {
	_ int
	id int
	next *node
}

func main() {
	n1 := node{
		id: 1,
	}
	n2 := node{
		id: 2,
		next: &n1,
	}

	fmt.Println(n1,n2)
}

/*
{0 1 <nil>} {0 2 0xc000004078}
 */
```

可按顺序初始化全部字段，或使用命名方式初始化指定字段。

```go
package main

import "fmt"

func main() {
	type user struct {
		name string
		age int
	}

	u1 := user{"Tom",12}
	u2 := user{"tom"}			// 5\1.go:12:13: too few values in user{...}

	fmt.Println(u1,u2)
}
```

推荐使用命名初始化。这样在扩充结构字段或调整字段顺序时，不会导致初始化语句出错。

可直接定义匿名结构类型变量，或用作字段类型。但因其缺少类型标识，在作为字段类型时无法直接初始化，稍显麻烦。

```go
package main

import "fmt"

func main() {
	u := struct {				// 直接定义匿名结构体变量
		name string
		age byte
	}{
		name: "Tom",
		age:12,
	}

	type file struct {
		name string
		attr struct{			// 定义匿名结构体字段
			owner int
			perm int
		}
	}

	f := file{
		name: "test.dat",

		//attr: {				// missing type in composite literal
		//	owner:1,
		//	perm:0755,
		//},
	}
	f.attr.owner = 1			// 正确方式
	f.attr.perm = 0755
	fmt.Println(u,f)

}
/*
{Tom 12} {test.dat {1 493}}
 */
```

也可在初始化语句中再次定义，但那样看上去会非常丑陋。

只有在所有字段类型全部支持时，才可做相等操作。

```go
package main

func main() {
	type data struct {
		x int
		y map[int]int
	}

	d1 := data{
		x : 100,
	}
	d2 := data{
		x: 200,
	}

	println(d1==d2)	   // invalid operation: d1 == d2 (struct containing map[int]int cannot be compared)
}
```

可使用指针直接操作结构体字段，但不能是多级指针。

```go
package main

func main() {
	type user struct {
		name string
		age int
	}

	p := &user{
		name: "Tom",
		age: 1,
	}
	p.name = "Marry"
	p.age = 2

	p2 := &p
	p2.age = 3		// p2.age undefined (type **user has no field or method age)

}
```

**空结构**

空结构（`struct{}`）是指没有字段的结构类型。它比较特殊，因为无论是其自身，还是作为数组元素类型，其长度都为零。

```go
package main

import "unsafe"

func main() {
	var a struct{}
	var b [100]struct{}

	println(unsafe.Sizeof(a), unsafe.Sizeof(b))
}

/*
0 0
 */
```

尽管没有分配内存，但依然可以操作元素，对应切片 `len`，`cap` 属性也正常。

```go
package main

import "fmt"

func main() {
	var d [100]struct{}
	s := d[:]

	d[1] = struct{}{}
	d[2] = struct{}{}
	fmt.Println(s[3], len(s), cap(s))
}
/*
{} 100 100
 */
```

实际上，这类长度为 零 的对象通常都是指向 `runtime.zerebase` 变量。

```go
package main

import "fmt"

func main() {
	a := [10]struct{}{}
	b := a[:]				// 底层数组指向 zerebase ,而非 slice
	c := [0]int{}
	fmt.Printf("%p, %p, %p\n", &a[0],&b[0],&c)
}
/*
0x60cde0, 0x60cde0, 0x60cde0
 */
```

空结构可作为通道元素类型，用于事件通知。

```go
package main

func main() {
	exit := make(chan struct{})

	go func() {
		println("hello,world!")
		exit <- struct{}{}
	}()

	<- exit
	println("end" )
}

/*
hello,world!
end
 */
```

**匿名字段**

所谓匿名字段（ anonymous field ）, 是指没有名字，仅有类型的字段，也被称为嵌入字段或嵌入类型。

```go
package main

func main() {
	type attr struct {
		perm int
	}

	type file struct {
		name string
		attr					// 仅有类型名
	}
}
```

从编译器的角度看，这只是隐式的以类型名作为字段名字。可直接引用匿名字段的成员，但初始化时须当作独立字段。

```go
package main

func main() {
	type attr struct {
		perm int
	}

	type file struct {
		name string
		attr					// 仅有类型名
	}

	f := file{
		name: "test.dat",
		attr: attr{				// 显式初始化匿名字段
			perm:0755,
		},
	}

	f.perm = 0644				// 直接设置匿名字段
	println(f.perm)				// 直接读取匿名字段
}
```

如嵌入其他包中的类型，则隐式字段名字不包括包名。

```go
package main

import (
	"fmt"
	"os"
)

type data struct {
	os.File
}

func main() {
	d := data{
		File: os.File{},
	}
	fmt.Printf("%#v\n",d)
}
/*
main.data{File:os.File{file:(*os.file)(nil)}}
 */
```

不仅仅是结构体，除 接口指针和多级指针以外的任何命名类型都可以作为匿名字段。

```go
package main

import "fmt"

type data struct {
	*int				// 嵌入指针类型
	string
}

func main() {
	x := 100
	d := data{
		int: &x,		// 使用基础类型作为字段名
		string: "abc",
	}

	fmt.Printf("%#v\n",d)
}

/*
main.data{int:(*int)(0xc00000a0b8), string:"abc"}
 */
```

因未命名类型没有名字标识，自然无法作为匿名字段

```go
package main

func main() {
	type a *int
	type b *int
	type c interface {}

	type d struct {
		*a				// embedded type cannot be a pointer
		*b				// embedded type cannot be a pointer
		*c				// embedded type cannot be a pointer to interface
	}
	type f struct {
		a				// embedded type cannot be a pointer
		b				// embedded type cannot be a pointer
		c
	}
}
```

不能将基础类型和其指针类型同时嵌入，因为两者隐式名字相同。

```go
package main

func main() {
	type a struct {
		*int
		int				// duplicate field int
	}
}
```

虽然可以像普通字段那样访问匿名字段成员，但会存在重名问题。默认情况下，编译器从当前显式命名字段开始，逐步向内查找匿名字段成员。如匿名字段成员被外层同名字段遮蔽，那么必须使用显式字段名。

```go
package main

import "fmt"

type file struct {
	name string
}

type data struct {
	file
	name string							// 与匿名字段 file.name 重名
}

func main() {
	d := data{
		file{"file"},
		"data",
	}

	d.name = "data2"					// 访问 data.name
	d.file.name = "file2"				// 使用显式字段名访问 data.file.name

	fmt.Println(d.name, d.file.name)
}
/*
data2 file2
 */
```

如果多个相同层级的匿名字段成员重名，就只能使用显式字段名访问，因为编译器无法确定目标。

```go
package main

type file struct {
	name string
}

type log struct {
	name string
}

type data struct {
	file						// file 和 log 层次相同
	log							// file.name 和 log.name 重名
}

func main() {
	d := data{}
	d.name = "name"				// 错误: ambiguous selector d.name
	d.file.name = "file"		// 显式字段名
	d.log.name = "log"
}
```

严格来说，Go 并不是传统意义上的面向对象的编程语言，或者说仅实现了最小面向对象机制。匿名嵌入不是继承，无法实现多态处理。虽然配合方法集，可用接口来实现一些类似操作，但其本质式完全不同的。



**字段标签**

字段标签（ tag ）并不是注释，而是用来对字段进行描述的元数据。尽管它不属于数据成员，但确实类型的组成部分。

在运行期，可用反射获取标签信息。它常被用作格式校验，数据库关系映射等。

```go
package main

import (
	"fmt"
	"reflect"
)

type user struct {
	name string `昵称`
	sex byte `性别`
}

func main() {
	u := user{"Tom",1}
	v := reflect.ValueOf(u)
	t := v.Type()

	for i,n:=0,t.NumField();i < n;i++{
		fmt.Printf("%s :%v\n", t.Field(i).Tag, v.Field(i))
	}
}
/*
昵称 :Tom
性别 :1
 */
```

**内存布局**

不管结构体包含多少字段，其内存总是一次性分配的，各字段在相邻的地址空间按定义顺序排列。当然，对于引用类型、字符串和指针，结构内存中只包含其基本（ 头部 ）数据。还有，所有匿名字段成员也被包含在内。

借助 unsafe 包中的相关函数，可输出所有字段的偏移量和长度。

```go
package main

import (
	"fmt"
	"unsafe"
)

type point struct {
	x,y int
}

type value struct {
	id int							// 基本类型
	name string						// 字符串
	data []byte						// 引用类型
	next *value						// 指针类型
	point							// 匿名字段
}

func main() {
	v := value{
		id: 1,
		name: "test",
		data: []byte{1,2,3,4},
		point: point{x: 100, y:200},
	}

	s := `
		v: %p ~ %x, size: %d, align: %d
 		
		field	address			offset		size
		------+----------------+---------+--------
		id		%p					%d		%d
		name	%p					%d		%d
		data	%p					%d		%d
		next	%p					%d		%d
		x		%p					%d		%d
		y		%p					%d		%d
`
	fmt.Printf(s,
		&v,uintptr(unsafe.Pointer(&v)) + unsafe.Sizeof(v), unsafe.Sizeof(v), unsafe.Alignof(v),
		&v.id,unsafe.Offsetof(v.id), unsafe.Sizeof(v.id),
		&v.name,unsafe.Offsetof(v.name), unsafe.Sizeof(v.name),
		&v.data,unsafe.Offsetof(v.data), unsafe.Sizeof(v.data),
		&v.next,unsafe.Offsetof(v.next), unsafe.Sizeof(v.next),
		&v.x,unsafe.Offsetof(v.x), unsafe.Sizeof(v.x),
		&v.y,unsafe.Offsetof(v.y), unsafe.Sizeof(v.y))
}

/*
		v: 0xc000052050 ~ c000052098, size: 72, align: 8

		field	address			offset		size
		------+----------------+---------+--------
		id		0xc000052050					0		8
		name	0xc000052058					8		16
		data	0xc000052068					24		24
		next	0xc000052080					48		8
		x		0xc000052088					56		8
		y		0xc000052090					64		8

 */
```

```shell
	 |--------- name-------|-------------- data ------------|	   |-------- point ----|
+----+----------+----------+----------+----------+----------+------+---------+---------+
| id | name.ptr | name.len | data.ptr | data.len | data.cap | next | point.x | point.y |
+----+----------+----------+----------+----------+----------+------+---------+---------+
0	 8			16		   24		  32		 40			48	   56		64		   72	    

```

在分配内存时，字段必须做对齐处理，通常以所有字段中最长的基础类型宽度为标准。

```
package main

import (
	"fmt"
	"unsafe"
)

func main() {
	v1 := struct {
		a byte
		b byte
		c int32			// 对齐宽度 4
	}{}

	v2 := struct {
		a byte
		b byte			// 对齐宽度 1
	}{}

	v3 := struct {
		a byte
		b []int			// 基础类型 int ，对齐宽度 8
		c byte
	}{}

	fmt.Printf("v1: %d, %d\n", unsafe.Alignof(v1), unsafe.Sizeof(v1))
	fmt.Printf("v2: %d, %d\n", unsafe.Alignof(v2), unsafe.Sizeof(v2))
	fmt.Printf("v3: %d, %d\n", unsafe.Alignof(v3), unsafe.Sizeof(v3))
	fmt.Println(unsafe.Offsetof(v1.a), unsafe.Offsetof(v1.b), unsafe.Offsetof(v1.c))
	fmt.Println(unsafe.Offsetof(v2.a), unsafe.Offsetof(v2.b))
	fmt.Println(unsafe.Offsetof(v3.a), unsafe.Offsetof(v3.b), unsafe.Offsetof(v3.c))
}
/*
v1: 4, 8
v2: 1, 2
v3: 8, 40
0 1 4
0 1
0 8 32
 */
```

比较特殊的是空结构类型字段。如果他是最后一个字段，那么编译器将其当作长度为 1 的类型做对齐处理，以便其地址不会越界，避免引发垃圾回收错误。

```go
package main

import (
	"fmt"
	"unsafe"
)

func main() {
	v := struct {
		a struct{}
		b int
		c struct{}
	}{}

	s := `
	v: %p ~ %x, size: %d, align: %d

	field		address				offset		size
	----------+-------------------+---------+---------
	a			%p					%d			%d
	b			%p					%d			%d
	c			%p					%d			%d
`
	fmt.Printf(s,
		&v, uintptr(unsafe.Sizeof(&v)) + unsafe.Sizeof(v), unsafe.Sizeof(v), unsafe.Alignof(v),
		&v.a, unsafe.Offsetof(v.a), unsafe.Sizeof(v.a),
		&v.b,unsafe.Offsetof(v.b), unsafe.Sizeof(v.b),
		&v.c, unsafe.Offsetof(v.c), unsafe.Sizeof(v.c))
}

/*
	v: 0xc0000ac070 ~ 18, size: 16, align: 8

	field		address				offset		size
	----------+-------------------+---------+---------
	a			0xc0000ac070					0			0
	b			0xc0000ac070					0			8
	c			0xc0000ac078					8			0

 */
```

如果仅有一个空结构字段，那么同样按照 1 对齐，只不过长度为 0 ，且指向 `runtime.zerobase` 变量。

对齐的原因与硬件平台，以及访问效率有关。某些平台只能访问特定地址，比如只能是偶数地址。而另一方面，CPU 访问自然对齐的数据所需的读周期最少，还可避免拼接数据。




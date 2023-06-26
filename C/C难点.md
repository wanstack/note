[toc]



# 操作符

++

--

## 后置++

```c
#include <stdio.h>

int main() {
    int a = 10;
    int b = a++;	// 后置++，先使用，后++ 等价于 int b = a; a = a + 1
    printf("%d\n", b);	// 10
    printf("%d\n", a);	// 11
}
```

## 前置++

```c
#include <stdio.h>

int main() {
    int a = 10;
    int b = ++a;	// 前置++，先++，后使用 等价于 a = a + 1; int b = a 
    printf("%d\n", b);	// 11
    printf("%d\n", a);	// 11
}
```

## 后置--

```c
#include <stdio.h>

int main() {
    int a = 10;
    int b = a--;	// 后置--，先使用，后-- 等价于 int b = a; a = a - 1
    printf("%d\n", b);	// 10
    printf("%d\n", a);	// 9
}
```

## 前置--

```c
#include <stdio.h>

int main() {
    int a = 10;
    int b = --a;	// 前置--，先--，后使用 等价于 a = a - 1; int b = a 
    printf("%d\n", b);	// 9
    printf("%d\n", a);	// 9
}
```



## 三目操作符

exp1 ? exp2 : exp3

```c
int main() {
    int a = 10;
    int b = 20;
    int r = (a > b ? a : b) // if (a>b); r = a; else r = b
    return 0;
}
```



## 逗号操作符

逗号表达式的特点是：从左向右依次计算，整个表达式的结果是最后一个表达式的结果。
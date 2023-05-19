

## 1. 安装

```bash
//下载安装包
wget https://cpan.metacpan.org/authors/id/S/SH/SHLOMIF/Graph-Easy-0.76.tar.gz

//解决依赖与编译安装
yum install perl perl-ExtUtils-MakeMaker graphviz
perl Makefile.PL
make test
make install
```



## 2. 使用

### 2.1. hello world

```bash
[root@controller Graph-Easy-0.76]# echo '[hello]->[world]' | graph-easy 
+-------+     +-------+
| hello | --> | world |
+-------+     +-------+

# graph-easy 的语法相对来说比较宽松，[hello]->[world]，[hello]-->[world],[ hello ]-->[ world ]都是可以的。这里可以根据个人的风格。我比较喜欢紧凑的风格。所以后面都是使用紧凑的方式来做。


```

### 2.2. 线上加个上标

```bash
# 有时候要在连接线上加一个标志说明，比如我想要表明从上海坐车到北京，则可以使用下面的方式：

[root@controller Graph-Easy-0.76]# echo "[shanghai]-- car -->[beijing]" | graph-easy
+----------+  car   +---------+
| shanghai | -----> | beijing |
+----------+        +---------+

# 注意 -- car --  ; car与 -- 之间必须有空格
```

### 2.3. 画个环

```bash
[root@controller Graph-Easy-0.76]# echo "[a]->[b]->[a]" | graph-easy

  +---------+
  v         |
+---+     +---+
| a | --> | b |
+---+     +---+

[root@controller Graph-Easy-0.76]# echo "[a]->[a]" | graph-easy

  +--+
  v  |
+------+
|  a   |
+------+

```

### 2.4. 多个目标或者多个源

```bash
[root@controller Graph-Easy-0.76]# echo "[a],[b]->[c]" | graph-easy 
+---+     +---+     +---+
| a | --> | c | <-- | b |
+---+     +---+     +---+

[root@controller Graph-Easy-0.76]# echo "[a]->[b],[c]" | graph-easy 
+---+     +---+
| a | --> | b |
+---+     +---+
  |
  |
  v
+---+
| c |
+---+

```



### 2.5. 多个流程在一个图内

```bash
[root@controller Graph-Easy-0.76]# echo "[a]->[b] [c]->[d]" | graph-easy 

+---+     +---+
| a | --> | b |
+---+     +---+
+---+     +---+
| c | --> | d |
+---+     +---+


```

### 2.6 改变图方向

```bash
# 默认图方向是从左到右的。有时候想要从上向下的流程图。可以用标签来调整

[root@controller Graph-Easy-0.76]# echo "graph{flow:south} [a]->[b]" | graph-easy
+---+
| a |
+---+
  |
  |
  v
+---+
| b |
+---+

```

更多示例：https://github.com/ironcamel/Graph-Easy/tree/master/t/txt



## 3. 语法

graph-easy 语法都是基于 Graph::Easy::Parser

### 4.1 节点

- 单节点：即单个节点，用[xx]表示，比如[a]那出来的就一个节点

- 复合节点：由多个节点组成的一个复合节点。

  ```bash
  用[xx | xx | xx]表示，节点之间使用|分隔，比如[a | b | c | d]
  ```

### 4.2 连接线

- 单向箭头：使用->表示，比如[a] -> [b]
- 无方向连接线：使用–表示，比如[a] – [b]
- 双横线单向箭头：使用==>表示，比如[a] ==> [b]
- 点横线单向箭头：使用…>表示，比如[a] …> [b]
- 波浪线单向箭头：使用~~>表示，比如[a] ~~> [b]
- 横线、点单向箭头：使用.->表示，比如[a] .-> [b]
- 双向箭头：使用<->表示，比如[a] <-> [b]
- 双横线双向箭头：使用<=>表示，比如[a] <=> [b]


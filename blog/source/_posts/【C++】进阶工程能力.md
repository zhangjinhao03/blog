---
title: 【C++】进阶工程能力
date: 2026-09-07 19:01:57
tags: [CPP]
categories: CPP
series: C++知识整理
top_img: /img/img4.jpg
cover: /img/img4.jpg
---

# 进阶工程能力



- 文件操作
- 字符串处理
- 多文件编译



## 宏





## 链接与编译流程

C++ 文件编译到运行的整体流程：

```tex
源代码
  ↓
预处理   主要处理替换宏定义、头文件内容展开(处理以#开头的指令）
  ↓
编译    将预处理后的C++代码转换为汇编代码并检查报错
  ↓
汇编    将汇编代码转换为机器指令，生成目标文件 main.cpp -> main.o
  ↓
链接    将多个目标文件和库合并   main.o + 其他目标文件 + 标准库 -> 可执行文件
  ↓     g++ main.cpp -o main
可执行文件   生产main
  ↓
加载到内存  ./main
  ↓
运行

操作系统会：
  1. 创建进程
  2. 将程序加载到内存
  3. 准备栈和堆
  4. 加载需要的库
  5. 调用 main()
```

**注意：**

```
编译错误：C++ 代码本身有问题
链接错误：函数声明存在，但找不到函数实现
运行错误：程序已经生成，但运行时出错
```

## 静态库 / 动态库

假设有以下文件：

add.h

```cpp
  // add.h
  int add(int a, int b);

```

add.cpp

```cpp
  // add.cpp
  #include "add.h"

  int add(int a, int b) {
      return a + b;
  }
```

main.cpp

```cpp
  // main.cpp
  #include <iostream>
  #include "add.h"

  int main() {
      std::cout << add(1, 2) << '\n';
  }

```

### 静态库

静态库的文件通常是：

```tex
Linux: libadd.a
Windows: add.lib
```

**生成静态库**

先将 add.cpp 编译成目标文件：

```bash
g++ -c add.cpp -o add.o
```

再生成静态库：

```bash
ar rcs libadd.a add.o
```

最后链接主程序：

```bash
g++ main.cpp -L. -ladd -o app
```

其中：

-L.    在当前目录寻找库
-ladd  寻找 libadd.a

**静态库的特点**

链接时复制代码，程序相对独立；

链接时，库中的代码会被复制到可执行文件中：

main.cpp + libadd.a ->app

程序运行时通常不再需要：libadd.a

**优点：**

部署简单
运行时不依赖外部库文件

**缺点：**

可执行文件体积较大
库更新后通常需要重新链接程序
多个程序可能各自保存一份库代码

### 动态库

动态库的文件通常是：

```tex
Linux：libadd.so
Windows：add.dll
macOS：libadd.dylib
```

**生成动态库**

 先生成位置无关代码：

```bash
g++ -fPIC -c add.cpp -o add.o
```

 再生成动态库：

```bash
g++ -shared add.o -o libadd.so
```

链接主程序：

```bash
g++ main.cpp -L. -ladd -o app
```

运行时指定当前目录：

```bash
LD_LIBRARY_PATH=. ./app
```

**动态库的特点**

动态库代码不会完整复制到可执行文件中；

运行时加载代码，程序依赖外部库文件。

程序运行时，操作系统会：

1. 启动 app
  2. 查找 libadd.so
  3. 将 libadd.so 加载到内存
  4. 连接 app 中对 add() 的调用
  5. 执行程序

**优点：**

可执行文件体积较小
多个程序可以共享同一个动态库
更新库后通常不需要重新编译主程序

**缺点：**

运行时必须找到动态库
库版本不兼容可能导致程序无法运行
部署和路径配置更复杂



---

- 预处理器
- 编译选项
- 调试技巧

---
title: 【C++】值类别
date: 2026-08-06 18:43:05
tags: CPP
categories: CPP
series: C++知识整理
top_img: /img/img1.png
cover: /img/img1.png
---

# 【C++】值类别

> 当前已学：左值、右值、左值引用、const 左值引用、右值引用。

---

# 1. 左值和右值

## 1.1 一句话理解

```text
左值：有身份、能长期存在、可以反复访问的表达式。
右值：临时产生、用完即走的表达式。
```

粗略判断：

```text
有名字、通常能取地址 -> 左值
临时结果、字面量、表达式结果 -> 右值
```

---

## 1.2 左值例子

```cpp
int a = 10;
```

这里 `a` 是左值。

原因：

```text
a 有名字
a 有稳定地址
a 可以被再次访问
```

例如：

```cpp
&a
```

可以取地址。

---

## 1.3 右值例子

```cpp
10
```

`10` 是右值。

原因：

```text
它是一个临时值
没有名字
不能长期访问
```

例如：

```cpp
int a = 10;
```

这里：

```text
a  是左值
10 是右值
```

---

## 1.4 表达式结果也可能是右值

```cpp
int a = 1;
int b = 2;

int c = a + b;
```

这里：

```cpp
a + b
```

是右值。

因为它只是临时计算结果。

---

## 1.5 左值不等于能放在等号左边

```cpp
const int x = 10;
```

`x` 是左值，因为它有名字、有地址、可以反复访问。

但是：

```cpp
x = 20; // 错误
```

原因不是 `x` 不是左值，而是：

```text
x 是 const 左值，不能被修改
```

所以要记住：

```text
左值表示有身份，不代表一定能被赋值。
```

---

## 1.6 函数返回值也分情况

### 返回普通值：右值

```cpp
int f() {
    return 10;
}

int x = f();
```

这里：

```cpp
f()
```

是右值，因为返回的是临时结果。

---

### 返回引用：左值

```cpp
int global = 10;

int& g() {
    return global;
}

g() = 20;
```

这里：

```cpp
g()
```

是左值，因为它返回的是已有对象的引用。

---

# 2. 左值引用 / const 左值引用 / 右值引用

## 2.1 左值引用 `T&`

左值引用只能绑定普通左值。

```cpp
int a = 10;
int& r = a;
```

修改 `r` 就是修改 `a`：

```cpp
r = 20;
std::cout << a << std::endl; // 20
```

不能这样：

```cpp
int& r = 10; // 错误
```

原因：

```text
10 是右值，普通左值引用不能绑定右值。
```

---

## 2.2 const 左值引用 `const T&`

`const T&` 既可以绑定左值，也可以绑定右值。

```cpp
int a = 10;
const int& r1 = a;   // 可以
const int& r2 = 20;  // 也可以
```

原因：

```text
const T& 承诺只读访问，不修改对象。
```

所以 C++ 允许它绑定临时右值，并延长临时对象生命周期。

例如：

```cpp
const std::string& s = std::string("hello");
```

临时 `std::string("hello")` 的生命周期会被延长到 `s` 的作用域结束。

---

## 2.3 右值引用 `T&&`

右值引用主要用于绑定右值。

```cpp
int&& r = 10;
```

右值引用支持：

```text
移动语义
完美转发
```

当前阶段重点理解移动语义。

---

## 2.4 右值引用变量本身是左值

```cpp
int&& r = 10;
```

虽然 `r` 的类型是：

```cpp
int&&
```

但是表达式：

```cpp
r
```

本身是左值。

原因：

```text
r 有名字
r 可以反复访问
r 可以取地址
```

所以：

```cpp
int&& r2 = r; // 错误
```

如果想继续把它当右值使用，需要：

```cpp
int&& r2 = std::move(r);
```

---

# 3. 三种引用绑定规则

## 3.1 `T&`

```cpp
int a = 10;
int& r = a;   // 对
int& x = 10;  // 错
```

只能绑定普通左值。

---

## 3.2 `const T&`

```cpp
int a = 10;
const int& r1 = a;   // 对
const int& r2 = 10;  // 对
```

左值、右值都能绑定。

---

## 3.3 `T&&`

```cpp
int&& r1 = 10;           // 对
int a = 10;
int&& r2 = a;            // 错
int&& r3 = std::move(a); // 对
```

只能绑定右值。

---

# 4. 判断题整理

```cpp
int a = 10;              // 能编译
const int c = 20;        // 能编译

int& r1 = a;             // 能编译，a 是左值
int& r2 = 10;            // 不能编译，普通左值引用不能绑定右值

const int& r3 = a;       // 能编译，const 左值引用可以绑定左值
const int& r4 = 10;      // 能编译，const 左值引用可以绑定右值

int&& r5 = 10;           // 能编译，右值引用可以绑定右值
int&& r6 = a;            // 不能编译，a 是左值
int&& r7 = std::move(a); // 能编译，std::move(a) 是右值形式
```

---

# 5. `std::move`

## 5.1 `std::move` 是什么

最重要的一句话：

```text
std::move 本身不移动任何东西。
```

它只是做一件事：

```text
把一个左值转换成右值形式。
```

更准确地说：

```text
把 T& 转成 T&&。
```

---

## 5.2 单独调用 `std::move` 不会改变对象

```cpp
std::string s = "hello";
std::move(s);
std::cout << s << std::endl;
```

这里 `s` 通常仍然输出：

```text
hello
```

原因：

```text
std::move(s) 只是转换值类别。
没有发生移动构造或移动赋值，所以不会真正移动资源。
```

---

## 5.3 真正发生移动的位置

```cpp
std::string s = "hello";
std::string t = std::move(s);
```

这里真正发生移动的是：

```text
std::string 的移动构造函数
```

完整理解：

```text
std::move(s)：把 s 转成右值形式
std::string t = ...：调用移动构造，真正转移资源
```

---

## 5.4 为什么需要 `std::move`

有名字的变量本身是左值。

例如：

```cpp
auto p = std::make_unique<Foo>();
```

这里 `p` 是左值。

所以不能：

```cpp
auto q = p; // 错误，unique_ptr 不能拷贝
```

必须：

```cpp
auto q = std::move(p);
```

含义：

```text
明确告诉编译器：允许把 p 里的资源转走。
```

---

## 5.5 `std::move` 后对象还活着

```cpp
std::string s = "hello";
std::string t = std::move(s);
```

移动后：

```text
s 还活着
s 可以析构
s 可以重新赋值
但不应该继续依赖它原来的内容
```

例如：

```cpp
s = "world";
```

这是可以的。

对 `unique_ptr` 来说：

```cpp
auto p = std::make_unique<Foo>();
auto q = std::move(p);
```

移动后：

```text
q 拥有对象
p 变为空
```

所以：

```cpp
q->hello(); // 可以
p->hello(); // 错误，p 已经为空
```

---

# 6. 移动构造 / 移动赋值

## 6.1 拷贝构造

```cpp
Buffer(const Buffer& other)
```

用于：

```cpp
Buffer b = a;
```

含义：

```text
用已有对象 a 创建新对象 b。
```

如果类管理堆内存，拷贝构造通常要做深拷贝。

---

## 6.2 移动构造

```cpp
Buffer(Buffer&& other)
```

用于：

```cpp
Buffer b = std::move(a);
```

含义：

```text
用即将被移动的对象 a 创建新对象 b。
```

移动构造通常不复制资源，而是接管资源：

```cpp
Buffer(Buffer&& other) {
    data = other.data;
    other.data = nullptr;
}
```

为什么要把 `other.data` 置空：

```text
防止两个对象析构时重复释放同一块资源。
```

---

## 6.3 拷贝赋值

```cpp
Buffer& operator=(const Buffer& other)
```

用于：

```cpp
Buffer d;
d = b;
```

含义：

```text
d 已经存在，现在把 b 的内容复制给 d。
```

---

## 6.4 移动赋值

```cpp
Buffer& operator=(Buffer&& other)
```

用于：

```cpp
Buffer d;
d = std::move(c);
```

含义：

```text
d 已经存在，先释放 d 原来的资源，再接管 c 的资源。
```

典型写法：

```cpp
Buffer& operator=(Buffer&& other) {
    if (this != &other) {
        delete[] data;
        data = other.data;
        other.data = nullptr;
    }
    return *this;
}
```

---

## 6.5 判断题整理

```cpp
Buffer a;                 // 普通构造
Buffer b = a;             // 拷贝构造
Buffer c = std::move(a);  // 移动构造

Buffer d;                 // 普通构造
d = b;                    // 拷贝赋值
d = std::move(c);         // 移动赋值
```

---

# 7. 当前最重要结论

```text
T&：只能接普通左值
const T&：左值右值都能接，只读
T&&：只能接右值
右值引用变量本身是左值
std::move(a) 把左值 a 转成右值形式
std::move 本身不移动任何东西
真正移动发生在移动构造 / 移动赋值
拷贝构造：新对象复制旧对象
移动构造：新对象接管旧对象资源
拷贝赋值：已有对象复制另一个对象
移动赋值：已有对象释放旧资源，再接管另一个对象资源
```

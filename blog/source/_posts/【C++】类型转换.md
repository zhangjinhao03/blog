---
title: 【C++】类型转换
date: 2026-08-06 18:43:05
tags: CPP
categories: Markdown
top_img: /img/img2.jpg
cover: /img/img2.jpg
---

# 【C++】类型转换

C++ 主要有 4 种显式类型转换：

```cpp
static_cast
dynamic_cast
const_cast
reinterpret_cast
```

可以按危险程度理解：

```text
static_cast       正常转换，最常用
dynamic_cast      多态类安全向下转型
const_cast        去掉 const / volatile
reinterpret_cast  按二进制/地址硬解释，最危险
```

---

## 1. `static_cast`：正常、明确、编译期转换

最常用。适合“类型之间本来就有合理关系”的转换。

### 数值转换

```cpp
double d = 3.14;
int i = static_cast<int>(d);  // i = 3
```

### 父子类指针转换

```cpp
class Base {};
class Derived : public Base {};

Derived d;
Base* b = &d;

Derived* p = static_cast<Derived*>(b);
```

注意：`static_cast` 不做运行时检查。

如果 `b` 实际不是 `Derived`，那就危险。

### `void*` 转回原类型

```cpp
void* p = &d;
Derived* dp = static_cast<Derived*>(p);
```

一句话：

> `static_cast` 用于“我知道这是合理类型转换”。

---

## 2. `dynamic_cast`：安全的父子类运行时转换

主要用于有虚函数的类，也就是多态类。

```cpp
class Base {
public:
    virtual ~Base() = default;
};

class Derived : public Base {};

Base* b = new Derived;

Derived* d = dynamic_cast<Derived*>(b);
if (d != nullptr) {
    // 转换成功
}
```

如果转换失败：

```cpp
Derived* d = dynamic_cast<Derived*>(b);
```

会返回 `nullptr`。

引用转换失败会抛异常：

```cpp
Derived& d = dynamic_cast<Derived&>(*b);
```

失败时抛 `std::bad_cast`。

一句话：

> `dynamic_cast` 用于“我不确定这个父类指针实际是不是某个子类，让运行时帮我检查”。

---

## 3. `const_cast`：去掉 const / volatile

只能用于改 const/volatile 属性。

```cpp
const int x = 10;
int* p = const_cast<int*>(&x);
```

但注意：如果对象本身真的是 `const`，你改它是未定义行为：

```cpp
const int x = 10;
int* p = const_cast<int*>(&x);
*p = 20;  // 未定义行为
```

安全场景是：原对象不是 const，只是传递过程中变成了 const。

```cpp
void f(const std::string& s) {
    std::string& ref = const_cast<std::string&>(s);
}
```

如果调用方传进来的原本不是 const，修改才可能安全。

一句话：

> `const_cast` 只改 const 属性，不改真实类型。

---

## 4. `reinterpret_cast`：重新解释内存/地址

最危险。它不关心类型关系，基本是告诉编译器：

> 你别管，我就要把这块东西当成另一个类型看。

例如指针转整数：

```cpp
int x = 10;
uintptr_t addr = reinterpret_cast<uintptr_t>(&x);
```

整数转指针：

```cpp
int* p = reinterpret_cast<int*>(addr);
```

不同指针类型互转：

```cpp
int x = 10;
char* p = reinterpret_cast<char*>(&x);
```

函数指针、底层系统代码、序列化、内存映射里可能会用到。

一句话：

> `reinterpret_cast` 是底层硬转，除非你非常清楚内存布局，否则别用。

---

## 和 C 风格强转对比

C 风格：

```cpp
int i = (int)d;
```

C++ 风格：

```cpp
int i = static_cast<int>(d);
```

C 风格强转的问题是它可能偷偷做很多事：

```cpp
(T)x
```

可能等价于：

```cpp
static_cast
const_cast
reinterpret_cast
```

甚至组合使用。

所以 C++ 推荐写明确的转换方式。

---

## 最快判断用哪个

### 普通数值、父子类明确转换

```cpp
static_cast<T>(x)
```

### 父类指针转子类，不确定真实类型

```cpp
dynamic_cast<T*>(x)
```

### 去掉 const

```cpp
const_cast<T>(x)
```

### 指针地址、内存布局、底层硬转

```cpp
reinterpret_cast<T>(x)
```

---

## 记忆口诀

```text
static_cast       正常转
dynamic_cast      安全查
const_cast        去 const
reinterpret_cast  硬解释
```

再短一点：

```text
static：我知道能转
dynamic：运行时帮我确认
const：只改 const
reinterpret：当成另一种东西看
```
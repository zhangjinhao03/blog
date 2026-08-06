---
title: lambda表达式
date: 2026-08-06 18:43:05
tags: C++
categories: Docs
top_img: /img/img5.png
cover: /img/img5.png
---

# lambda

> 当前已学：lambda 基础语法、捕获、mutable。

---

# 1. lambda 是什么

`lambda` 就是匿名函数。

你可以把它理解成：

```text
一个可以直接写在代码里的小函数
```

常见用途：

- 排序比较规则
- 查找条件
- 遍历处理
- 回调函数

---

# 2. 基本语法

```cpp
[capture](params) -> return_type {
    body
};
```

分别是：

- `capture`：捕获外部变量
- `params`：参数列表
- `return_type`：返回值类型，可省略
- `body`：函数体

---

# 3. 最简单的 lambda

```cpp
auto add = [](int a, int b) {
    return a + b;
};
```

这里：

- `[]` 表示不捕获任何外部变量
- `(int a, int b)` 是参数
- `return a + b` 是返回值

如果编译器能推导返回类型，通常可以省略 `-> return_type`。

---

# 4. 为什么 lambda 有用

因为很多时候你只想写一个临时的小函数，比如：

- 排序规则
- 条件过滤
- 对容器中元素做处理
- 传给 STL 算法

lambda 比单独写一个函数更短、更贴近使用地点。

---

# 5. lambda 和普通函数的区别

普通函数：

```cpp
int add(int a, int b) {
    return a + b;
}
```

lambda：

```cpp
auto add = [](int a, int b) {
    return a + b;
};
```

区别：

- 普通函数有名字
- lambda 可以直接写在局部位置
- lambda 更适合一次性的小逻辑

---

# 6. 捕获列表

lambda 经常要用外部变量：

```cpp
int x = 10;
auto f = [x]() {
    std::cout << x << std::endl;
};
```

这时就要用捕获列表。

---

# 7. 值捕获 `[x]`

```cpp
int x = 10;
auto f = [x]() {
    std::cout << x << std::endl;
};
```

含义：

```text
把外部变量 x 复制一份放进 lambda 里
```

特点：

- lambda 内部用的是副本
- 外部 `x` 改了，不影响 lambda 里的值
- 更安全

例子：

```cpp
int x = 10;
auto f = [x]() {
    std::cout << x << std::endl;
};

x = 20;
f(); // 输出 10
```

---

# 8. 引用捕获 `[&x]`

```cpp
int x = 10;
auto f = [&x]() {
    std::cout << x << std::endl;
};
```

含义：

```text
lambda 里引用外部变量 x
```

特点：

- lambda 里看到的是外部真实变量
- 外部变量变了，lambda 里也变
- 可以修改外部变量

例子：

```cpp
int x = 10;
auto f = [&x]() {
    x++;
};

f();
std::cout << x << std::endl; // 11
```

---

# 9. 默认捕获 `[=]` 和 `[&]`

### `[=]`

表示：

```text
默认按值捕获外部用到的变量
```

例子：

```cpp
int x = 10;
int y = 20;

auto f = [=]() {
    std::cout << x + y << std::endl;
};
```

---

### `[&]`

表示：

```text
默认按引用捕获外部用到的变量
```

例子：

```cpp
int x = 10;
int y = 20;

auto f = [&]() {
    x++;
    y++;
};
```

---

# 10. 捕获的生命周期问题

这是很重要的坑。

```cpp
auto f = []() {
    int x = 10;
    return [&x]() {
        std::cout << x << std::endl;
    };
};
```

这里返回的 lambda 引用了局部变量 `x`，但 `x` 已经销毁了。

所以调用它会出问题。

核心记住：

```text
引用捕获不能引用已经销毁的变量
```

---

# 11. `mutable lambda`

值捕获默认是只读的。

```cpp
int x = 10;
auto f = [x]() {
    // x++;
};
```

加上 `mutable` 后，可以修改 lambda 内部自己的副本：

```cpp
int x = 10;
auto f = [x]() mutable {
    x++;
    std::cout << x << std::endl;
};
```

注意：

```text
修改的是 lambda 内部自己的副本，不是外部 x
```

例子：

```cpp
int x = 10;
auto f = [x]() mutable {
    x++;
    std::cout << x << std::endl;
};

f();
f();
std::cout << x << std::endl;
```

输出通常是：

```text
11
12
10
```

---

# 12. 已掌握的结论

```text
lambda = 匿名函数
[] 是捕获列表
() 是参数列表
{} 是函数体
[x] 是值捕获
[&x] 是引用捕获
[=] 是默认值捕获
[&] 是默认引用捕获
mutable 允许修改值捕获副本
```

---

# 13. 最快判断方式

```text
需要临时写一个小函数 -> 用 lambda
只想读外部变量 -> 值捕获
需要改外部变量 -> 引用捕获
要改值捕获副本 -> 加 mutable
```

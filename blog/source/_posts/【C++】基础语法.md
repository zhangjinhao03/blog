---
title: 【C++】基础语法
date: 2026-09-07 18:59:55
tags: [CPP]
categories: CPP
series: C++知识整理
top_img: /img/830179.jpg
cover: /img/830179.jpg
---

# C++基础语法

## 数据类型

- 数据类型：`int`、`char`、`float`、`double`、`bool`

### 枚举和枚举类

C++ 中有两种常见枚举：

普通枚举

```cpp
enum Color {
    RED,
    BLACK
};
```

和C++11引入的枚举类

```cpp
enum class Color {
    Red,
    Black
};
```

它们都用于表示一组有限的取值，但类型安全性和使用方式不同。

#### 作用域不同

**普通枚举```enum```**

枚举成员会直接进入外层作用域

```cpp
enum Color {
    RED,
    BLACK
};

Color color = RED;

// 可以直接使用：
if (color == RED) {
    ···
}
```

但容易造成命名冲突：

```cpp
enum Color {
    RED,
    BLACK
};

enum TrafficLight {
    RED, // 编译错误：RED 已经存在
    BLACK
};
```

**普通枚举```enum class```**

枚举成员属于枚举类自己的作用域：

```cpp
enum class Color {
    Red,
    Black
};

Color color = Color::Red;

// 必须通过枚举类型访问成员
if (color == Color::Red) {
    ···
}
```

不同枚举类型可以拥有同名成员：

```cpp
enum class Color {
    Red,
    Black
};

enum class TrafficLight {
    Red,
    Black
};

// 使用时通过作用域区分
Color color = Color::Red;
TrafficLight light = TrafficLight::Red;
```

#### 类型安全不同

普通枚举可以隐式转换为整数：

```cpp
enum Color {
    RED,
    BLACK
};

int value = RED; // 通常可以正常编译。
```

枚举类不能隐式转换为整数：

```cpp
enum class Color {
    Red,
    Black
};

// int value = Color::Red;  // 编译错误
```

需要显式转换：

```cpp
int value = static_cast<int>(Color::Red);
```

这可以避免枚举值被意外当作整数使用。

### 不同枚举之间的比较

普通枚举更容易发生隐式转换：

```cpp
enum Color {
    RED,
    BLACK
};

enum Status {
    READY,
    ERROR
};

if (RED == READY) {
    // 可能被转换为整数后进行比较
}
```

枚举类之间不能直接比较：

```cpp
enum class Color {
    Red,
    Black
};

enum class Status {
    Ready,
    Error
};

// if (Color::Red == Status::Ready) {
//     // 编译错误
//  }
```

这可以避免比较两个语言完全不同的值。



枚举类是现代 C++ 普通枚举需求，而枚举类型一般用于兼容旧代码和底层标志位。

---

- 变量、常量、作用域
- 运算符
- 条件、循环
- 函数
- 头文件与命名空间


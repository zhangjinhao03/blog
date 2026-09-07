---
title: 【C++】知识体系
date: 2026-09-04 00:00:00
tags: [CPP]
categories: Markdown
top_img: /img/830179.jpg
cover: /img/830179.jpg
---

#  C++知识体系

## 1. 基础语法
{% post_link 【C++】基础语法 【C++】基础语法%}

- 数据类型：`int`、`char`、`float`、`double`、`bool`
- 变量、常量、作用域
- 运算符
- 条件、循环
- 函数
- 头文件与命名空间

## 2. 指针与引用
{% post_link 【C++】指针与引用 【C++】指针与引用%}

- 指针
- 指针运算
- 空指针
- 引用
- 指针和引用的区别
- `const` 指针、`const` 引用

## 3. 内存管理
{% post_link 【C++】内存管理 【C++】内存管理%}

- 栈、堆、静态区
- `new` / `delete`
- `malloc` / `free`
- 内存泄漏
- 野指针、悬空指针
- 内存对齐

## 4. 面向对象
{% post_link 【C++】面向对象 【C++】面向对象%}

- 类与对象
- 构造函数 / 析构函数
- 拷贝构造 / 拷贝赋值
- 默认构造、移动构造、移动赋值
- 封装、继承、多态
- 访问权限：`public` / `protected` / `private`
- 虚函数、纯虚函数、抽象类、虚函数表
- 对象布局
- `override`、`final`

## 5. 值类别与引用体系
{% post_link 【C++】值类别 【C++】值类别%}

- `std::forward`
- 完美转发

## 6. 资源管理与智能指针
{% post_link 【C++】资源管理与智能指针 【C++】资源管理与智能指针%}

- RAII
- 自定义删除器

## 7. 标准模板库 STL

{% post_link 【C++】标准模版库STL 【C++】标准模版库STL%}

### 容器

- 顺序容器：`vector`、`deque`、`list`
- 关联容器：`set`、`map`、`multiset`、`multimap`
- 无序容器：`unordered_set`、`unordered_map`
- 容器适配器：`stack`、`queue`、`priority_queue`

### 算法
- `sort`
- `find`
- `binary_search`
- `lower_bound` / `upper_bound`
- `accumulate`
- `for_each`
- 其他常用算法

### 迭代器
- 输入 / 输出 / 前向 / 双向 / 随机访问迭代器

## 8. 函数高级特性
{% post_link 【C++】函数高级特性 【C++】函数高级特性%}

- 函数重载
- 默认参数
- 内联函数
- 函数指针
- lambda 表达式
- 仿函数
- `std::function`

## 9. 模板与泛型编程
{% post_link 【C++】模版与泛型编程 【C++】模版与泛型编程%}

- 函数模板
- 类模板
- 模板特化
- 偏特化
- 可变参数模板
- 模板元编程基础

## 10. 异常处理
{% post_link 【C++】异常处理 【C++】异常处理%}

- `try` / `catch` / `throw`
- 异常安全
- 异常规格
- 自定义异常

## 11. 类型转换
{% post_link 【C++】类型转换 【C++】类型转换%}

## 12. 多线程与并发
{% post_link 【C++】多线程与并发 【C++】多线程与并发%}

- `std::thread`
- `std::mutex`
- `std::lock_guard`
- `std::unique_lock`
- `std::condition_variable`
- 数据竞争、原子性、临界区
- 协程

## 13. C++11 及之后的新特性
{% post_link 【C++】C++11新特性 【C++】C++11新特性%}

- `auto`
- 范围 `for`
- lambda {% post_link 【C++】lambda表达式 【C++】lambda表达式%}
- `nullptr`
- `enum class`
- `constexpr`
- 统一初始化
- `override` / `final`
- `using`
- `std::array`
- `std::tuple`

## 14. 进阶工程能力
{% post_link 【C++】进阶工程能力 【C++】进阶工程能力%}

- 文件操作
- 字符串处理
- 多文件编译
- 链接与编译流程
- 静态库 / 动态库
- 预处理器
- 宏
- 编译选项
- 调试技巧

## 15. 常见设计与实践
{% post_link 【C++】常见设计与实践 【C++】常见设计与实践%}

- 单例模式
- 工厂模式
- 观察者模式
- 资源句柄封装
- 容器选型
- 接口设计

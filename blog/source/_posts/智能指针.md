---
title: 智能指针
date: 2026-08-06 18:43:05
tags: C++
categories: Docs
top_img: /img/img3.png
cover: /img/img3.png
---

# Smart Pointer-智能指针

> 当前已学：`unique_ptr`、`shared_ptr`、`weak_ptr`

---

# 1. 为什么需要智能指针

手动管理内存容易出错：

- 忘记 `delete`，导致内存泄漏
- 异常或提前 `return` 时没有释放资源
- 多个地方同时管理同一块内存，容易重复释放
- 原始指针失去控制，容易出现野指针

智能指针的核心思想是：

```text
对象活着时自动持有资源
对象销毁时自动释放资源
```

这就是 RAII。

---

# 2. `unique_ptr`

## 2.1 `unique_ptr` 是什么

`unique_ptr` 表示：

```text
一个对象只能有一个拥有者
```

它负责独占一个资源，离开作用域时自动释放。

示例：

```cpp
auto p = std::make_unique<Foo>();
```

不需要手写 `delete`。

---

## 2.2 `unique_ptr` 的核心规则

### 不能拷贝

```cpp
std::unique_ptr<int> a = std::make_unique<int>(10);
std::unique_ptr<int> b = a;   // 错误
```

原因：

```text
unique_ptr 要保证独占所有权
```

如果允许拷贝，就会有两个指针都以为自己负责释放同一块内存，导致重复 `delete`。

---

### 可以移动

```cpp
std::unique_ptr<int> a = std::make_unique<int>(10);
std::unique_ptr<int> b = std::move(a);
```

含义：

```text
所有权从 a 转移给 b
```

转移后：

- `b` 拥有对象
- `a` 变为空

---

### 离开作用域自动释放

```cpp
void f() {
    auto p = std::make_unique<int>(10);
}
```

函数结束时自动释放资源。

---

## 2.3 `std::move`

`std::move` 本身不移动对象，它只是把左值强制转换成右值，让编译器允许调用移动构造或移动赋值。

例如：

```cpp
auto p = std::make_unique<Foo>();
auto q = std::move(p);
```

这里发生的是所有权转移，不是拷贝。

---

## 2.4 `unique_ptr` 的三种常见传参方式

### 按值传递

适合：函数要接管所有权。

```cpp
void take(std::unique_ptr<Foo> p) {
    p->hello();
}
```

调用：

```cpp
auto p = std::make_unique<Foo>();
take(std::move(p));
```

特点：

- 函数拿到所有权
- 函数结束时自动释放
- 调用者的指针会变空

---

### 按引用传递

适合：函数要修改 `unique_ptr` 本身。

```cpp
void reset_ptr(std::unique_ptr<Foo>& p) {
    p = std::make_unique<Foo>();
}
```

特点：

- 不转移所有权
- 可以重新赋值、`reset`
- 会改变调用者手里的那个 `unique_ptr`

---

### 只读使用对象

适合：函数只是借用对象，不接管所有权。

```cpp
void use(Foo* p) {
    p->hello();
}
```

或：

```cpp
void use(const Foo& p) {
    p.hello();
}
```

调用：

```cpp
use(p.get());
```

特点：

- 不转移所有权
- 只是临时访问
- 适合借用

---

## 2.5 `unique_ptr` 的返回值

函数可以返回 `unique_ptr`：

```cpp
std::unique_ptr<Foo> make_foo() {
    return std::make_unique<Foo>();
}
```

调用：

```cpp
auto p = make_foo();
```

这没问题，因为返回时可以移动所有权，很多时候还会触发返回值优化。

也可以这样写：

```cpp
std::unique_ptr<Foo> f() {
    std::unique_ptr<Foo> p = std::make_unique<Foo>();
    return p;
}
```

这也是对的，会走移动语义或返回值优化。

---

## 2.6 `get()` / `release()` / `reset()`

### `get()`

```cpp
T* get() const noexcept;
```

作用：

```text
拿到内部裸指针，但不转移所有权
```

示例：

```cpp
auto p = std::make_unique<Foo>();
Foo* raw = p.get();
```

注意：

- `p` 仍然拥有对象
- `raw` 只是借用
- 不要对 `raw` 手动 `delete`

---

### `release()`

```cpp
T* release() noexcept;
```

作用：

```text
释放所有权，返回裸指针，unique_ptr 变空
```

示例：

```cpp
auto p = std::make_unique<Foo>();
Foo* raw = p.release();
```

这时：

- `p` 为空
- 你需要自己负责 `delete raw`

---

### `reset()`

```cpp
void reset(T* ptr = nullptr) noexcept;
```

作用：

```text
释放当前对象，然后改为管理新对象
```

示例：

```cpp
auto p = std::make_unique<Foo>();
p.reset(new Foo());
```

或者清空：

```cpp
p.reset();
```

---

## 2.7 `unique_ptr` 使用原则

```text
默认优先用 unique_ptr 管理资源
需要借用时用 get()
需要转交所有权时用 move 或 release()
需要替换对象时用 reset()
```

---

## 2.8 目前已掌握的结论

```text
unique_ptr = 独占所有权
不能拷贝，只能移动
离开作用域自动释放
返回值可以靠移动或返回值优化交给调用者
get() 只借用，不交权
release() 交出所有权
reset() 释放旧对象，换管新对象
```

---

# 3. `shared_ptr`

## 3.1 `shared_ptr` 是什么

`shared_ptr` 表示：

```text
多个指针可以共同拥有同一个对象
```

它和 `unique_ptr` 最大区别是：

- `unique_ptr`：独占
- `shared_ptr`：共享

---

## 3.2 为什么需要 `shared_ptr`

有些场景不是“一个主人”，而是“多个地方都要用同一个对象”。

比如：

- 一个对象被多个模块引用
- 一个对象要在多个函数之间传递
- 一个对象不能轻易判断谁最后释放

这时 `shared_ptr` 就有用。

---

## 3.3 它的核心机制：引用计数

`shared_ptr` 内部维护一个计数器。

规则是：

- 拷贝一次，计数 +1
- 销毁一个，计数 -1
- 计数变成 0 时，自动释放对象

---

## 3.4 最小例子

```cpp
#include <memory>
#include <iostream>

struct Foo {
    Foo() { std::cout << "Foo ctor\n"; }
    ~Foo() { std::cout << "Foo dtor\n"; }
    void hello() { std::cout << "hello\n"; }
};

int main() {
    std::shared_ptr<Foo> a = std::make_shared<Foo>();
    std::shared_ptr<Foo> b = a;

    a->hello();
    b->hello();

    std::cout << a.use_count() << std::endl;
}
```

这里：

- `a` 和 `b` 共享同一个 `Foo`
- `use_count()` 会显示当前引用计数

---

## 3.5 `shared_ptr` 的核心规则

### 可以拷贝

```cpp
auto a = std::make_shared<Foo>();
auto b = a;
```

这不会复制对象本身，只是多了一个共同持有者。

---

### 最后一个销毁时才释放

```cpp
{
    auto a = std::make_shared<Foo>();
    auto b = a;
}
```

离开作用域后，最后一个 `shared_ptr` 析构，`Foo` 才释放。

---

### `make_shared` 优先使用

```cpp
auto p = std::make_shared<Foo>();
```

比直接 `new` 更推荐，因为：

- 写法更简洁
- 通常更高效
- 更安全

---

## 3.6 `shared_ptr` 传参方式

### 按值传递

适合：函数需要共享这份所有权。

```cpp
void f(std::shared_ptr<Foo> p) {
    p->hello();
}
```

调用：

```cpp
auto p = std::make_shared<Foo>();
f(p);
```

效果：

- 拷贝一份 `shared_ptr`
- 引用计数 +1

---

### 按引用传递

适合：函数要修改这个 `shared_ptr` 本身。

```cpp
void reset_ptr(std::shared_ptr<Foo>& p) {
    p = std::make_shared<Foo>();
}
```

---

### 只读借用

如果函数只是看对象，不想增加引用计数，通常传：

```cpp
void use(const Foo& p) {
    p.hello();
}
```

或者：

```cpp
void use(Foo* p) {
    p->hello();
}
```

---

## 3.7 `use_count()`

```cpp
std::cout << p.use_count() << std::endl;
```

作用是看当前有多少个 `shared_ptr` 在共享这个对象。

例子：

```cpp
auto a = std::make_shared<Foo>();
std::cout << a.use_count() << std::endl; // 1

auto b = a;
std::cout << a.use_count() << std::endl; // 2
```

---

## 3.8 `shared_ptr` 的坑：循环引用

这是最重要的坑。

比如：

```cpp
struct B;

struct A {
    std::shared_ptr<B> b;
};

struct B {
    std::shared_ptr<A> a;
};
```

如果 `A` 持有 `B`，`B` 也持有 `A`，那它们的引用计数可能永远都不会变成 0。

结果就是：

```text
对象不会析构，内存泄漏
```

这就是循环引用。

---

## 3.9 `shared_ptr` 不能乱用

`shared_ptr` 很方便，但不能滥用。

因为它表示：

```text
共享所有权
```

如果其实只有一个拥有者，就应该优先用 `unique_ptr`。

经验上：

```text
默认先想 unique_ptr
确实需要共享时再用 shared_ptr
```

---

## 3.10 目前已掌握的结论

```text
shared_ptr = 共享所有权
拷贝 shared_ptr 会增加引用计数
最后一个 shared_ptr 销毁时对象才释放
循环引用会导致内存泄漏
```

---

## 3.11 和 unique_ptr 的区别

```text
unique_ptr：一个对象只有一个拥有者
shared_ptr：一个对象可以有多个拥有者
```

如果你的问题是“谁负责释放”，优先先想 `unique_ptr`。

如果你的问题是“大家都要用，而且共享生命周期”，再想 `shared_ptr`。

---

# 4. `weak_ptr`

## 4.1 `weak_ptr` 是什么

`weak_ptr` 是配合 `shared_ptr` 使用的。

它表示：

```text
我可以观察这个对象，但我不拥有它
```

最重要特点：

```text
weak_ptr 不增加引用计数
```

---

## 4.2 为什么需要 `weak_ptr`

因为 `shared_ptr` 有一个重要问题：循环引用。

错误模型：

```cpp
struct B;

struct A {
    std::shared_ptr<B> b;
};

struct B {
    std::shared_ptr<A> a;
};
```

如果：

```cpp
auto a = std::make_shared<A>();
auto b = std::make_shared<B>();

a->b = b;
b->a = a;
```

引用关系变成：

```text
外部 a -> A
A -> B
外部 b -> B
B -> A
```

当外部 `a` 和 `b` 销毁后，A 和 B 仍然互相持有，引用计数无法变成 0。

结果：

```text
A 和 B 都不会析构，发生内存泄漏
```

---

## 4.3 用 `weak_ptr` 打破循环引用

正确模型：

```cpp
struct B;

struct A {
    std::shared_ptr<B> b;
};

struct B {
    std::weak_ptr<A> a;
};
```

含义：

```text
A 拥有 B
B 只观察 A，不拥有 A
```

这样外部 `shared_ptr<A>` 销毁时，A 的引用计数可以正常变成 0。

析构链路：

```text
外部 shared_ptr<A> 销毁
-> A 引用计数变成 0
-> A 析构
-> A 里面的 shared_ptr<B> b 析构
-> B 引用计数变成 0
-> B 析构
-> B 里面的 weak_ptr<A> a 随 B 析构
```

最关键的一句话：

```text
weak_ptr 不阻止对象被释放
```

---

## 4.4 `weak_ptr` 不能直接访问对象

因为 `weak_ptr` 不拥有对象，对象可能已经被释放。

所以不能这样：

```cpp
std::weak_ptr<Foo> w;
w->hello(); // 错误
```

要先用：

```cpp
lock()
```

---

## 4.5 `lock()`

```cpp
std::shared_ptr<T> lock() const noexcept;
```

作用：

```text
尝试从 weak_ptr 获取一个 shared_ptr
```

如果对象还活着：

```text
lock() 返回有效 shared_ptr
```

如果对象已经销毁：

```text
lock() 返回空 shared_ptr
```

常见写法：

```cpp
if (auto s = w.lock()) {
    s->hello();
}
```

这样检查和使用连在一起，更安全。

---

## 4.6 `expired()`

```cpp
bool expired() const noexcept;
```

作用：

```text
判断 weak_ptr 观察的对象是否已经释放
```

示例：

```cpp
if (w.expired()) {
    std::cout << "object expired" << std::endl;
}
```

不过实际使用中，更推荐直接用：

```cpp
if (auto s = w.lock()) {
    s->hello();
}
```

---

## 4.7 `weak_ptr` 的典型用途

### 解决循环引用

父子关系、双向关系中经常用：

```text
强拥有方向：shared_ptr
反向观察方向：weak_ptr
```

例如：

```text
Parent 拥有 Child
Child 观察 Parent
```

---

### 缓存

缓存里可以保存一个对象的弱引用：

```text
如果对象还活着，就复用
如果对象已经释放，就重新创建
```

---

### 观察者模式

观察者不一定拥有被观察对象。

可以用：

```text
weak_ptr 表示观察关系
```

---

## 4.8 三者关系

```text
unique_ptr：独占拥有
shared_ptr：共享拥有
weak_ptr：只观察，不拥有
```

判断方式：

```text
谁负责对象生命周期？用 unique_ptr / shared_ptr
谁只是知道它、观察它？用 weak_ptr / 裸指针 / 引用
```

---

## 4.9 目前已掌握的结论

```text
weak_ptr 不增加引用计数
weak_ptr 不能直接访问对象
weak_ptr 要通过 lock() 临时变成 shared_ptr
weak_ptr 主要用来解决 shared_ptr 循环引用
weak_ptr 不阻止对象被释放
```

---
title: 【C++】多线程与并发
date: 2026-08-10
tags:
  - CPP
categories: CPP
series: C++知识整理
top_img: /img/830179.jpg
cover: /img/830179.jpg
---

# 多线程与并发

## 1. 学习目标

本笔记用于快速掌握 C++ 并发编程中的几个核心概念：

- 什么是数据竞争
- 什么是原子性
- `volatile` 的真正作用
- `std::atomic` 的作用
- `std::mutex` 锁的作用
- 什么时候用 atomic，什么时候用 mutex

核心结论：

```text
volatile 不能保证线程安全。
volatile 不能保证原子性。
volatile 不能替代锁。
volatile 不能替代 std::atomic。
```

现代 C++ 多线程同步主要使用：

```cpp
std::atomic
std::mutex
std::lock_guard
std::unique_lock
std::condition_variable
```

---

## 2. 推荐学习顺序

```text
1. 先理解什么是数据竞争
2. 再理解什么是原子性
3. 再区分 volatile 和 atomic
4. 再学习 mutex 锁
5. 最后理解 atomic 和锁分别适合什么场景
```

---

## 3. 什么是原子性

原子性表示：

```text
一个操作要么完整发生，要么完全没有发生；
中间状态不会被其他线程看到。
```

例如：

```cpp
x++;
```

这行代码看起来是一行，但通常不是原子的。

它底层大致可以拆成三步：

```text
1. 从内存读取 x
2. 在 CPU 寄存器里加 1
3. 写回内存
```

如果两个线程同时执行：

```cpp
x++;
```

可能发生：

```text
线程 A 读取 x = 0
线程 B 读取 x = 0
线程 A 写回 1
线程 B 写回 1
```

最终结果是：

```text
1
```

但理论上两个线程各加一次，期望结果应该是：

```text
2
```

这就是经典的并发问题：

```text
丢失更新 lost update
```

---

## 4. 什么是数据竞争

如果多个线程同时访问同一个变量，并且至少有一个线程在写，而且没有同步手段，就是数据竞争。

错误示例：

```cpp
int counter = 0;

void work() {
    for (int i = 0; i < 100000; ++i) {
        counter++;
    }
}
```

如果两个线程同时执行 `work()`，这里就存在数据竞争。

原因：

```text
counter++ 不是原子操作
多个线程同时读写 counter
没有 std::atomic
没有 std::mutex
```

在 C++ 中，数据竞争属于：

```text
undefined behavior，未定义行为
```

这不是简单的“结果不稳定”，而是 C++ 标准不保证程序行为。

---

## 5. volatile 是什么

`volatile` 的作用是告诉编译器：

```text
这个变量可能被当前程序控制流之外的因素修改，
所以每次访问都要真的读写，不要随便优化掉。
```

典型用途：

```text
内存映射 IO
硬件寄存器
某些嵌入式场景
少量信号处理相关场景
```

嵌入式示例：

```cpp
volatile int* status_register = reinterpret_cast<int*>(0x12345678);

while (*status_register == 0) {
}
```

含义：

```text
这个地址可能被硬件修改；
编译器不要把它优化成只读取一次。
```

但是 `volatile` 不保证：

```text
操作原子
线程安全
线程间同步
内存顺序
互斥访问
```

所以这个写法是错误的线程同步方式：

```cpp
volatile int counter = 0;

void work() {
    counter++;
}
```

`volatile` 不能让 `counter++` 变成原子操作。

---

## 6. std::atomic 是什么

`std::atomic` 用于保证某些变量操作是原子的。

正确示例：

```cpp
#include <atomic>
#include <iostream>
#include <thread>

std::atomic<int> counter{0};

void work() {
    for (int i = 0; i < 100000; ++i) {
        counter++;
    }
}

int main() {
    std::thread t1(work);
    std::thread t2(work);

    t1.join();
    t2.join();

    std::cout << counter << std::endl;
}
```

两个线程各加 `100000` 次，结果应该稳定为：

```text
200000
```

因为：

```cpp
counter++;
```

对于 `std::atomic<int>` 来说是原子自增。

它也可以写成：

```cpp
counter.fetch_add(1);
```

常用 atomic 操作：

```cpp
load()
store()
fetch_add()
fetch_sub()
exchange()
compare_exchange_strong()
compare_exchange_weak()
```

入门阶段重点掌握：

```cpp
load()
store()
fetch_add()
```

---

## 7. std::mutex 是什么

`std::mutex` 是互斥锁。

它保证：

```text
同一时间只有一个线程可以进入被锁保护的代码区域。
```

这个被保护的代码区域叫：

```text
临界区 critical section
```

示例：

```cpp
#include <iostream>
#include <mutex>
#include <thread>

int counter = 0;
std::mutex mtx;

void work() {
    for (int i = 0; i < 100000; ++i) {
        std::lock_guard<std::mutex> lock(mtx);
        counter++;
    }
}

int main() {
    std::thread t1(work);
    std::thread t2(work);

    t1.join();
    t2.join();

    std::cout << counter << std::endl;
}
```

这里：

```cpp
std::lock_guard<std::mutex> lock(mtx);
```

含义：

```text
构造 lock 时加锁
离开作用域时自动解锁
```

这依赖 C++ 的 RAII 机制。

推荐写法：

```cpp
std::lock_guard<std::mutex> lock(mtx);
```

不推荐手写：

```cpp
mtx.lock();
counter++;
mtx.unlock();
```

原因：

```text
如果中间出现异常、提前 return，可能导致 unlock 没有执行。
```

---

## 8. atomic 和 mutex 的区别

简单判断：

```text
atomic 适合保护一个简单变量的简单操作。
mutex 适合保护一段复杂逻辑或多个共享变量。
```

适合使用 atomic 的场景：

```cpp
std::atomic<int> counter{0};
counter++;
```

例如：

```text
计数器
简单状态标志
引用计数
简单开关
```

适合使用 mutex 的场景：

```cpp
#include <mutex>
#include <vector>

std::vector<int> data;
std::mutex mtx;

void add(int x) {
    std::lock_guard<std::mutex> lock(mtx);
    data.push_back(x);
}
```

原因是 `vector.push_back()` 不是一个简单的 CPU 原子操作。

它内部可能包含：

```text
检查容量
分配内存
移动已有元素
修改 size
写入新元素
```

这类复杂共享数据结构通常需要锁保护。

---

## 9. 常见错误

### 9.1 错误：用 volatile 做线程同步

错误写法：

```cpp
volatile bool ready = false;

void thread1() {
    ready = true;
}

void thread2() {
    while (!ready) {
    }
}
```

问题：

```text
volatile 不提供 C++ 多线程同步语义。
```

更正确的写法：

```cpp
#include <atomic>

std::atomic<bool> ready{false};

void thread1() {
    ready.store(true);
}

void thread2() {
    while (!ready.load()) {
    }
}
```

但是这个写法会空转，占用 CPU。

工程上更常用：

```cpp
std::condition_variable
```

---

### 9.2 错误：以为一行代码就是原子的

错误理解：

```cpp
counter++;
```

虽然是一行代码，但通常不是一个不可分割操作。

---

### 9.3 错误：以为 atomic 可以保护所有东西

错误思路：

```cpp
std::atomic<std::vector<int>> data;
```

容器这类复杂对象一般不应该这样处理。

通常应该使用：

```cpp
std::mutex
```

---

### 9.4 错误：锁的范围太小

错误写法：

```cpp
if (!data.empty()) {
    std::lock_guard<std::mutex> lock(mtx);
    data.pop_back();
}
```

问题：

```text
empty() 没有被锁保护。
在检查 empty() 和 pop_back() 之间，其他线程可能已经修改了 data。
```

正确写法：

```cpp
std::lock_guard<std::mutex> lock(mtx);
if (!data.empty()) {
    data.pop_back();
}
```

---

## 实验 1：不加锁的 counter++

代码：

```cpp
#include <iostream>
#include <thread>

int counter = 0;

void work() {
    for (int i = 0; i < 1000000; ++i) {
        counter++;
    }
}

int main() {
    std::thread t1(work);
    std::thread t2(work);

    t1.join();
    t2.join();

    std::cout << counter << std::endl;
}
```

编译：

```bash
g++ test.cpp -std=c++17 -pthread -O2
```

运行：

```bash
./a.out
```

理论期望：

```text
2000000
```

实际结果可能小于 `2000000`。

原因：

```text
counter++ 不是原子操作。
多个线程同时读写 counter，发生数据竞争。
```

---

## 实验 2：使用 volatile

代码：

```cpp
#include <iostream>
#include <thread>

volatile int counter = 0;

void work() {
    for (int i = 0; i < 1000000; ++i) {
        counter++;
    }
}

int main() {
    std::thread t1(work);
    std::thread t2(work);

    t1.join();
    t2.join();

    std::cout << counter << std::endl;
}
```

结论：

```text
volatile 版本仍然是错误的。
volatile 不能保证 counter++ 原子。
volatile 不能消除数据竞争。
```

---

## 实验 3：使用 std::atomic

代码：

```cpp
#include <atomic>
#include <iostream>
#include <thread>

std::atomic<int> counter{0};

void work() {
    for (int i = 0; i < 1000000; ++i) {
        counter++;
    }
}

int main() {
    std::thread t1(work);
    std::thread t2(work);

    t1.join();
    t2.join();

    std::cout << counter << std::endl;
}
```

运行结果应该稳定为：

```text
2000000
```

原因：

```text
std::atomic<int> 的自增操作是原子的。
```

---

## 实验 4：使用 std::mutex

代码：

```cpp
#include <iostream>
#include <mutex>
#include <thread>

int counter = 0;
std::mutex mtx;

void work() {
    for (int i = 0; i < 1000000; ++i) {
        std::lock_guard<std::mutex> lock(mtx);
        counter++;
    }
}

int main() {
    std::thread t1(work);
    std::thread t2(work);

    t1.join();
    t2.join();

    std::cout << counter << std::endl;
}
```

运行结果应该稳定为：

```text
2000000
```

原因：

```text
mutex 保证同一时间只有一个线程执行 counter++。
```

---



## 协程

{% note purple 'fas fa-wand-magic-sparkles' %}
协程是一种可以暂停执行，并在之后恢复执行的**函数**。
{% endnote %}

### 1. 什么是协程

普通函数的执行过程是：

```text
调用函数 → 执行到底 → 返回
```

协程可以在执行过程中主动暂停，并在之后从暂停位置继续执行：

```text
调用协程
    ↓
执行一部分
    ↓
暂停执行
    ↓
执行其他任务
    ↓
恢复协程
    ↓
继续执行
```

C++20 开始，C++ 在语言层面正式支持协程。协程不是线程，也不是进程，而是运行在线程之上的一种可暂停、可恢复的执行单元。

### 2. 协程的关键字

C++ 协程主要使用以下三个关键字：

| 关键字 | 作用 |
| --- | --- |
| `co_await` | 等待异步操作，同时暂停当前协程 |
| `co_yield` | 产生一个值并暂停，常用于生成器 |
| `co_return` | 从协程中返回 |

示意代码如下：

```cpp
Task download() {
    std::cout << "开始下载\\n";

    auto data = co_await downloadAsync();

    std::cout << "下载完成\\n";
    co_return;
}
```

当 `downloadAsync()` 尚未完成时，`co_await` 会暂停当前协程，让线程执行其他任务；异步操作完成后，协程再从暂停位置继续执行。

### 3. 协程解决的问题

#### 3.1 简化异步编程

传统异步代码通常使用回调，多个异步操作嵌套后容易形成回调地狱：

```cpp
readAsync([](Data data) {
    parseAsync(data, [](Result result) {
        saveAsync(result, [] {
            std::cout << "完成\\n";
        });
    });
});
```

使用协程后，可以按接近同步代码的方式编写：

```cpp
Data data = co_await readAsync();
Result result = co_await parseAsync(data);
co_await saveAsync(result);

std::cout << "完成\\n";
```

代码表面上是顺序执行的，但等待异步操作时不会一直阻塞线程。

#### 3.2 处理异步 I/O

协程适合网络、文件和数据库等需要等待 I/O 的场景：

```cpp
Task handleClient(Socket socket) {
    auto request = co_await socket.read();
    auto response = process(request);
    co_await socket.write(response);
}
```

当网络数据尚未到达时，协程可以暂停，线程可以处理其他客户端连接。

#### 3.3 实现生成器

生成器按照需要逐个产生数据，而不是一次性生成全部数据：

```cpp
generator<int> numbers() {
    int value = 0;

    while (true) {
        co_yield value++;
    }
}
```

`co_yield` 每次产生一个值后暂停协程，下一次获取数据时再继续执行。生成器适合用于：

- 大数据遍历
- 文件逐行读取
- 分页查询
- 数据流处理
- 无限序列

C++20 提供了底层协程机制，但没有直接提供通用的 `Task` 或 `generator` 类型，实际开发中通常使用 Asio、cppcoro 等库，或者自行封装返回类型。

#### 3.4 简化状态机

没有协程时，异步状态机通常需要手动保存当前状态：

```cpp
switch (state) {
case 0:
    doStep1();
    state = 1;
    break;
case 1:
    doStep2();
    state = 2;
    break;
case 2:
    doStep3();
    state = 3;
    break;
}
```

使用协程后，可以按照自然的业务流程编写：

```cpp
Task run() {
    doStep1();
    co_await waitEvent();

    doStep2();
    co_await waitEvent();

    doStep3();
}
```

编译器和协程运行时会帮助保存暂停位置以及相关局部变量。

### 4. 协程与线程的区别

协程和线程解决的问题不同：

| 对比项 | 协程 | 线程 |
| --- | --- | --- |
| 调度方式 | 通常由程序主动调度 | 通常由操作系统调度 |
| 执行关系 | 多个协程可以运行在同一线程 | 多个线程可以真正并行运行 |
| 切换成本 | 通常较低 | 通常高于协程 |
| 主要用途 | 异步等待、任务调度 | 并行计算、利用多核 CPU |
| 是否自动并行 | 否 | 可以 |

因此：

```text
协程不是线程。
协程不会自动带来并行能力。
协程主要解决等待和调度问题。
线程主要解决并行执行问题。
```

如果协程中执行长时间计算，并且中间没有挂起点，那么它仍然会占用当前线程，无法及时让其他协程执行。

### 5. 协程的优点

- 异步代码结构更清晰，减少回调嵌套。
- 可以保存暂停位置、局部变量和执行状态。
- 协程切换通常比线程切换更加轻量。
- 适合创建大量轻量级任务。
- 适合实现生成器、事件驱动逻辑和异步 I/O。

### 6. 协程的注意事项

- C++20 只提供底层协程机制，没有统一的高级异步运行时。
- 协程本身不能替代线程池或并行计算方案。
- 使用 `co_await` 时需要正确管理协程的生命周期。
- 协程引用的对象必须在协程恢复时仍然有效。
- 长时间计算任务应放到合适的工作线程中，避免阻塞其他协程。

### 7. 适用场景

协程比较适合：

```text
网络服务器
异步文件读写
数据库异步查询
定时器任务
事件驱动程序
生成器和迭代器
游戏逻辑和行为树
流式数据处理
```

对于简单同步函数或纯计算密集型任务，协程不一定比普通函数或线程更合适。

### 8. 总结

协程可以概括为：

> 一种能够暂停并恢复执行的函数机制，用接近同步代码的形式编写异步逻辑。

它主要解决：

```text
异步回调嵌套
大量任务调度
生成器实现
事件驱动状态机
高并发 I/O
```

需要牢记：

```text
协程 ≠ 线程
协程 ≠ 自动并行
```

## 总结

```text
volatile：防止编译器优化某些特殊读写，主要用于硬件寄存器等场景，不解决线程安全。
atomic：保证单个变量的原子操作，适合计数器、状态标志等简单同步。
mutex：保护一段临界区，同一时间只允许一个线程执行，适合复杂共享数据。
原子性：一个操作不可被中断地完整发生。
```


# C++ volatile、atomic、原子性和锁学习笔记

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

最快掌握路线：

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

## 10. 实验 1：不加锁的 counter++

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

## 11. 实验 2：使用 volatile

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

## 12. 实验 3：使用 std::atomic

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

## 13. 实验 4：使用 std::mutex

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

## 14. 三天学习路线

### 第一天：数据竞争和锁

掌握：

```text
线程同时读写同一个变量会出问题
counter++ 不是原子的
mutex 如何保护临界区
lock_guard 为什么安全
```

练习：

```text
1. 不加锁 counter++，观察结果错误
2. 用 mutex 修复
3. 用 atomic 修复
```

---

### 第二天：atomic 和 volatile

掌握：

```text
volatile 不是线程同步工具
atomic 能保证原子操作
load/store/fetch_add
atomic<bool> 用作简单标志位
```

练习：

```text
1. volatile counter++ 仍然错误
2. atomic counter++ 正确
3. atomic<bool> 控制线程退出
```

---

### 第三天：锁的工程用法

掌握：

```text
mutex
lock_guard
unique_lock
condition_variable
死锁
锁粒度
```

练习：

```text
1. 多线程安全队列
2. 生产者消费者模型
```

---

## 15. 一句话总结

```text
volatile：防止编译器优化某些特殊读写，主要用于硬件寄存器等场景，不解决线程安全。
atomic：保证单个变量的原子操作，适合计数器、状态标志等简单同步。
mutex：保护一段临界区，同一时间只允许一个线程执行，适合复杂共享数据。
原子性：一个操作不可被中断地完整发生。
```

---

## 16. 掌握标准

能回答以下问题，说明已经入门：

1. `counter++` 为什么不是原子的？
2. 什么是数据竞争？
3. C++ 中数据竞争为什么严重？
4. `volatile` 的作用是什么？
5. `volatile` 为什么不能保证线程安全？
6. `std::atomic<int>` 为什么可以解决计数器问题？
7. `fetch_add()` 是什么？
8. `std::mutex` 保护的是什么？
9. `std::lock_guard` 为什么比手写 `lock()` / `unlock()` 更安全？
10. 什么时候用 atomic？
11. 什么时候用 mutex？
12. 为什么 `std::vector` 这类容器一般用 mutex 保护？

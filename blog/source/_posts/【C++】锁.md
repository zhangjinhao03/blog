---
title: 【C++】锁
date: 2026-09-15 16:40:06
tags: [CPP,Mutex]
categories: CPP
series: 多线程与并发
top_img: /img/1210768.png
cover: /img/1210768.png
---

# C++锁

{% note purple 'fas fa-wand-magic-sparkles' %}
C++ 常见锁可以分为以下几种
{% endnote %}

```text
1. std::mutex              普通互斥锁
2. std::recursive_mutex    递归锁
3. std::timed_mutex        超时锁
4. std::shared_mutex       读写锁
5. spinlock                自旋锁，标准库没有直接提供
6. std::shared_timed_mutex 带超时能力的读写锁
```

{% note purple 'fas fa-wand-magic-sparkles' %}
常见锁管理器
{% endnote %}

```text
std::lock_guard
std::unique_lock
std::shared_lock
std::scoped_lock
```

**注意：**

```text
mutex、recursive_mutex、timed_mutex、shared_mutex 是锁本身。
lock_guard、unique_lock、shared_lock、scoped_lock 是管理锁的工具。
```

---

## 1. std::mutex：普通互斥锁

`std::mutex` 是最基础、最常用的互斥锁。

作用：

```text
同一时间只允许一个线程进入临界区。
```

示例：

```cpp
#include <mutex>

std::mutex mtx;
int counter = 0;

void add() {
    std::lock_guard<std::mutex> lock(mtx);
    ++counter;
}
```

适合：

```text
保护普通共享变量
保护 vector/map/queue 等容器
保护一段复杂逻辑
保护文件、日志对象、连接池等共享资源
```

---

## 2. std::recursive_mutex：递归锁

### 2.1 作用

`std::recursive_mutex` 允许同一个线程重复加同一把锁。

普通 `std::mutex` 不允许同一个线程重复加锁。

---

### 2.2 普通 mutex 的问题

```cpp
#include <mutex>

std::mutex mtx;

void func2() {
    std::lock_guard<std::mutex> lock(mtx);
}

void func1() {
    std::lock_guard<std::mutex> lock(mtx);
    func2();
}
```

如果调用：

```cpp
func1();
```

执行过程：

```text
func1() 加锁成功
func1() 调用 func2()
func2() 再次尝试加同一把锁
```

这时会卡住。

原因：

```text
同一个线程已经持有 mtx，又试图再次获取它。
普通 mutex 不支持同线程重复加锁。
```

---

### 2.3 recursive_mutex 写法

```cpp
#include <mutex>

std::recursive_mutex mtx;

void func2() {
    std::lock_guard<std::recursive_mutex> lock(mtx);
}

void func1() {
    std::lock_guard<std::recursive_mutex> lock(mtx);
    func2();
}
```

这时同一个线程可以重复加锁。

---

### 2.4 使用场景

适合：

```text
递归函数中需要加锁
老代码中多个函数互相调用，且都需要保护同一资源
```

不建议滥用：

```text
recursive_mutex 容易掩盖设计问题。
很多时候更好的办法是重新划分加锁边界。
```

---

## 3. std::timed_mutex：超时锁

### 3.1 作用

`std::timed_mutex` 可以尝试获取锁，但不会无限等待。

普通 mutex：

```cpp
mtx.lock();
```

如果拿不到锁，会一直等待。

`timed_mutex` 提供：

```cpp
try_lock_for()
try_lock_until()
```

---

### 3.2 示例

```cpp
#include <chrono>
#include <iostream>
#include <mutex>
#include <thread>

std::timed_mutex mtx;

void work() {
    if (mtx.try_lock_for(std::chrono::seconds(1))) {
        std::cout << "got lock" << std::endl;

        std::this_thread::sleep_for(std::chrono::seconds(2));

        mtx.unlock();
    } else {
        std::cout << "failed to get lock" << std::endl;
    }
}

int main() {
    std::thread t1(work);
    std::thread t2(work);

    t1.join();
    t2.join();
}
```

可能输出：

```text
got lock
failed to get lock
```

原因：

```text
第一个线程拿到锁后睡 2 秒。
第二个线程最多等 1 秒。
等不到就失败。
```

---

### 3.3 使用场景

适合：

```text
不能无限等待锁
需要超时降级
需要避免线程永久卡死
服务端请求有超时时间
```

---

## 4. std::shared_mutex：读写锁

### 4.1 作用

`std::shared_mutex` 也叫读写锁。

它允许：

```text
多个线程同时读
写线程独占访问
```

---

### 4.2 为什么需要读写锁

普通 `std::mutex` 的行为：

```text
读和读之间互斥
读和写之间互斥
写和写之间互斥
```

但很多场景里：

```text
读操作不会修改数据。
多个线程同时读是安全的。
只有写操作需要独占。
```

这时使用 `std::shared_mutex` 可以提高并发度。

---

### 4.3 示例

```cpp
#include <mutex>
#include <shared_mutex>
#include <string>
#include <unordered_map>

std::unordered_map<std::string, int> cache;
std::shared_mutex mtx;

int get_value(const std::string& key) {
    std::shared_lock<std::shared_mutex> lock(mtx);

    auto it = cache.find(key);
    if (it != cache.end()) {
        return it->second;
    }

    return -1;
}

void set_value(const std::string& key, int value) {
    std::unique_lock<std::shared_mutex> lock(mtx);

    cache[key] = value;
}
```

读操作使用：

```cpp
std::shared_lock<std::shared_mutex> lock(mtx);
```

写操作使用：

```cpp
std::unique_lock<std::shared_mutex> lock(mtx);
```

---

### 4.4 读写锁规则

```text
多个读锁可以同时存在。
写锁只能独占。
有写锁时，不能有读锁。
有读锁时，写锁通常需要等待。
```

---

### 4.5 使用场景

适合：

```text
读多写少
配置表
缓存
路由表
字典查询
状态快照
```

不适合：

```text
写很多
读操作也很慢
锁竞争严重
```

如果写操作很多，读写锁可能不如普通 `std::mutex`。

---

## 5. spinlock：自旋锁

### 5.1 作用

自旋锁的特点是：

```text
拿不到锁时，不睡眠，而是一直循环等待。
```

普通 mutex 拿不到锁时，线程可能被操作系统挂起。

自旋锁拿不到锁时类似：

```cpp
while (拿不到锁) {
    // 一直循环
}
```

---

### 5.2 示例

C++ 标准库没有直接提供 `spinlock` 类，但可以用 `std::atomic_flag` 实现。

```cpp
#include <atomic>

class SpinLock {
private:
    std::atomic_flag flag = ATOMIC_FLAG_INIT;

public:
    void lock() {
        while (flag.test_and_set(std::memory_order_acquire)) {
        }
    }

    void unlock() {
        flag.clear(std::memory_order_release);
    }
};
```

使用：

```cpp
SpinLock lock;

void work() {
    lock.lock();

    // 临界区

    lock.unlock();
}
```

实际项目中如果要写自旋锁，也应该使用 RAII 包装，避免忘记解锁。

---

### 5.3 优点

```text
临界区极短时性能好
避免线程睡眠和唤醒的上下文切换开销
```

---

### 5.4 缺点

```text
拿不到锁时一直占用 CPU
临界区稍微长一点就很浪费
不适合普通业务代码
```

---

### 5.5 使用场景

适合：

```text
底层系统编程
内核场景
极短临界区
非常明确不会长时间持锁的场景
```

普通 C++ 应用里，一般优先使用：

```cpp
std::mutex
```

不要随便自己写自旋锁。

---

## 6. std::shared_timed_mutex

`std::shared_timed_mutex` 是带超时能力的读写锁。

可以理解为：

```text
shared_mutex + timed_mutex
```

它支持：

```text
共享读锁
独占写锁
超时获取锁
```

常见代码里使用频率不如 `std::shared_mutex` 高。

---

## 7. 锁管理器

锁管理器不是锁本身，而是管理锁生命周期的对象。

它们的主要价值是：

```text
构造时自动加锁
析构时自动解锁
避免忘记 unlock
异常安全
```

---

### 7.1 std::lock_guard

最简单的锁管理器。

```cpp
std::lock_guard<std::mutex> lock(mtx);
```

特点：

```text
构造时加锁
析构时解锁
不能手动解锁
不能重新加锁
开销小
```

适合：

```text
简单临界区
作用域明确
不需要中途解锁
```

---

### 7.2 std::unique_lock

比 `lock_guard` 更灵活。

```cpp
std::unique_lock<std::mutex> lock(mtx);
```

特点：

```text
可以手动 unlock
可以重新 lock
可以延迟加锁
可以转移所有权
可以和 condition_variable 配合
```

适合：

```text
需要中途解锁
需要条件变量
需要更灵活控制锁生命周期
```

---

### 7.2.1 lock_guard 和 unique_lock 的详细区别

先记住一句话：

```text
lock_guard 简单、安全、轻量。
unique_lock 更灵活，但稍微重一点。
```

#### lock_guard 的能力

```cpp
std::lock_guard<std::mutex> lock(mtx);
```

它只做两件事：

```text
构造时：mtx.lock()
析构时：mtx.unlock()
```

它不支持：

```text
手动 unlock
重新 lock
延迟加锁
转移锁所有权
配合 condition_variable 等待
```

适合：

```text
进入作用域就加锁
离开作用域就解锁
中间不需要复杂控制
```

示例：

```cpp
#include <mutex>
#include <vector>

std::mutex mtx;
std::vector<int> data;

void push(int x) {
    std::lock_guard<std::mutex> lock(mtx);
    data.push_back(x);
}
```

---

#### unique_lock 可以手动解锁

```cpp
std::unique_lock<std::mutex> lock(mtx);

// 访问共享数据

lock.unlock();

// 这里已经不持有锁
```

适合：

```text
只想保护前半段共享数据，后面耗时操作不需要持锁。
```

示例：

```cpp
#include <mutex>
#include <vector>

std::mutex mtx;
std::vector<int> data;

void expensive_work(int value) {
    // 耗时处理，不访问 data
}

void pop_and_process() {
    std::unique_lock<std::mutex> lock(mtx);

    if (data.empty()) {
        return;
    }

    int value = data.back();
    data.pop_back();

    lock.unlock();

    expensive_work(value);
}
```

这里的关键是：

```text
锁只保护 data 的访问。
取出数据后立刻解锁。
耗时处理不要放在锁里。
```

---

#### unique_lock 可以延迟加锁

```cpp
std::unique_lock<std::mutex> lock(mtx, std::defer_lock);
```

含义：

```text
创建 unique_lock 对象，但先不加锁。
```

后面可以手动加锁：

```cpp
lock.lock();
```

示例：

```cpp
std::mutex mtx;

void func() {
    std::unique_lock<std::mutex> lock(mtx, std::defer_lock);

    // 这里还没有加锁

    lock.lock();

    // 临界区

    lock.unlock();
}
```

---

#### unique_lock 可以尝试加锁

```cpp
std::unique_lock<std::mutex> lock(mtx, std::try_to_lock);

if (lock.owns_lock()) {
    // 拿到了锁
} else {
    // 没拿到锁
}
```

含义：

```text
尝试加锁，拿不到也不阻塞。
```

适合：

```text
拿不到锁就跳过
避免线程卡住
```

---

#### unique_lock 可以接管已经加好的锁

```cpp
mtx.lock();
std::unique_lock<std::mutex> lock(mtx, std::adopt_lock);
```

含义：

```text
mtx 已经被当前线程锁住了。
unique_lock 负责后续自动解锁。
```

注意：

```text
adopt_lock 要小心使用。
如果 mtx 实际没有被当前线程锁住，行为就是错误的。
```

`lock_guard` 也支持 `adopt_lock`：

```cpp
mtx.lock();
std::lock_guard<std::mutex> lock(mtx, std::adopt_lock);
```

入门阶段一般不推荐这样写。

---

#### unique_lock 可以转移所有权

`unique_lock` 可以移动，不能复制。

```cpp
std::unique_lock<std::mutex> make_lock(std::mutex& mtx) {
    std::unique_lock<std::mutex> lock(mtx);
    return lock;
}
```

这表示：

```text
锁的管理权可以从一个 unique_lock 转移到另一个 unique_lock。
```

`lock_guard` 不能移动，也不能复制。

---

#### unique_lock 可以配合 condition_variable

这是 `unique_lock` 最重要的实际用途之一。

```cpp
#include <condition_variable>
#include <mutex>

std::mutex mtx;
std::condition_variable cv;
bool ready = false;

void wait_thread() {
    std::unique_lock<std::mutex> lock(mtx);

    cv.wait(lock, [] {
        return ready;
    });

    // ready 为 true 后继续执行
}
```

`condition_variable::wait()` 内部需要：

```text
等待前临时释放锁
被唤醒后重新获取锁
```

`lock_guard` 不能手动释放和重新加锁，所以不能用于 `condition_variable::wait()`。

---

#### 对比表

```text
能力                         lock_guard     unique_lock
-------------------------------------------------------
RAII 自动加锁/解锁             支持           支持
构造时立即加锁                 支持           支持
手动 unlock                    不支持         支持
重新 lock                      不支持         支持
延迟加锁 defer_lock            不支持         支持
尝试加锁 try_to_lock           不支持         支持
接管已有锁 adopt_lock          支持           支持
移动所有权                     不支持         支持
配合 condition_variable        不支持         支持
开销                           更小           稍大
使用复杂度                     简单           更灵活
```

---

#### 选择原则

优先用：

```cpp
std::lock_guard<std::mutex> lock(mtx);
```

当你只需要：

```text
进入作用域加锁
离开作用域解锁
中途不需要释放锁
不需要条件变量
```

才使用 `unique_lock`：

```text
需要中途 unlock
需要延迟加锁
需要 try_lock
需要和 condition_variable 配合
需要转移锁所有权
```

一句话：

```text
lock_guard 是默认选择，unique_lock 是高级选择。
能用 lock_guard，就不要用 unique_lock。
```

---

### 7.3 std::shared_lock

专门配合 `std::shared_mutex` 做读锁。

```cpp
std::shared_lock<std::shared_mutex> lock(mtx);
```

特点：

```text
多个 shared_lock 可以同时存在
用于共享读访问
```

适合：

```text
读多写少场景中的读操作
```

---

### 7.4 std::scoped_lock

C++17 引入。

```cpp
std::scoped_lock lock(mtx1, mtx2);
```

特点：

```text
可以一次锁多个 mutex
作用域结束自动解锁
自动避免常见死锁问题
```

适合：

```text
需要同时锁多个资源
```

示例：

```cpp
#include <mutex>

std::mutex m1;
std::mutex m2;

void func() {
    std::scoped_lock lock(m1, m2);

    // 同时访问 m1 和 m2 保护的资源
}
```

---

## 8. 怎么选择锁

简单选择表：

```text
普通共享数据             std::mutex
简单作用域加锁           std::lock_guard
需要灵活加锁/解锁         std::unique_lock
读多写少                 std::shared_mutex
读写锁中的读操作          std::shared_lock
递归调用中重复加锁        std::recursive_mutex
不能无限等待锁           std::timed_mutex
多个锁一起加             std::scoped_lock
极短临界区、底层优化      spinlock
```

入门阶段优先级：

```text
第一优先：std::mutex + std::lock_guard
第二优先：std::unique_lock，用于 condition_variable
第三优先：std::shared_mutex，用于读多写少
其他锁先知道用途，不要乱用
```

---

## 9. 使用须知

### 9.1 优先使用 RAII 管理锁

推荐：

```cpp
std::lock_guard<std::mutex> lock(mtx);
```

不推荐：

```cpp
mtx.lock();
// 临界区
mtx.unlock();
```

原因：

```text
手动 lock/unlock 容易因为异常、return、分支遗漏导致忘记解锁。
```

---

### 9.2 recursive_mutex 不要滥用

如果频繁需要递归锁，通常说明：

```text
函数调用关系和加锁边界可能设计得不清晰。
```

---

### 9.3 spinlock 不要随便用

自旋锁拿不到锁时会一直占用 CPU。

如果临界区不是极短，或者线程可能被调度出去，自旋锁可能严重浪费 CPU。

---

### 9.4 shared_mutex 适合读多写少

如果写操作很多，读写锁不一定比普通 mutex 更快。

---

## 10. 总结

```text
std::mutex 是最常用的普通互斥锁。
std::recursive_mutex 允许同线程重复加锁，但不建议滥用。
std::timed_mutex 支持超时获取锁。
std::shared_mutex 适合读多写少。
spinlock 适合极短临界区和底层场景，普通业务慎用。
lock_guard、unique_lock、shared_lock、scoped_lock 是管理锁生命周期的工具。
```

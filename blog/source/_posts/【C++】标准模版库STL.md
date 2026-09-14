---
title: 【C++】标准模版库STL
date: 2026-09-07 19:00:33
tags: [CPP]
categories: CPP
series: C++知识整理
top_img: /img/1089613.jpg
cover: /img/1089613.jpg
---

# C++标准模版库STL

## 容器

- 顺序容器：`vector`、`deque`、`list`
- 关联容器：`set`、`map`、`multiset`、`multimap`
- 无序容器：`unordered_set`、`unordered_map`
- 容器适配器：`stack`、`queue`、`priority_queue`

---

### vector

{% note purple 'fas fa-wand-magic-sparkles' %}

vector的底层实现原理为**一维数组**

{% endnote %}

**特点**：元素在内存连续存放，动态数组，在堆中分配内存，元素连续存放，有保留内存，如果减少大小 

后内存也不会释放。 

**优点**：和数组类似开辟一段连续的空间，并且支持随机访问，所以它的查找效率高其时间复杂度O(1)。 

**缺点**：由于开辟一段连续的空间，所以插入删除会需要对数据进行移动比较麻烦，时间复杂度O 

（n），另外当空间不足时还需要进行扩容。

**使用场景**

适合需要随机访问的场景

**大概实现原理**

```cpp
#include <cstddef>
#include <stdexcept>

class DefVector {
private:
    int* data_ = nullptr;
    std::size_t size_ = 0;
    std::size_t capacity_ = 0;

    // 重新分配更大的连续内存，并复制原有元素。
    void reallocate(std::size_t newCapacity) {
        int* newData = new int[newCapacity];

        for (std::size_t i = 0; i < size_; ++i) {
            newData[i] = data_[i];
        }

        delete[] data_;
        data_ = newData;
        capacity_ = newCapacity;
    }

public:
    DefVector() = default;

    ~DefVector() {
        delete[] data_;
    }

    // 禁止拷贝，避免多个对象管理同一块内存。
    DefVector(const DefVector&) = delete;
    DefVector& operator=(const DefVector&) = delete;

    // 添加元素。
    void push_back(int value) {
        if (size_ == capacity_) {
            const std::size_t newCapacity =
                capacity_ == 0 ? 1 : capacity_ * 2;
            reallocate(newCapacity);
        }

        data_[size_] = value;
        ++size_;
    }

    // 删除最后一个元素。
    void pop_back() {
        if (size_ > 0) {
            --size_;
        }
    }

    // 使用下标访问元素，不进行边界检查。
    int& operator[](std::size_t index) {
        return data_[index];
    }

    const int& operator[](std::size_t index) const {
        return data_[index];
    }

    // 访问元素，进行边界检查。
    int& at(std::size_t index) {
        if (index >= size_) {
            throw std::out_of_range("index out of range");
        }

        return data_[index];
    }

    const int& at(std::size_t index) const {
        if (index >= size_) {
            throw std::out_of_range("index out of range");
        }

        return data_[index];
    }

    // 预先申请容量。
    void reserve(std::size_t newCapacity) {
        if (newCapacity > capacity_) {
            reallocate(newCapacity);
        }
    }

    // 清空元素，但不释放已申请的内存。
    void clear() {
        size_ = 0;
    }

    std::size_t size() const {
        return size_;
    }

    std::size_t capacity() const {
        return capacity_;
    }

    bool empty() const {
        return size_ == 0;
    }
};
```

---

### list

{% note purple 'fas fa-wand-magic-sparkles' %}

list的底层实现原理为**双向链表**

{% endnote %}

**特点**：元素在堆中存放，每个元素都是存放在一块内存中，它的内存空间可以是不连续的，通过指针来 

进行数据的访问。

**优点**：底层实现是循环双链表，当对大量数据进行插入删除时，其时间复杂度O(1)。 

**缺点**：底层没有连续的空间，只能通过指针来访问，所以查找数据需要遍历其时间复杂度O（n），没 

有提供`[]`操作符的重载



**使用场景**

适合需要高效的插入和删除，而不关心随机访问

---

### deque

{% note purple 'fas fa-wand-magic-sparkles' %}

采用双向队列实现，元素在内存中连续存放

{% endnote %}

不同操作的时间复杂度为：

插入: O(N) 

查看: O(1) 

删除: O(N)

---

### set

{% note purple 'fas fa-wand-magic-sparkles' %}

 set 即集合。set中不允许相同元素

{% endnote %}

底层原理为红黑树



### multiset

{% note purple 'fas fa-wand-magic-sparkles' %}

multiset是允许有重复元素的集合

{% endnote %}

底层同样也由红黑树实现

插入：O(log n)   

查找：O(log n)

删除：O(log n)   

遍历：O(n)

### unordered_set

{% note purple 'fas fa-wand-magic-sparkles' %}

{% endnote %}

底层原理为哈希表





---

### map

{% note purple 'fas fa-wand-magic-sparkles' %}

map内部实现了一个**红黑树**（红黑树是非严格平衡的二叉搜索树，而AVL是严格平衡二叉搜索 

树），红黑树有自动排序的功能，因此map内部所有元素都是有序的，红黑树的每一个节点都代表 

着map的一个元素。因此，对于map进行的查找、删除、添加等一系列的操作都相当于是对红黑树 

进行的操作。map中的元素是按照二叉树（又名二叉查找树、二叉排序树）存储的，特点就是左子 

树上所有节点的键值都小于根节点的键值，右子树所有节点的键值都大于根节点的键值。使用中序 

遍历可将键值按照从小到大遍历出来。

{% endnote %}

### multimap

{% note purple 'fas fa-wand-magic-sparkles' %}

**不同于map:**

键值允许重复，一个键值对应多个值，不支持`[]`操作符，查找结果对应多个元素

{% endnote %}

```cpp
std::multimap<Key, Value>

std::multimap<int, std::string> students;

students.insert({1, "Alice"});
students.insert({1, "Bob"});
students.insert({2, "Tom"});
```

**使用场景**

用于保存“一个键对应多个值”的数据

### unordered_map

{% note purple 'fas fa-wand-magic-sparkles' %}

unordered_map内部实现了一个**哈希表**（也叫散列表），通过把关键码值映射到Hash表中一个位 

置来访问记录，**查找时间复杂度可达O（1）**，其中在海量数据处理中有着广泛应用。因此，元素 

的排列顺序是**无序**的。

{% endnote %}

key不允许重复

查找、插入、删除的时间复杂度为O(1)；

---

### stack

{% note purple 'fas fa-wand-magic-sparkles' %}

{% endnote %}



### queue

{% note purple 'fas fa-wand-magic-sparkles' %}

{% endnote %}



### priority_queue

{% note purple 'fas fa-wand-magic-sparkles' %}

{% endnote %}





## 算法

### sort

std::sort底层使用内省排序（Introsort） = 快排 + 堆排 + 插入排序

**1.快排**

主要部分为快速排序，快速排序平均情况下速度很快，通常具有较好的缓存局部性。

**2.堆排序**

**防止快排退化**，快速排序在特殊情况下可能退化为：O(n²) 

因此 Introsort 会限制递归深度：最大递归深度 ≈ 2 × log₂(n)

如果递归深度超过限制，就认为快速排序可能正在退化，此时切换为堆排序：保证最坏复杂度为 O(n log n) 

**3.插入排序：处理小区间**

当待排序区间比较小时，继续使用快速排序的递归和划分反而不划算。

因此通常会切换为插入排序

---

- `find`
- `binary_search`
- `lower_bound` / `upper_bound`
- `accumulate`
- `for_each`
- 其他常用算法

## 迭代器

- 输入 / 输出 / 前向 / 双向 / 随机访问迭代器

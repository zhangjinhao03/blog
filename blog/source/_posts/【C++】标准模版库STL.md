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

- `sort`
- `find`
- `binary_search`
- `lower_bound` / `upper_bound`
- `accumulate`
- `for_each`
- 其他常用算法

## 迭代器

- 输入 / 输出 / 前向 / 双向 / 随机访问迭代器

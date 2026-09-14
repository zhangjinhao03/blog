---
title: 【Datastruct】哈希表
date: 2023-09-07 15:29:06
tags: [CPP,Hash,Datastruct]
categories: Datastruct
series: 数据结构基础
top_img: /img/hash.png
cover: /img/hash.png
---

# 哈希表拉链法实现C++版

{% note purple 'fas fa-wand-magic-sparkles' %}

哈希表（Hash Table）是一种通过哈希函数快速存储和查找数据的数据结构。

{% endnote %}

## 哈希表

哈希表常由以下部分组成：

哈希函数 + 数组（桶） + 冲突处理机制

基本流程：

```tex
key
 ↓                                                                              
哈希函数
 ↓
哈希值
 ↓
映射到数组下标
 ↓  
存储或查找数据
```

**哈希函数**负责将任意 key 转换为数组下标或哈希值。

一个好的哈希函数应该满足：                                                                                                                                                                            
  1. 相同的 key 必须得到相同的哈希值；                                                                                                                                                  
  2. 不同的 key 尽量分布到不同位置；                                                                                                                                                  
  3. 计算速度较快；                                                                                                                                                                     
  4. 尽量减少哈希冲突。

## 哈希冲突

当两个不同的 key 映射到同一个数组下标时，就发生了哈希冲突。

## 解决哈希冲突

### 1.链地址法（拉链法）

每个桶不只存储一个元素，而是存储一个链表或其他容器：

```tex
桶0：空 
桶1：空
桶2：空 
桶3：23 -> 33 -> 43 
桶4：空 
```

使用相同下标的元素放在同一个链表中。

优点：                                                                                                                                                                                

  - 实现相对简单；                                                                                                                                                                      
  - 哈希表装满后仍然可以继续插入；                                                                                                                                                    
  - 删除操作比较方便。                                                                                                                                                                          

  缺点：                                                                                                                                                                                
  - 需要额外的链表或节点空间；                                                                                                                                                          
  - 冲突严重时，某个桶中的链表可能很长；                                                                                                                                              
  - 会产生额外的指针访问。  

### 2.开放地址法

开放地址法不使用链表，而是把所有元素直接放在哈希表数组中。

发生冲突时，按照某种规则寻找其他空位置。

**线性探测**

如果目标位置已被占用，就依次检查下一个位置：

hash(key) = 3

```tex
下标 3 已被占用  
检查 4   
下标 4 已被占用  
检查 5  
下标 5 为空
存入下标 5
```

探测公式：

```cpp
index = (hash(key) + step) % tableSize;
```

step = 0, 1, 2, 3, ...

优点：                                                                                                                                                                          
  - 不需要额外链表；                                                                                                                                                                    
  - 数据连续存储，缓存局部性较好；                                                                                                                                                    
  - 内存结构相对紧凑。                                                                                                                                                                                    

  缺点：                                                                                                                                                                               
  - 删除不能简单清空位置，否则可能破坏后续查找；                                                                                                                                        
  - 表中空闲位置较少时，性能下降明显；                                                                                                                                                
  - 容易产生连续聚集问题。

**二次探测**

发生冲突时，不是每次加 1，而是按照平方距离探测：

```cpp
index = (hash(key) + step * step) % tableSize;
```

探测位置类似：

```tex
原位置                                                                            
原位置 + 1²
原位置 + 2²
原位置 + 3²
...
```

相比线性探测，可以减少连续位置聚集。

**开放地址法删除键值对**

删除键值对不能简单地把槽位设置为“空”，通常要使用一个特殊状态：

```cpp
enum class State {
    Empty,   //从未使用
    Occupied //当前存放数据
    Deleted  //曾经存放过，但已删除  --墓碑标记--
};
```

假设使用线性探测，哈希表大小为 7：

```cpp
index = key % 7
```

插入：

```tex
key = 10 → 10 % 7 = 3
key = 17 → 17 % 7 = 3
```

发生冲突后：

```tex
下标 3：10
下标 4：17
```

现在删除 10。

如果直接把下标 3 设置为空：

```tex
下标 3：EMPTY
下标 4：17
```

之后查找 17：

```tex
1. 计算 17 % 7 = 3
2. 检查下标 3
3. 发现是 EMPTY
4. 认为 17 不存在
```

因此，删除后不能使用普通的 EMPTY，而要标记为：

```tex
下标 3：DELETED
下标 4：17
```

查找时遇到 DELETED，需要继续向后探测。



### 3.双重哈希

使用第二个哈希函数计算探测步长：

```cpp
index = (hash1(key) + step * hash2(key)) % tableSize;
```

不同 key 的探测步长也不同，可以进一步减少聚集现象。

## 字符串哈希

使用多项式哈希计算：

```cpp
hash = hash × base + 字符编码
```

假设：

```tex
base = 131
初始 hash = 0
```

"abcd"

ASCII 编码为：

97 98 99 100

逐个计算：

```cpp
// a
hash = 0 × 131 + 97 = 97
    
// b
hash = 97 × 131 + 98 = 12805
    
// c
hash = 12805 × 131 + 98 = 1677554
    
// d
hash = 1677554 × 131 + 100 = 219759674

所以
hash("abcd") = 219759674
```

**注：**哈希值本身通常很大，不能直接作为数组下标，还需要取模。

假设哈希表有 8 个桶

index = hash % 8
        = 219759674 % 8
        = 2

直接把字符相加会导致：

abcd、dcba、bcad的值都相同

而多项式哈希中，每个字符都会参与乘法计算，字符顺序不同，结果通常也不同：

## 常见哈希函数

### MD5算法

MD5 是一种密码学哈希算法，可以把任意长度的数据转换成固定长度的摘要。

**特点：**

输出固定为 128 位，也就是 16 字节。

相同输入一定得到相同结果。

输入稍微改变，摘要通常会发生明显变化。

不可逆，不能通过摘要还原原文。

计算速度较快。

**常见用途**

文件完整性校验

判断文件是否发生变化

**安全性问题**

MD5 已经不再适合安全场景，因为它存在严重的碰撞问题：

不同输入可能构造出相同的 MD5 值

因此不能用于：

密码存储

数字签名

安全认证

**加盐**

MD5 加盐就是在密码进行哈希之前，额外加入一段随机字符串：

密码 + 随机盐值 → MD5 → 最终摘要

加盐可以

​	防止相同密码得到相同结果

​	增加破解彩虹表的难度	

### CRC算法

循环冗余校验

CRC 主要用于检查数据在传输或存储过程中是否发生错误。

原始数据 → CRC 计算 → CRC 校验值

接收方收到数据后重新计算 CRC，并和原来的校验值比较

**使用场景**

网络数据传输

压缩文件

以太网数据帧

## 哈希表拉链法实现C++版

```c
#include <cstddef>
#include <functional>
#include <list>
#include <string>
#include <utility>
#include <vector>

// 使用拉链法实现的简单哈希表。
// key 类型为 int，value 类型为 std::string。
class HashMap {
private:
    struct Entry {
        int key;
        std::string value;
    };

    // 每个桶对应一条链表，用于保存发生哈希冲突的元素。
    std::vector<std::list<Entry>> buckets_;
    std::size_t size_ = 0;

    // 根据 key 计算桶下标。
    std::size_t indexOf(int key) const {
        return std::hash<int>{}(key) % buckets_.size();
    }

    // 当负载因子超过 0.75 时扩容。
    void rehash() {
        if (size_ * 4 <= buckets_.size() * 3) {
            return;
        }

        std::vector<std::list<Entry>> newBuckets(buckets_.size() * 2);

        for (const auto& bucket : buckets_) {
            for (const auto& entry : bucket) {
                const std::size_t newIndex =
                    std::hash<int>{}(entry.key) % newBuckets.size();
                newBuckets[newIndex].push_back(entry);
            }
        }

        buckets_ = std::move(newBuckets);
    }

public:
    explicit HashMap(std::size_t bucketCount = 8)
        : buckets_(bucketCount == 0 ? 1 : bucketCount) {}

    // 插入键值对。如果 key 已存在，则更新对应的 value。
    void insert(int key, const std::string& value) {
        const std::size_t index = indexOf(key);
        auto& bucket = buckets_[index];

        for (auto& entry : bucket) {
            if (entry.key == key) {
                entry.value = value;
                return;
            }
        }

        bucket.push_back({key, value});
        ++size_;
        rehash();
    }

    // 查找 key 对应的 value。找到时写入 value 并返回 true。
    bool find(int key, std::string& value) const {
        const std::size_t index = indexOf(key);
        const auto& bucket = buckets_[index];

        for (const auto& entry : bucket) {
            if (entry.key == key) {
                value = entry.value;
                return true;
            }
        }

        return false;
    }

    // 判断 key 是否存在。
    bool contains(int key) const {
        std::string value;
        return find(key, value);
    }

    // 删除 key 对应的键值对。
    bool erase(int key) {
        const std::size_t index = indexOf(key);
        auto& bucket = buckets_[index];

        for (auto it = bucket.begin(); it != bucket.end(); ++it) {
            if (it->key == key) {
                bucket.erase(it);
                --size_;
                return true;
            }
        }

        return false;
    }

    std::size_t size() const {
        return size_;
    }

    bool empty() const {
        return size_ == 0;
    }
};

```

---
title: 【Datastruct】哈希表拉链法实现
date: 2023-09-07 15:29:06
tags: [C,Hash,Datastruct]
categories: Datastruct
series: 数据结构基础
top_img: /img/922387.jpg
cover: /img/922387.jpg
---

# 哈希表拉链法实现C语言版

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

### 3.双重哈希

使用第二个哈希函数计算探测步长：

```cpp
index = (hash1(key) + step * hash2(key)) % tableSize;
```

不同 key 的探测步长也不同，可以进一步减少聚集现象。

## 哈希表实现C语言版

```c
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

typedef struct hash {
    int nValue;
    struct hash* pNext;
}Hash;

Hash** CreateHashTable(int arr[], int nLength) {
    if (arr == NULL || nLength <= 0) return NULL;
    
    Hash** pHash = NULL;
    pHash = (Hash**)malloc(sizeof(Hash*) * nLength);
    memset(pHash,0,sizeof(Hash*) * nLength);
    int nIndex;
    Hash* pTemp = NULL;
    int i;
    for (i = 0; i < nLength; i++) {
        nIndex = arr[i]%nLength;
        pTemp = (Hash*)malloc(sizeof(Hash));
        pTemp->nValue = arr[i];
        pTemp->pNext = pHash[nIndex];
        pHash[nIndex] = pTemp;
    }
    return pHash;
}

void HashSearch(Hash **pHash,int nLength,int nNum) {
    if (pHash == NULL) return;
    int nIndex = nNum % nLength;
    Hash* pTemp = pHash[nIndex];
    while (pTemp) {
        if (pTemp->nValue == nNum) {
            printf("%d\n", pTemp->nValue);
            return;
        }
        pTemp = pTemp->pNext;
    }
    printf("failed.\n");
}


int main() {
    int arr[] = { 10,116,2,18,99,333,15,25,90,376 };
    Hash** pHash = CreateHashTable(arr,sizeof(arr)/sizeof(arr[0]));
    HashSearch(pHash,sizeof(arr)/sizeof(arr[0]),333);
    return 0;
}
```

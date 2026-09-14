---
title: 【C++】内存管理
date: 2026-09-07 19:00:08
tags: [CPP,C]
categories: CPP
series: C++知识整理
top_img: /img/909101.jpg
cover: /img/909101.jpg
---

# C++内存管理



- 栈、堆、静态区



## new/delete





## malloc/free

### malloc

{% note purple 'fas fa-wand-magic-sparkles' %}
malloc 用于在堆上申请一块指定大小的连续内存
{% endnote %}

函数声明：

```c
void* malloc(std::size_t size);
```

例如申请 10 个 int 的空间：

```c
int* data = (int*)malloc(sizeof(int)*10);
```

申请成功后：data 指向堆内存的起始位置

申请失败时返回： nullptr



**注：**malloc 申请的内存没有初始化

此时 data[0]、data[1]、data[2] 的值是不确定的，不能直接当作 0 使用。

---

### free

{% note purple 'fas fa-wand-magic-sparkles' %}
free 用于释放由 malloc、calloc 或 realloc 申请的内存：
{% endnote %}

```c
free(data);
```

释放后，指针本身仍然保存着原来的地址，但这块内存已经不能再访问。

推荐释放后置空：

```c
free(data);
data = nullptr;
```













---

- 内存泄漏
- 野指针、悬空指针
- 内存对齐

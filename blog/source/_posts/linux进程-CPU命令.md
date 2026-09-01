---
title: Linux 进程、内存、CPU
date: 2026-08-10
tags: [Linux]
categories: Docs
top_img: /img/830179.jpg
cover: /img/830179.jpg
---

# Linux 进程、内存、CPU 检查学习笔记

## 1. 学习目标

快速掌握 Linux 常用检查命令，重点用于判断：

- 哪些进程占 CPU 高
- 哪些进程占内存高
- 系统内存是否紧张
- CPU 是否打满
- 是否存在 swap 换页
- 什么是虚拟内存和物理内存

核心思路：

```text
机器变慢时，先判断：
1. 是哪个进程？
2. CPU 是否高？
3. 内存是否够？
4. 是否频繁 swap？
5. 进程实际占用了多少物理内存？
```

---

## 2. 必须掌握的命令

### 2.1 查看进程

```bash
ps aux
ps -ef
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head
ps -p <PID> -o pid,ppid,stat,%cpu,%mem,cmd
```

最常用：

```bash
ps aux --sort=-%mem | head
```

作用：按内存占用从高到低查看进程。

```bash
ps aux --sort=-%cpu | head
```

作用：按 CPU 占用从高到低查看进程。

---

### 2.2 实时查看系统状态

```bash
top
```

进入 `top` 后常用按键：

```text
P    按 CPU 排序
M    按内存排序
1    显示每个 CPU 核心
k    杀进程
q    退出
```

重点看：

```text
load average
%Cpu(s)
MiB Mem
MiB Swap
```

CPU 字段含义：

```text
us    用户态 CPU，应用程序计算消耗
sy    内核态 CPU，系统调用、内核操作消耗
id    idle，CPU 空闲比例
wa    iowait，等待 IO 的时间
```

判断方式：

```text
us 高：应用程序本身计算多
sy 高：系统调用或内核操作多
wa 高：磁盘 IO 可能慢
id 低：CPU 忙
```

---

### 2.3 查看 CPU 和负载

```bash
uptime
```

输出中的：

```text
load average: 1分钟, 5分钟, 15分钟
```

判断方法：

```text
如果机器有 4 个 CPU 核心：
load < 4      压力正常
load ≈ 4      接近满载
load > 4      有任务在排队
load 远大于 4 系统压力较大
```

查看 CPU 信息：

```bash
lscpu
```

重点看：

```text
CPU(s)
Core(s) per socket
Thread(s) per core
Model name
```

---

### 2.4 查看内存

```bash
free -h
```

重点字段：

```text
total        总内存
used         已使用内存
free         完全空闲内存
buff/cache   Linux 用作缓存的内存
available    估算还能给程序使用的内存
Swap         交换分区使用情况
```

重点：不要只看 `free`，更应该看 `available`。

原因：Linux 会尽量把空闲内存用于文件缓存，这部分在需要时可以释放给程序使用。

判断内存是否紧张：

```text
available 很低：内存可能紧张
Swap 使用很多：物理内存可能不够
```

---

### 2.5 查看 swap 和系统压力

```bash
vmstat 1
```

每 1 秒输出一次系统状态。

重点字段：

```text
r     等待 CPU 的进程数
b     等待 IO 的进程数
swpd  已使用 swap 大小
free  空闲内存
si    swap in，从磁盘换回内存
so    swap out，从内存换到磁盘
us    用户态 CPU
sy    内核态 CPU
id    CPU 空闲比例
wa    IO 等待比例
```

判断方式：

```text
r 长期大于 CPU 核心数：CPU 压力较大
si/so 长期不为 0：系统正在频繁换页，内存紧张
wa 很高：可能是磁盘 IO 瓶颈
id 很低：CPU 很忙
```

---

### 2.6 查看单个进程详情

```bash
cat /proc/<PID>/status
```

重点字段：

```text
Name      进程名
State     进程状态
VmSize    虚拟内存大小
VmRSS     实际占用物理内存
VmData    数据段、堆等大小
VmStk     栈大小
Threads   线程数量
```

例子：

```text
VmSize:  1000000 kB
VmRSS:     80000 kB
```

含义：

```text
进程拥有或映射了约 1GB 虚拟地址空间，
但实际占用的物理内存约 80MB。
```

---

## 3. ps aux 输出字段解释

示例命令：

```bash
ps aux --sort=-%mem | head
```

输出列：

```text
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
```

字段解释：

```text
USER     谁启动的进程
PID      进程 ID
%CPU     当前 CPU 使用率
%MEM     占总内存比例
VSZ      虚拟内存大小，单位 KB
RSS      实际占用物理内存，单位 KB
TTY      关联终端，? 表示没有终端
STAT     进程状态
START    启动时间
TIME     累计 CPU 时间
COMMAND  启动命令
```

最重要字段：

```text
PID
%CPU
%MEM
VSZ
RSS
STAT
COMMAND
```

---

## 4. 当前输出分析示例

用户执行：

```bash
ps aux --sort=-%mem | head
```

看到内存占用最高的进程主要是：

```text
/opt/eset/efs/lib/scand          安全/杀毒扫描服务
/proc/self/exe --type=renderer   miwork 或 Chromium 类渲染进程
/opt/google/chrome/chrome        Chrome 渲染进程
/opt/miwork/miwork/miwork        miwork 后台服务
```

大致内存占用：

```text
ESET scand                    RSS ≈ 990 MB
miwork renderer               RSS ≈ 928 MB
miwork JSRuntimeService       RSS ≈ 822 MB
Chrome renderer               RSS ≈ 813 MB
Chrome renderer               RSS ≈ 660 MB
miwork backend                RSS ≈ 590 MB
Chrome renderer               RSS ≈ 572 MB
miwork renderer               RSS ≈ 544 MB
Chrome renderer               RSS ≈ 511 MB
```

结论：

```text
当前内存占用最高的主要是：
1. 安全/杀毒服务
2. Chrome 多进程
3. miwork 企业办公软件
```

这些进程单个占用数百 MB 到约 1GB RSS，对现代桌面环境比较常见。

---

## 5. 为什么 VSZ 很大但 RSS 较小

示例：

```text
VSZ = 1215623332 KB
RSS = 950564 KB
```

换算：

```text
VSZ ≈ 1159 GB
RSS ≈ 928 MB
```

这不代表进程真的用了 1159GB 内存。

原因是 Chrome、Electron、Chromium 类程序会映射大量虚拟地址空间，例如：

```text
V8 引擎地址空间
沙箱地址空间
共享库
mmap 文件映射
预留堆地址空间
GPU/渲染相关映射
共享内存
```

关键区别：

```text
VSZ = 虚拟地址空间大小
RSS = 当前实际驻留在物理内存中的大小
```

判断真实内存压力时，优先看：

```text
RSS
```

不要只看：

```text
VSZ
```

---

## 6. STAT 进程状态解释

常见状态：

```text
R    running，正在运行或等待 CPU
S    sleeping，可中断睡眠，等待事件
D    不可中断睡眠，通常在等待 IO
Z    zombie，僵尸进程
T    stopped，暂停
I    idle，内核空闲线程
```

附加标记：

```text
l    多线程进程
L    有页面被锁在内存中
<    高优先级
N    低优先级
s    session leader
+    前台进程组
```

例如：

```text
Sl
```

表示：

```text
S = 睡眠中
l = 多线程
```

例如：

```text
SLl
```

表示：

```text
S = 睡眠中
L = 有页面被锁在内存中
l = 多线程
```

Chrome、miwork、安全软件出现 `Sl` 或 `SLl` 并不奇怪。

---

## 7. 物理内存是什么

物理内存就是机器上真实存在的内存条 RAM。

例如：

```text
电脑有 16GB RAM
```

这 16GB 就是物理内存。

CPU 最终真正访问的数据，必须在物理内存中。磁盘上的程序、文件、数据，需要加载到内存后，CPU 才能高效访问。

---

## 8. 虚拟内存是什么

虚拟内存是操作系统提供给每个进程的一套独立地址空间。

每个进程看到的是自己的虚拟地址，例如：

```text
0x00000000 到 0x7fffffffffff
```

但这些地址不一定直接对应真实内存条上的地址。

真正访问时，会经过：

```text
虚拟地址 -> 页表 -> 物理地址 -> 真实 RAM
```

也就是说：

```text
进程使用虚拟地址
内存条使用物理地址
页表负责建立映射
```

---

## 9. 虚拟内存为什么存在

### 9.1 进程隔离

进程 A 不能随便访问进程 B 的内存。

这样一个程序崩溃时，不会随便破坏其他程序的数据。

### 9.2 简化程序运行

每个程序都可以认为自己拥有一大片连续地址空间，不需要关心真实物理内存在哪里。

### 9.3 按需分配

程序申请或映射了很大的虚拟地址空间，不代表系统立刻分配同样大小的物理内存。

只有真正访问某些页面时，操作系统才可能分配物理页。

### 9.4 支持 mmap 和共享库

动态库、文件映射、共享内存都依赖虚拟内存机制。

### 9.5 支持 swap

物理内存不够时，操作系统可以把暂时不用的内存页换到磁盘上的 swap 区域。

---

## 10. 虚拟地址到物理地址的过程

简化流程：

```text
进程访问虚拟地址
        |
        v
CPU 的 MMU 查询页表
        |
        v
找到对应物理地址
        |
        v
访问真实物理内存 RAM
```

如果访问的虚拟地址还没有对应物理页：

```text
触发缺页异常 page fault
        |
        v
操作系统处理
        |
        v
分配物理页或从磁盘加载数据
        |
        v
建立页表映射
        |
        v
程序继续运行
```

缺页异常不一定是错误。很多时候它是正常的按需分配机制。

---

## 11. 常见判断模板

机器变慢时，按这个顺序排查。

### 11.1 看整体负载

```bash
uptime
```

看 `load average` 是否长期超过 CPU 核心数。

### 11.2 看 CPU 是否打满

```bash
top
```

进入后按：

```text
1
P
```

观察每个 CPU 核心和 CPU 占用最高的进程。

### 11.3 找 CPU 高的进程

```bash
ps aux --sort=-%cpu | head
```

### 11.4 找内存高的进程

```bash
ps aux --sort=-%mem | head
```

### 11.5 看内存是否紧张

```bash
free -h
```

重点看：

```text
available
Swap
```

### 11.6 看是否频繁 swap 或 IO 等待

```bash
vmstat 1
```

重点看：

```text
si
so
wa
r
```

### 11.7 看单个进程详情

```bash
cat /proc/<PID>/status
```

重点看：

```text
VmSize
VmRSS
Threads
State
```

---

## 12. 最小练习

依次执行：

```bash
lscpu
free -h
uptime
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head
vmstat 1
```

选择一个 PID：

```bash
cat /proc/<PID>/status
```

观察：

```text
VmSize
VmRSS
Threads
State
```

---

## 13. 掌握标准

能回答下面问题，说明已经入门掌握。

1. `ps aux` 中 `VSZ` 和 `RSS` 有什么区别？
2. 为什么 Chrome 进程的 `VSZ` 可能特别大？
3. 判断真实内存占用应该优先看 `VSZ` 还是 `RSS`？
4. `free -h` 里为什么不能只看 `free`？
5. `available` 和 `free` 有什么区别？
6. `vmstat` 中 `si` 和 `so` 长期不为 0 说明什么？
7. `top` 中 `%us`、`%sy`、`%wa`、`%id` 分别代表什么？
8. `load average` 和 CPU 核心数有什么关系？
9. 什么是物理内存？
10. 什么是虚拟内存？
11. 页表的作用是什么？
12. 什么是缺页异常？

---

## 14. 一句话总结

```text
物理内存是真实 RAM，虚拟内存是进程看到的地址空间。
VSZ 表示虚拟地址空间大小，RSS 表示实际占用的物理内存。
排查系统性能时，先看 uptime/top，再看 ps/free/vmstat，最后看 /proc/<PID>/status。
```

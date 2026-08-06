---
title: IPC
date: 2026-08-04 19:43:05
tags: [C++,IPC]
categories: Docs
top_img: /img/img1.png
cover: /img/img1.png
---

# IPC-进程间通信

> 当前已学：Pipe、双向 Pipe、FIFO、Signal、Unix Domain Socket、TCP Socket。

---

# 1. IPC 总览

IPC（Inter-Process Communication）是进程间通信机制，用来解决：

- 传数据
- 发通知
- 做同步
- 做本机或跨机器服务通信

## 常见分类

| 类型 | 代表机制 | 主要用途 |
|---|---|---|
| 字节流通信 | Pipe、FIFO、Unix Socket、TCP Socket | 传输连续数据 |
| 通知机制 | Signal | 进程事件通知 |
| 消息边界通信 | Message Queue | 以消息为单位通信 |
| 共享数据 | Shared Memory、mmap | 高性能数据共享 |
| 同步机制 | Semaphore、Mutex、Condition Variable | 保护共享资源 |

---

# 2. Pipe 匿名管道

## 2.1 Pipe 解决什么问题

Pipe 用于**有亲缘关系的进程通信**，最典型是父子进程。

一个 pipe 默认是**单向字节流**：

```text
write end -> kernel pipe buffer -> read end
```

创建后会得到两个 fd：

```cpp
int pipefd[2];
pipefd[0] // read end
pipefd[1] // write end
```

---

## 2.2 Pipe 的最小模型

流程：

```text
父进程创建 pipe
父进程 fork 子进程

子进程：关闭写端，从读端 read
父进程：关闭读端，从写端 write
```

重点：Pipe 是**内核缓冲区**，不是父子共享变量。

---

## 2.3 为什么要关闭不用的端

`fork()` 后，父子进程都会继承 pipe 的读端和写端：

```text
父进程：读端 + 写端
子进程：读端 + 写端
```

如果本节只需要父写子读，就应该关闭不用的端：

```cpp
// 子进程只读，关闭写端
close(pipefd[1]);

// 父进程只写，关闭读端
close(pipefd[0]);
```

`read()` 的阻塞规则：

```text
管道有数据：read 返回读到的字节数
管道没数据，但还有写端存在：read 阻塞等待
管道没数据，并且所有写端都关闭：read 返回 0，表示 EOF
```

记忆：

```text
读者关闭写端，写者关闭读端。
```

---

## 2.4 Pipe 的阻塞行为

```text
read：
  有数据 -> 返回数据
  没数据但还有写端 -> 阻塞
  没数据且所有写端关闭 -> 返回 0

write：
  缓冲区有空间 -> 写入数据
  缓冲区满 -> 可能阻塞
  所有读端关闭 -> 触发 SIGPIPE 或返回 -1
```

---

## 2.5 Pipe 相关 API

### pipe

```cpp
int pipe(int pipefd[2]);
```

作用：创建匿名管道。

返回值：

- 成功：0
- 失败：-1

特点：

- 单向通信
- 字节流
- 通常用于父子进程
- 数据经过内核缓冲区
- 没有消息边界

---

### write

```cpp
ssize_t write(int fd, const void* buf, size_t count);
```

作用：向文件描述符写数据。

参数：

- `fd`：写入哪个 fd
- `buf`：数据地址
- `count`：最多写多少字节

返回值：

- `> 0`：实际写入字节数
- `-1`：失败

注意：

- `strlen(msg)` 不包含 `\0`
- 大数据写入时要考虑循环写

---

### read

```cpp
ssize_t read(int fd, void* buf, size_t count);
```

作用：从 fd 读取数据。

返回值：

- `> 0`：实际读到的字节数
- `= 0`：EOF，所有写端关闭
- `-1`：失败

常见写法：

```cpp
char buffer[128] = {0};
ssize_t n = read(pipefd[0], buffer, sizeof(buffer) - 1);
if (n > 0) {
    buffer[n] = '\0';
}
```

为什么是 `sizeof(buffer) - 1`：

```text
给字符串结尾 '\0' 留位置
```

---

### wait

```cpp
pid_t wait(int* status);
```

作用：父进程等待任意子进程结束并回收资源。

示例：

```cpp
wait(nullptr);
```

含义：

- 等待子进程结束
- 不关心退出状态

不 `wait` 可能导致僵尸进程。

---

## 2.6 单向 Pipe 示例

文件：

```text
IPC/Pipe/pipe_01_basic.cpp
```

功能：

```text
父进程发送字符串
子进程读取并打印
父进程 wait 回收子进程
```

---

## 2.7 双向 Pipe

一个 pipe 只能单向，双向通信需要两个 pipe：

```cpp
int parent_to_child[2];
int child_to_parent[2];
```

通信模型：

```text
父进程 write parent_to_child[1]
子进程 read  parent_to_child[0]

子进程 write child_to_parent[1]
父进程 read  child_to_parent[0]
```

### fd 关闭规则

```cpp
// parent_to_child
close(parent_to_child[0]); // 父进程关读端
close(parent_to_child[1]); // 子进程关写端

// child_to_parent
close(child_to_parent[1]); // 父进程关写端
close(child_to_parent[0]); // 子进程关读端
```

### 关键注意

父子进程读写顺序必须配合，否则可能死锁。

---

## 2.8 双向 Pipe 示例

文件：

```text
IPC/Pipe/pipe_02_bidirectional.cpp
```

功能：

```text
父进程发 hello child
子进程转成大写后返回
父进程打印返回值
```

---

# 3. FIFO / Named Pipe 命名管道

## 3.1 FIFO 解决什么问题

Pipe 通常用于有亲缘关系的进程。

FIFO 用于**无亲缘关系的两个进程通信**。

FIFO 会在文件系统中创建一个路径，例如：

```text
/tmp/cpp_ipc_fifo
```

通信模型：

```text
writer write -> kernel pipe buffer -> reader read
```

注意：FIFO 有路径，但不是普通文件，不保存普通文件内容。它只是进入内核管道缓冲区的入口。

---

## 3.2 FIFO 和 Pipe 的区别

| 对比 | Pipe | FIFO |
|---|---|---|
| 是否有名字 | 没有 | 有路径 |
| 是否要求父子关系 | 通常需要 | 不需要 |
| 数据模型 | 字节流 | 字节流 |
| 是否经过内核 | 是 | 是 |
| 是否保存普通文件内容 | 否 | 否 |

---

## 3.3 FIFO 使用流程

reader：

```text
mkfifo
open(path, O_RDONLY)
read
close
unlink
```

writer：

```text
open(path, O_WRONLY)
write
close
```

也可以由单独初始化程序提前 `mkfifo`，reader 和 writer 都只负责 `open`。

---

## 3.4 FIFO 是否只需要创建一次

FIFO 只需要创建一次：

```cpp
mkfifo("/tmp/cpp_ipc_fifo", 0666);
```

如果路径已存在，再次创建会失败，`errno == EEXIST`。

writer 可以不创建 FIFO，直接 `open()`，前提是 FIFO 路径已经存在。

---

## 3.5 FIFO 的阻塞规则

| 操作 | 对端不存在 | 默认行为 |
|---|---|---|
| `open(path, O_RDONLY)` | 没有 writer | 阻塞 |
| `open(path, O_WRONLY)` | 没有 reader | 阻塞 |
| `read(fd, ...)` | 没有数据但 writer 还在 | 阻塞 |
| `read(fd, ...)` | writer 全部关闭 | 返回 0 |
| `write(fd, ...)` | reader 全部关闭 | 触发 SIGPIPE 或返回 -1 |

---

## 3.6 FIFO 相关 API

### mkfifo

```cpp
int mkfifo(const char* pathname, mode_t mode);
```

作用：创建 FIFO 文件。

---

### open

```cpp
int open(const char* pathname, int flags);
```

作用：打开 FIFO，获取 fd。

---

### read / write / close / unlink

这几个 API 和普通文件、Pipe 的语义一致：

- `read()`：读数据
- `write()`：写数据
- `close()`：关闭当前进程的 fd
- `unlink()`：删除 FIFO 路径

---

## 3.7 FIFO 示例

文件：

```text
IPC/FIFO/fifo_reader.cpp
IPC/FIFO/fifo_writer.cpp
```

功能：

```text
reader 创建并打开 FIFO
writer 打开 FIFO 并写入消息
reader 读取并打印消息
```

---

# 4. Signal 信号

## 4.1 Signal 解决什么问题

Signal 用来给进程发送异步通知。

它不是主要用来传输数据，而是通知进程发生了某件事：

```text
退出进程
重新加载配置
用户按 Ctrl+C
子进程退出通知父进程
```

---

## 4.2 常见 Signal

| 信号 | 含义 |
|---|---|
| SIGINT | 用户按 Ctrl+C |
| SIGTERM | 请求进程正常退出 |
| SIGKILL | 强制杀死进程，不能捕获、不能忽略 |
| SIGUSR1 | 用户自定义信号 1，常用于 reload |
| SIGUSR2 | 用户自定义信号 2 |
| SIGCHLD | 子进程退出时通知父进程 |
| SIGPIPE | 向已关闭读端的 pipe/socket 写数据 |
| SIGSTOP | 暂停进程，不能捕获、不能忽略 |

---

## 4.3 Signal 的特点

```text
1. 异步通知
2. 传输信息很少
3. 不适合传复杂数据
4. 可以打断进程当前执行流
5. 某些信号可以捕获，某些不能捕获
```

不能捕获、不能忽略的典型信号：

```text
SIGKILL
SIGSTOP
```

---

## 4.4 Signal 处理原则

信号处理函数是异步执行的，因此 handler 里不要做复杂事情。

不建议在 handler 中直接做：

```text
std::cout
malloc / new
lock mutex
复杂业务逻辑
```

推荐做法：

```text
handler 中只修改简单标志位
主循环中检查标志位并执行真正逻辑
```

---

## 4.5 Signal 相关 API

### sigaction

```cpp
int sigaction(int signum, const struct sigaction* act, struct sigaction* oldact);
```

作用：为指定信号注册处理方式。

---

### struct sigaction

常用字段：

- `sa_handler`：普通处理函数
- `sa_mask`：处理当前信号时额外屏蔽的信号集
- `sa_flags`：标志位

常见标志：

- `SA_RESTART`：部分系统调用自动重启
- `SA_SIGINFO`：使用更详细的信号信息

---

### sigemptyset

```cpp
int sigemptyset(sigset_t* set);
```

作用：初始化空信号集。

---

### kill

```cpp
int kill(pid_t pid, int sig);
```

作用：向指定进程发送信号。

命令行也可以：

```bash
kill -USR1 <pid>
kill -TERM <pid>
```

---

### getpid

```cpp
pid_t getpid(void);
```

作用：获取当前进程 pid。

---

## 4.6 Signal 示例

文件：

```text
IPC/Signal/signal_01_basic.cpp
```

功能：

```text
程序持续运行
收到 SIGUSR1：设置 reload 标志
收到 SIGTERM：优雅退出
收到 SIGINT：优雅退出
```

---

# 5. Unix Domain Socket

## 5.1 Unix Domain Socket 解决什么问题

Unix Domain Socket 用来实现本机进程之间的客户端/服务端通信。

典型模型：

```text
client 发送请求
server 接收请求
server 返回响应
```

常见用途：

```text
本机 daemon 通信
本机 agent/service 通信
数据库本地 socket
Docker daemon 风格服务
```

---

## 5.2 Unix Socket 和 TCP Socket 的区别

| 对比 | Unix Domain Socket | TCP Socket |
|---|---|---|
| 地址类型 | 文件路径 | IP + Port |
| 通信范围 | 本机 | 本机或跨机器 |
| 协议族 | AF_UNIX | AF_INET / AF_INET6 |
| 性能 | 通常更高 | 通常略低 |
| 权限控制 | 文件权限 | 网络、防火墙、认证 |
| 典型用途 | 本机 IPC | 网络通信 |

---

## 5.3 通信模型

```text
client connect -> server accept
client send    -> server recv
server send    -> client recv
```

server 端有两个重要 fd：

```text
server_fd：监听 fd，用于 bind/listen/accept
client_fd：通信 fd，由 accept 返回，用于 recv/send
```

真正和客户端收发数据的是 `client_fd`，不是 `server_fd`。

---

## 5.4 为什么需要 unlink

Unix Domain Socket 绑定的是文件系统路径，例如：

```text
/tmp/cpp_ipc_socket
```

如果上一次 server 异常退出，这个路径可能还存在。再次 `bind` 同一路径会失败：

```text
Address already in use
```

所以 server 启动前通常先：

```cpp
unlink(socket_path);
```

退出时也应该清理。

---

## 5.5 Unix Socket 的数据模型

本节使用：

```cpp
SOCK_STREAM
```

它是面向连接的字节流，类似 TCP。

特点：

```text
1. 可靠、有序
2. 面向连接
3. 没有消息边界
```

工程中通常需要自己设计协议：

```text
长度 + 数据
分隔符 + 数据
固定长度消息
```

---

## 5.6 Unix Socket 相关 API

### socket

```cpp
int socket(int domain, int type, int protocol);
```

Unix Domain Socket 常用：

```cpp
socket(AF_UNIX, SOCK_STREAM, 0);
```

---

### sockaddr_un

```cpp
sockaddr_un addr{};
addr.sun_family = AF_UNIX;
std::strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path) - 1);
```

---

### bind

```cpp
int bind(int sockfd, const struct sockaddr* addr, socklen_t addrlen);
```

作用：server 把 socket fd 绑定到一个地址。

---

### listen

```cpp
int listen(int sockfd, int backlog);
```

作用：让 server socket 进入监听状态。

---

### accept

```cpp
int accept(int sockfd, struct sockaddr* addr, socklen_t* addrlen);
```

作用：server 接受一个 client 连接，返回 `client_fd`。

---

### connect

```cpp
int connect(int sockfd, const struct sockaddr* addr, socklen_t addrlen);
```

作用：client 连接 server 的 socket 地址。

---

### send / recv

```cpp
ssize_t send(int sockfd, const void* buf, size_t len, int flags);
ssize_t recv(int sockfd, void* buf, size_t len, int flags);
```

flags 入门阶段填 `0`。

常见 flag：

- `MSG_PEEK`
- `MSG_DONTWAIT`
- `MSG_WAITALL`

---

### close

```cpp
int close(int fd);
```

作用：关闭 socket fd。

---

## 5.7 Unix Socket 示例

文件：

```text
IPC/UnixSocket/unix_server.cpp
IPC/UnixSocket/unix_client.cpp
```

功能：

```text
server 创建 Unix Domain Socket 并监听
client 连接 server 并发送消息
server 接收消息后 echo 回 client
client 接收并打印返回消息
```

---

# 6. TCP Socket

## 6.1 TCP 解决什么问题

当两个进程不在同一台机器上时，需要通过网络通信，这时使用 TCP Socket。

典型场景：

```text
Web 服务
微服务
RPC
数据库连接
分布式系统
```

---

## 6.2 TCP 的特点

```text
1. 面向连接
2. 可靠传输
3. 有序
4. 字节流
5. 没有消息边界
```

TCP 也是字节流，不是天然消息协议。

---

## 6.3 TCP 和 Unix Socket 的关系

| 对比 | Unix Socket | TCP Socket |
|---|---|---|
| 地址 | 文件路径 | IP + Port |
| 范围 | 本机 | 本机或跨机器 |
| 协议族 | AF_UNIX | AF_INET / AF_INET6 |
| 数据模型 | 字节流 | 字节流 |
| 是否有消息边界 | 否 | 否 |
| 典型用途 | 本机 IPC | 网络通信 |

共同骨架：

```text
client connect -> server accept
client send    -> server recv
server send    -> client recv
```

---

## 6.4 TCP 相关 API

### socket

```cpp
int socket(int domain, int type, int protocol);
```

TCP 常用：

```cpp
socket(AF_INET, SOCK_STREAM, 0);
```

---

### sockaddr_in

```cpp
sockaddr_in addr{};
addr.sin_family = AF_INET;
addr.sin_port = htons(5555);
addr.sin_addr.s_addr = htonl(INADDR_ANY);
```

---

### inet_pton

```cpp
inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);
```

作用：把字符串 IP 转成二进制地址。

---

### htons / htonl

- `htons`：16 位主机序转网络序
- `htonl`：32 位主机序转网络序

例如：

```cpp
addr.sin_port = htons(5555);
addr.sin_addr.s_addr = htonl(INADDR_ANY);
```

---

### bind / listen / accept / connect / send / recv / close

和 Unix Socket 语义类似，只是地址改成了 IP + Port。

重点：

```text
accept() 前必须 listen()
```

否则会报错。

---

## 6.5 TCP 示例

文件：

```text
IPC/TCP/tcp_server.cpp
IPC/TCP/tcp_client.cpp
```

功能：

```text
client 发消息
server 收到后原样返回
client 打印返回值
```

---

## 6.6 TCP 已学重点

### listen/backlog

`listen(server_fd, backlog)` 把 socket 变成监听 socket。

`backlog` 是等待 accept 的连接队列长度提示。

---

### accept 前必须 listen

TCP server 的顺序必须是：

```text
socket -> bind -> listen -> accept
```

---

### TCP 也是字节流

TCP 没有消息边界。

所以工程中通常需要自定义协议：

```text
长度 + 数据
分隔符 + 数据
固定长度消息
```

---

## 6.7 TCP 输出格式小问题

输出时建议在冒号后加空格：

```cpp
std::cout << "Server received: " << buffer << std::endl;
```

这只是显示格式，不影响功能。

---

# 7. TCP 进阶：半关闭、长连接、短连接、粘包

## 7.1 TCP 半关闭

半关闭就是：

```text
一方不再发送数据了，但还可以继续接收数据
```

常用 API：

```cpp
int shutdown(int sockfd, int how);
```

`how` 的值：

- `SHUT_RD`：关闭读
- `SHUT_WR`：关闭写
- `SHUT_RDWR`：读写都关

最常用的是：

```cpp
shutdown(sockfd, SHUT_WR);
```

含义：我不再发数据了，但还能继续收。

---

## 7.2 长连接和短连接

### 短连接

```text
建立连接 -> 发送一次请求 -> 接收一次响应 -> 关闭连接
```

特点：简单，但建连开销大。

---

### 长连接

```text
建立一次连接 -> 多次请求响应 -> 最后再关闭
```

特点：复用连接，适合高频通信，但需要维护连接状态、心跳、超时等。

---

## 7.3 TCP 粘包 / 拆包

TCP 是字节流，没有消息边界，所以接收端可能：

- 一次 recv 收到半条消息
- 一次 recv 收到多条消息
- 多次 recv 才拼成一条消息

这是正常现象。

---

## 7.4 长度协议

最常用协议格式：

```text
[4字节长度][正文数据]
```

发送端：

```cpp
uint32_t len = msg.size();
uint32_t net_len = htonl(len);
send_all(fd, &net_len, 4);
send_all(fd, msg.data(), len);
```

接收端：

```cpp
uint32_t net_len;
recv_all(fd, &net_len, 4);
uint32_t len = ntohl(net_len);
recv_all(fd, buffer, len);
```

配套要写：

- `send_all()`：保证发完
- `recv_all()`：保证收满

---

# 8. mmap 内存映射

## 8.1 mmap 解决什么问题

`mmap` 用来把文件或匿名内存映射到进程地址空间。

映射后，程序可以像访问普通内存一样访问文件内容或共享区域。

常见用途：

```text
高性能文件读写
大文件随机访问
共享内存
数据库缓存
```

---

## 8.2 mmap 的两种常见模式

### 文件映射

```text
文件 -> 进程虚拟地址空间
```

适合：读写文件、随机访问文件。

---

### 匿名映射

```text
不关联具体文件，只创建一块映射内存
```

如果配合 `MAP_SHARED` 和 `fork()`，可以让父子进程共享这块内存。

---

## 8.3 mmap 相关 API

### mmap

头文件：

```cpp
#include <sys/mman.h>
```

函数原型：

```cpp
void* mmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset);
```

参数：

```text
addr    一般传 nullptr，让内核选择映射地址
length  映射长度
prot    访问权限
flags   映射类型
fd      文件描述符，匿名映射时通常传 -1
offset  文件偏移，入门阶段传 0
```

返回值：

```text
成功：映射起始地址
失败：MAP_FAILED
```

---

### prot 常用值

```text
PROT_READ   可读
PROT_WRITE  可写
PROT_EXEC   可执行
PROT_NONE   不允许访问
```

常用组合：

```cpp
PROT_READ | PROT_WRITE
```

---

### flags 常用值

```text
MAP_SHARED    共享映射，修改会反映到底层文件或共享区域
MAP_PRIVATE   私有映射，写时复制，不影响原文件
MAP_ANONYMOUS 匿名映射，不关联文件
```

---

### ftruncate

头文件：

```cpp
#include <unistd.h>
```

函数原型：

```cpp
int ftruncate(int fd, off_t length);
```

作用：调整文件大小。

在文件映射写入前，通常先把文件扩展到足够大：

```cpp
ftruncate(fd, 4096);
```

原因：`mmap` 需要映射一块实际存在的文件区域，文件太小会导致写入风险。

---

### msync

头文件：

```cpp
#include <sys/mman.h>
```

函数原型：

```cpp
int msync(void* addr, size_t length, int flags);
```

作用：把映射内存中的修改同步回文件。

常用：

```cpp
msync(addr, len, MS_SYNC);
```

说明：

```text
不调用 msync，内核通常也会在合适时机回写。
学习阶段显式调用更容易理解。
```

---

### munmap

头文件：

```cpp
#include <sys/mman.h>
```

函数原型：

```cpp
int munmap(void* addr, size_t length);
```

作用：取消映射，释放虚拟地址空间中的映射关系。

---

## 8.4 文件映射写入流程

```text
open 文件
ftruncate 扩展文件大小
mmap 创建映射
memcpy 写映射内存
msync 同步回文件
munmap 取消映射
close 关闭 fd
```

示例文件：

```text
IPC/MMap/mmap_write.cpp
```

核心理解：

```text
memcpy 写的是映射内存，但由于 MAP_SHARED，修改会反映到底层文件。
```

---

## 8.5 文件映射读取流程

```text
open 文件
fstat 获取文件大小
mmap 创建只读映射
按 char* 读取映射内存
munmap 取消映射
close 关闭 fd
```

示例文件：

```text
IPC/MMap/mmap_read.cpp
```

核心理解：

```text
addr 是映射出来的内存地址，可以像普通内存一样读取。
```

---

## 8.6 匿名 mmap

匿名 mmap 不关联具体文件，只创建一块映射内存。

典型写法：

```cpp
void* addr = mmap(
    nullptr,
    len,
    PROT_READ | PROT_WRITE,
    MAP_SHARED | MAP_ANONYMOUS,
    -1,
    0
);
```

关键参数：

```text
MAP_ANONYMOUS：不关联文件
MAP_SHARED：共享映射
fd = -1：没有文件 fd
offset = 0：匿名映射不需要文件偏移
```

如果在 `fork()` 之前创建匿名共享映射，父子进程会继承这块映射区域。

因为使用了 `MAP_SHARED`，所以父子进程看到的是同一块内存。

通信模型：

```text
父进程 mmap 创建共享内存
fork 子进程
子进程写 addr
父进程读 addr
```

注意：匿名 mmap 更适合有亲缘关系的进程。无亲缘关系进程共享内存通常使用 POSIX Shared Memory，也就是后面要学的 `shm_open`。

---

## 8.7 普通变量 fork 和匿名 mmap 的区别

### 普通变量

```text
父进程 value = 100
fork 后子进程 value = 100
子进程改成 200
父进程仍然看到 100
```

原因：`fork()` 后父子进程地址空间独立，普通变量不是共享的。

---

### MAP_SHARED | MAP_ANONYMOUS

```text
父进程 shared_value = 100
fork 后子进程 shared_value = 100
子进程改成 200
父进程看到 200
```

原因：父子进程共享同一块 mmap 区域。

---

## 8.8 共享内存不等于同步

匿名 mmap 只解决数据共享，不解决同步问题。

它不负责处理：

```text
谁先读
谁先写
写到一半能不能读
多个进程同时写怎么办
```

所以共享内存通常要配合：

```text
semaphore
mutex
condition variable
atomic
```

---

## 8.9 mmap 和 read/write 的区别

| 对比 | read/write | mmap |
|---|---|---|
| 数据访问方式 | 系统调用读写 | 像访问内存一样访问 |
| 编程方式 | 显式 read/write | 直接操作指针 |
| 适合场景 | 普通文件 I/O | 大文件、随机访问、共享内存 |
| 是否有映射关系 | 否 | 是 |

---

## 8.10 mmap 当前已完成 demo

文件：

```text
IPC/MMap/mmap_write.cpp
IPC/MMap/mmap_read.cpp
IPC/MMap/mmap_anonymous.cpp
```

运行顺序：

```bash
./mmap_write
./mmap_read
```

预期结果：

```text
write done
file content: hello mmap
```

---

# 9. POSIX Shared Memory

## 9.1 POSIX Shared Memory 解决什么问题

匿名 mmap 适合父子进程，因为共享映射区域通常依赖 `fork()` 继承。

如果两个进程没有父子关系，也想共享同一块内存，可以使用 POSIX Shared Memory。

核心 API：

```cpp
shm_open()
```

---

## 9.2 通信模型

两个无亲缘关系的进程使用同一个共享内存名字：

```text
/cpp_ipc_shm
```

writer：

```text
shm_open
ftruncate
mmap
写共享内存
munmap
close
```

reader：

```text
shm_open
mmap
读共享内存
munmap
close
shm_unlink
```

底层理解：

```text
shm_open 创建或打开共享内存对象
mmap 把共享内存对象映射到进程地址空间
两个进程 mmap 同一个对象后，就能看到同一块内存
```

---

## 9.3 POSIX Shared Memory 和 FIFO 的相似点

FIFO 有路径：

```text
/tmp/cpp_ipc_fifo
```

POSIX Shared Memory 有名字：

```text
/cpp_ipc_shm
```

两个进程只要使用同一个名字，就能打开同一个通信对象。

注意：POSIX Shared Memory 的名字一般以 `/` 开头。

---

## 9.4 POSIX Shared Memory 相关 API

### shm_open

头文件：

```cpp
#include <sys/mman.h>
#include <fcntl.h>
```

函数原型：

```cpp
int shm_open(const char* name, int oflag, mode_t mode);
```

作用：创建或打开 POSIX 共享内存对象。

示例：

```cpp
int fd = shm_open("/cpp_ipc_shm", O_CREAT | O_RDWR, 0666);
```

返回值：

```text
成功：fd
失败：-1
```

注意：

```text
name 必须以 / 开头。
```

---

### ftruncate

```cpp
int ftruncate(int fd, off_t length);
```

作用：设置共享内存对象大小。

刚创建的共享内存对象大小通常是 0，所以 writer 需要先：

```cpp
ftruncate(fd, 4096);
```

否则无法正常写入指定大小的数据。

---

### mmap

```cpp
void* mmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset);
```

作用：把共享内存对象映射到当前进程地址空间。

示例：

```cpp
void* addr = mmap(nullptr, 4096,
                  PROT_READ | PROT_WRITE,
                  MAP_SHARED,
                  fd,
                  0);
```

注意：这里不是 `MAP_ANONYMOUS`，因为共享内存对象由 `shm_open` 提供 fd。

---

### shm_unlink

头文件：

```cpp
#include <sys/mman.h>
```

函数原型：

```cpp
int shm_unlink(const char* name);
```

作用：删除 POSIX 共享内存对象的名字。

它类似 FIFO 的 `unlink()`，但删除的是共享内存对象名。

---

## 9.5 POSIX Shared Memory 和文件 mmap 的区别

| 对比 | 文件 mmap | POSIX Shared Memory |
|---|---|---|
| 底层对象 | 普通文件 | 共享内存对象 |
| 创建方式 | open 文件 | shm_open |
| 设置大小 | ftruncate | ftruncate |
| 映射方式 | mmap | mmap |
| 删除方式 | unlink 文件 | shm_unlink |
| 主要用途 | 文件读写/共享 | 进程间共享内存 |
| 是否适合无亲缘进程 | 可以，但偏文件语义 | 更适合 |

---

## 9.6 当前 demo

文件：

```text
IPC/SharedMemory/shm_writer.cpp
IPC/SharedMemory/shm_reader.cpp
```

运行顺序：

```bash
./shm_writer
./shm_reader
```

预期结果：

```text
Writer wrote: hello from posix shared memory
Reader read: hello from posix shared memory
```

注意：这个 demo 没有同步机制，所以必须先运行 writer，再运行 reader。

如果 reader 先运行，可能 `shm_open` 失败，也可能读到旧数据或空数据。

真正工程里要配合：

```text
Semaphore
Mutex
Condition Variable
```

---

# 10. Semaphore 信号量

## 10.1 Semaphore 解决什么问题

共享内存只解决数据共享，不解决同步。

Semaphore 用来解决：

```text
reader 怎么知道 writer 已经写完？
多个进程如何等待某个事件发生？
多个进程如何控制资源数量？
```

在 Shared Memory 场景里，最常见分工是：

```text
Shared Memory：存数据
Semaphore：通知数据已经准备好
```

---

## 10.2 Semaphore 的核心思想

Semaphore 可以理解成一个整数计数器。

两个核心操作：

```text
wait：计数 -1
post：计数 +1
```

POSIX API 对应：

```cpp
sem_wait()
sem_post()
```

---

## 10.3 sem_wait / sem_post 行为

### sem_wait

```cpp
sem_wait(sem);
```

含义：

```text
如果 semaphore > 0：
    semaphore - 1，然后继续执行

如果 semaphore == 0：
    阻塞等待
```

---

### sem_post

```cpp
sem_post(sem);
```

含义：

```text
semaphore + 1
如果有进程阻塞在 sem_wait，唤醒其中一个
```

---

## 10.4 Shared Memory + Semaphore 模型

reader：

```text
sem_wait
读共享内存
```

writer：

```text
写共享内存
sem_post
```

这样 reader 一定等 writer 写完后再读。

---

## 10.5 POSIX Named Semaphore

命名信号量有名字，例如：

```text
/cpp_ipc_sem
```

无亲缘关系的进程只要打开同一个名字，就能使用同一个 semaphore。

---

## 10.6 Semaphore 相关 API

### sem_open

头文件：

```cpp
#include <semaphore.h>
#include <fcntl.h>
```

函数原型：

```cpp
sem_t* sem_open(const char* name, int oflag, mode_t mode, unsigned int value);
```

作用：创建或打开命名信号量。

示例：

```cpp
sem_t* sem = sem_open("/cpp_ipc_sem", O_CREAT, 0666, 0);
```

最后的 `0` 表示初始计数为 0。

含义：

```text
reader 一开始 sem_wait 会阻塞
writer sem_post 后 reader 被唤醒
```

返回值：

```text
成功：sem_t* 指针
失败：SEM_FAILED
```

---

### sem_wait

```cpp
int sem_wait(sem_t* sem);
```

作用：等待信号量。

如果计数为 0，会阻塞。

---

### sem_post

```cpp
int sem_post(sem_t* sem);
```

作用：释放/通知信号量。

会把计数 +1，并唤醒等待者。

---

### sem_close

```cpp
int sem_close(sem_t* sem);
```

作用：关闭当前进程中的 semaphore 句柄。

注意：`sem_close` 不删除命名信号量。

---

### sem_unlink

```cpp
int sem_unlink(const char* name);
```

作用：删除命名 semaphore。

类似：

```text
unlink
shm_unlink
```

---

## 10.7 当前 demo

文件：

```text
IPC/Semaphore/shm_sem_writer.cpp
IPC/Semaphore/shm_sem_reader.cpp
```

运行顺序：

```bash
./shm_sem_reader
./shm_sem_writer
```

预期结果：

```text
Reader waiting...
Writer wrote: hello with semaphore
Reader read: hello with semaphore
```

---

## 10.8 为什么 reader 里也执行 ftruncate

你的 reader 代码里有：

```cpp
int fd = shm_open(shm_name, O_CREAT | O_RDWR, 0666);
ftruncate(fd, len);
```

这是为了支持 reader 先启动。

因为 reader 使用了 `O_CREAT`，如果共享内存对象不存在，reader 会负责创建它。

刚创建出来的共享内存对象大小是 0，所以必须执行：

```cpp
ftruncate(fd, len);
```

否则后续：

```cpp
mmap(nullptr, len, ...)
```

可能映射一个实际大小不足的对象，读写会有风险。

所以这个 demo 中 writer 和 reader 都写 `ftruncate`，是为了让任意一方先启动时，共享内存对象都有正确大小。

---

## 10.9 工程中是否 reader 必须 ftruncate

不一定。

如果工程约定：

```text
只有 writer 或初始化进程负责创建共享内存并设置大小
reader 只负责打开已经存在的共享内存
```

那么 reader 可以写成：

```cpp
int fd = shm_open(shm_name, O_RDONLY, 0666);
```

并且不执行 `ftruncate`。

但这种写法要求：

```text
writer 或初始化进程必须先启动
```

本节 demo 的目标是：

```text
reader 可以先启动，并阻塞等待 writer 写入
```

所以 reader 也使用：

```cpp
O_CREAT | O_RDWR
ftruncate(fd, len)
```

---

## 10.10 重要注意

Semaphore 不是用来传数据的。

```text
数据：Shared Memory
同步：Semaphore
```

初始值为什么是 0：

```cpp
sem_open(sem_name, O_CREAT, 0666, 0);
```

因为一开始没有数据，reader 应该阻塞等待。

writer 写完后：

```cpp
sem_post(sem);
```

reader 才能从：

```cpp
sem_wait(sem);
```

继续执行。

---

# 11. 进程间 Mutex / Condition Variable

## 11.1 为什么还需要 Mutex / Condition Variable

Semaphore 可以做同步，但当共享状态更复杂时，Mutex + Condition Variable 更适合。

典型场景：

```text
共享队列
生产者/消费者
多个字段要一起修改
多个进程互斥访问共享结构体
```

---

## 11.2 Mutex 解决什么

Mutex 解决的是：

```text
同一时刻只能有一个进程访问共享资源
```

例如共享内存里的结构体：

```cpp
struct SharedData {
    int ready;
    char message[256];
};
```

如果没有 mutex，writer 可能写到一半，reader 就读到了不完整数据。

---

## 11.3 Condition Variable 解决什么

Condition Variable 解决的是：

```text
等待某个条件成立
```

比如：

```text
reader 等待 ready == true
writer 写完后设置 ready = true 并通知 reader
```

这比 reader 不断轮询更高效。

---

## 11.4 进程间使用 Mutex / Cond 的前提

普通 pthread mutex/cond 默认是线程间使用。

如果要跨进程使用，必须：

```cpp
PTHREAD_PROCESS_SHARED
```

并且 mutex/cond 必须放在共享内存里。

否则每个进程各有一份锁，彼此无法同步。

---

## 11.5 共享数据结构

典型结构：

```cpp
struct SharedData {
    pthread_mutex_t mutex;
    pthread_cond_t cond;
    bool initialized;
    bool ready;
    char message[256];
};
```

这块结构体必须放在共享内存里，这样 producer 和 consumer 看到的是同一份数据。

---

## 11.6 关键 API

### pthread_mutexattr_setpshared

作用：设置 mutex 可以跨进程共享。

```cpp
pthread_mutexattr_setpshared(&mutex_attr, PTHREAD_PROCESS_SHARED);
```

---

### pthread_condattr_setpshared

作用：设置 condition variable 可以跨进程共享。

```cpp
pthread_condattr_setpshared(&cond_attr, PTHREAD_PROCESS_SHARED);
```

---

### pthread_mutex_lock / pthread_mutex_unlock

```cpp
pthread_mutex_lock(&data->mutex);
pthread_mutex_unlock(&data->mutex);
```

作用：保护共享数据，防止并发读写冲突。

---

### pthread_cond_wait

```cpp
pthread_cond_wait(&data->cond, &data->mutex);
```

作用：等待条件成立。

它会：

```text
1. 原子地释放 mutex
2. 阻塞等待 cond
3. 被唤醒后重新加锁 mutex
```

---

### pthread_cond_signal

```cpp
pthread_cond_signal(&data->cond);
```

作用：唤醒一个等待中的进程。

---

## 11.7 为什么 pthread_cond_wait 要放在 while 里

正确写法：

```cpp
while (!data->ready) {
    pthread_cond_wait(&data->cond, &data->mutex);
}
```

不要写成 `if`。

原因：

```text
1. 可能虚假唤醒
2. 被唤醒后条件可能已变化
3. 可能存在多个等待者竞争
```

---

## 11.8 当前 demo

文件：

```text
IPC/MutexCond/ipc_mutex_producer.cpp
IPC/MutexCond/ipc_mutex_consumer.cpp
```

运行顺序：

```bash
./ipc_mutex_consumer
./ipc_mutex_producer
```

预期结果：

```text
Consumer waiting...
Producer wrote: hello from producer
Consumer read: hello from producer
```

---

## 11.9 这份 demo 的初始化说明

这份 demo 允许 producer 或 consumer 任意一方先启动，所以两边都写了初始化逻辑：

```cpp
if (!data->initialized) {
    初始化 mutex
    初始化 cond
    data->ready = false
    data->initialized = true
}
```

这只是为了教学方便。

严格工程里通常会：

```text
1. 单独初始化程序负责创建和初始化共享对象
2. 或用 O_CREAT | O_EXCL 约定谁是创建者
```

---

## 11.10 Semaphore 和 Mutex/Cond 的区别

| 对比 | Semaphore | Mutex/Cond |
|---|---|---|
| 主要用途 | 计数、通知、同步 | 互斥、等待条件、复杂同步 |
| 是否适合共享结构体 | 可以配合 | 很适合 |
| 是否常用于队列 | 可以 | 很适合 |
| 使用复杂度 | 较低 | 略高 |

---

# 12. Message Queue 消息队列

## 12.1 Message Queue 解决什么问题

Message Queue 适合一条一条消息传递的场景。

它天然带有消息边界，所以不需要自己处理粘包/拆包。

适合：

```text
生产者/消费者
异步任务
事件通知
消息解耦
```

---

## 12.2 Message Queue 和前面机制的区别

### 和 Pipe / Socket 的区别

Pipe / Socket 是字节流，需要自己切包。

Message Queue 是消息模型，消息边界天然存在。

---

### 和 Shared Memory 的区别

Shared Memory 是共享一块内存，消息边界和同步要自己处理。

Message Queue 更像内核帮你维护的消息盒子。

---

## 12.3 POSIX Message Queue 相关 API

### mq_open

头文件：

```cpp
#include <mqueue.h>
#include <fcntl.h>
```

函数原型：

```cpp
mqd_t mq_open(const char* name, int oflag, mode_t mode, struct mq_attr* attr);
```

作用：创建或打开消息队列。

示例：

```cpp
mqd_t mq = mq_open("/cpp_ipc_mq", O_CREAT | O_RDWR, 0666, &attr);
```

注意：消息队列名字必须以 `/` 开头。

---

### mq_send

```cpp
int mq_send(mqd_t mqdes, const char* msg_ptr, size_t msg_len, unsigned int msg_prio);
```

作用：发送一条消息。

最后一个参数是消息优先级。

---

### mq_receive

```cpp
ssize_t mq_receive(mqd_t mqdes, char* msg_ptr, size_t msg_len, unsigned int* msg_prio);
```

作用：接收一条消息。

接收缓冲区大小必须大于等于消息队列的 `mq_msgsize`。

---

### mq_close / mq_unlink

```cpp
mq_close(mq);
mq_unlink("/cpp_ipc_mq");
```

作用：关闭当前句柄，或删除消息队列名字。

---

## 12.4 mq_attr

`mq_attr` 用来显式设置消息队列属性：

```cpp
struct mq_attr attr{};
attr.mq_flags = 0;
attr.mq_maxmsg = 10;
attr.mq_msgsize = 256;
attr.mq_curmsgs = 0;
```

含义：

```text
mq_flags   : 队列标志
mq_maxmsg  : 队列最多容纳多少条消息
mq_msgsize : 单条消息最大长度
mq_curmsgs : 当前消息条数
```

---

## 12.5 当前 demo

文件：

```text
IPC/MessageQueue/mq_sender.cpp
IPC/MessageQueue/mq_receiver.cpp
```

运行顺序：

```bash
./mq_receiver
./mq_sender
```

预期结果：

```text
Sender sent: hello from mq sender
Receiver got: hello from mq sender
Priority: 0
```

---

## 12.6 消息优先级 prio

`mq_receive` 的第四个参数：

```cpp
unsigned int* msg_prio
```

是用来返回这条消息的优先级。

例如：

```cpp
unsigned int prio = 0;
mq_receive(mq, buffer, sizeof(buffer), &prio);
```

如果发送时写：

```cpp
mq_send(mq, msg, len, 0);
```

那么收到的优先级一般就是 0。

优先级越高，队列中越先被取出。

---

## 12.7 你之前遇到的 Message too long

这个错误通常是因为：

```text
接收缓冲区大小 < mq_msgsize
```

所以我们在这版 demo 中显式设置：

```cpp
attr.mq_msgsize = 256;
char buffer[256] = {0};
```

让发送和接收双方大小一致。

---

# 13. I/O 多路复用：select / poll / epoll

## 13.1 I/O 多路复用解决什么问题

普通阻塞 TCP server 如果直接调用：

```cpp
accept(...);
recv(...);
```

一旦没有新连接或没有数据，程序就会阻塞。

如果服务器要同时管理很多客户端，就需要一种机制：

```text
同时等待多个 fd，哪个 fd 就绪了，就处理哪个 fd。
```

这就是 I/O 多路复用。

Linux 常见三种模型：

```text
select -> poll -> epoll
```

它们都只负责“等事件”，不负责真正读写数据。

真正读写仍然靠：

```text
accept / recv / send / read / write
```

---

## 13.2 select 模型

`select` 是较早的 I/O 多路复用 API。

核心思想：

```text
把要监听的 fd 放进 fd_set
调用 select 阻塞等待
select 返回后，遍历 fd_set，找出哪些 fd 就绪
```

常见 API：

```cpp
int select(int nfds,
           fd_set* readfds,
           fd_set* writefds,
           fd_set* exceptfds,
           struct timeval* timeout);
```

常用配套宏：

```cpp
FD_ZERO(&readfds);        // 清空 fd_set
FD_SET(fd, &readfds);     // 把 fd 加入集合
FD_ISSET(fd, &readfds);   // 判断 fd 是否就绪
FD_CLR(fd, &readfds);     // 从集合删除 fd
```

参数含义：

```text
nfds      最大 fd + 1
readfds   关心哪些 fd 可读
writefds  关心哪些 fd 可写
exceptfds 异常事件，入门阶段较少用
timeout   超时时间，nullptr 表示一直等
```

最小模型：

```cpp
fd_set readfds;
FD_ZERO(&readfds);
FD_SET(server_fd, &readfds);

int n = select(server_fd + 1, &readfds, nullptr, nullptr, nullptr);
if (n > 0 && FD_ISSET(server_fd, &readfds)) {
    int client_fd = accept(server_fd, nullptr, nullptr);
}
```

注意点：

```text
select 每次调用前都要重新设置 fd_set。
select 返回后会修改 fd_set，只保留就绪的 fd。
select 需要从 0 遍历到 max_fd，查找哪些 fd 就绪。
select 有 fd 数量上限，通常受 FD_SETSIZE 限制。
```

---

## 13.3 poll 模型

`poll` 是对 `select` 的改进。

它不再使用固定大小的 `fd_set`，而是使用数组：

```cpp
struct pollfd {
    int fd;
    short events;
    short revents;
};
```

常见 API：

```cpp
int poll(struct pollfd* fds, nfds_t nfds, int timeout);
```

参数含义：

```text
fds     pollfd 数组
nfds    数组元素个数
timeout 超时时间，-1 表示一直等
```

`events` 表示你关心什么事件：

```text
POLLIN  ：可读
POLLOUT ：可写
```

`revents` 表示实际发生了什么事件。

最小模型：

```cpp
pollfd fds[1];
fds[0].fd = server_fd;
fds[0].events = POLLIN;

int n = poll(fds, 1, -1);
if (n > 0 && (fds[0].revents & POLLIN)) {
    int client_fd = accept(server_fd, nullptr, nullptr);
}
```

相比 select：

```text
poll 没有 fd_set 固定大小限制。
poll 用数组表达监听列表，结构更清晰。
```

但 poll 仍然需要：

```text
每次 poll 返回后遍历整个数组，找出就绪 fd。
```

所以连接数量很大时，效率仍然不够理想。

---

## 13.4 select / poll 的共同问题

select 和 poll 都有一个核心问题：

```text
用户态每次都要把监听列表交给内核。
内核返回后，用户态还要遍历列表找就绪 fd。
```

连接少时问题不大。

连接很多时，成本会变高：

```text
fd 越多，遍历成本越高。
很多 fd 没有事件，也要被扫描。
```

因此 Linux 后来提供了更适合大量连接的：

```text
epoll
```

---

## 13.5 epoll 解决什么问题

前面的 TCP server 一次通常只处理一个或少量客户端。

如果想同时管理很多连接，不能给每个 fd 都写一套阻塞等待逻辑。

`epoll` 的作用是：

```text
同时等待多个 fd，告诉程序哪些 fd 当前可以进行 I/O 操作。
```

注意：

```text
epoll 不负责真正读写数据。
accept / recv / send 才负责真正 I/O。
```

---

## 13.6 epoll 核心模型

```text
epoll_wait：等待事件
epoll_ctl ：添加 / 修改 / 删除要监听的 fd
EPOLLIN  ：fd 可读
EPOLLOUT ：fd 可写
```

典型事件循环：

```cpp
while (true) {
    int n = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);

    for (int i = 0; i < n; ++i) {
        int fd = events[i].data.fd;

        if (fd == server_fd) {
            // 监听 socket 可读：有新连接
            accept(...);
        } else {
            // 客户端 socket 可读：有数据
            recv(...);
            send(...);
        }
    }
}
```

---

## 13.7 epoll 相关 API

### epoll_create1

```cpp
int epoll_create1(int flags);
```

作用：创建一个 epoll 实例。

示例：

```cpp
int epoll_fd = epoll_create1(0);
```

返回值：

```text
成功：epoll fd
失败：-1
```

---

### epoll_ctl

```cpp
int epoll_ctl(int epfd, int op, int fd, struct epoll_event* event);
```

作用：管理 epoll 监听的 fd。

常见 `op`：

```text
EPOLL_CTL_ADD：添加 fd
EPOLL_CTL_MOD：修改 fd 监听事件
EPOLL_CTL_DEL：删除 fd
```

示例：

```cpp
epoll_event event{};
event.events = EPOLLIN;
event.data.fd = server_fd;

epoll_ctl(epoll_fd, EPOLL_CTL_ADD, server_fd, &event);
```

---

### epoll_wait

```cpp
int epoll_wait(int epfd, struct epoll_event* events, int maxevents, int timeout);
```

作用：等待 fd 事件发生。

参数：

```text
epfd      epoll_create1 返回的 fd
events    输出数组，用来接收就绪事件
maxevents events 数组最大容量
timeout   超时时间，-1 表示一直等
```

返回值：

```text
> 0：本次就绪 fd 数量
= 0：超时
-1 ：失败
```

---

## 13.8 EPOLLIN / EPOLLOUT

`EPOLLIN` 表示 fd 可读。

但不同 fd 的含义不同：

```text
server_fd 触发 EPOLLIN：有新连接，需要 accept
client_fd 触发 EPOLLIN：有数据到达，需要 recv
```

`EPOLLOUT` 表示 fd 可写，可以 `send`。

注意：socket 大多数时候都是可写的，所以不要一直监听 `EPOLLOUT`。

真实服务器通常是：

```text
平时监听 EPOLLIN
只有有数据没发完时，临时监听 EPOLLOUT
发完后再取消 EPOLLOUT
```

---

## 13.9 为什么要设置非阻塞

epoll server 的 fd 通常要设置为非阻塞：

```cpp
int flags = fcntl(fd, F_GETFL, 0);
fcntl(fd, F_SETFL, flags | O_NONBLOCK);
```

原因：

```text
如果某个 accept / recv / send 阻塞，整个 epoll 事件循环都会卡住。
```

非阻塞模式下，如果暂时没有连接或数据，会返回 `-1`，并设置：

```cpp
errno == EAGAIN || errno == EWOULDBLOCK
```

这通常不是严重错误，只表示：

```text
现在没有更多连接 / 数据了。
```

---

## 13.10 为什么 accept 要 while

一次 `EPOLLIN` 到来时，监听 socket 的连接队列里可能已经有多个客户端。

所以推荐写法：

```cpp
while (true) {
    int client_fd = accept(server_fd, nullptr, nullptr);

    if (client_fd == -1) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) {
            break;
        }

        perror("accept");
        break;
    }

    // 设置非阻塞，并加入 epoll
}
```

含义：

```text
把当前已经到达的连接全部 accept 出来，直到 EAGAIN 表示没有更多连接。
```

---

## 13.11 LT / ET 模式

epoll 有两种触发模式：

```text
LT：Level Triggered，水平触发，默认模式
ET：Edge Triggered，边缘触发，需要加 EPOLLET
```

LT 模式：

```text
只要 fd 里还有数据没读完，epoll_wait 就会继续提醒。
```

ET 模式：

```text
只在状态变化时提醒一次。
如果没一次读完，可能不会再次提醒。
```

ET 模式必须循环读到 `EAGAIN`：

```cpp
while (true) {
    ssize_t n = recv(fd, buffer, sizeof(buffer), 0);

    if (n > 0) {
        // 处理数据
    } else if (n == 0) {
        close(fd);
        break;
    } else {
        if (errno == EAGAIN || errno == EWOULDBLOCK) {
            break;
        }

        perror("recv");
        close(fd);
        break;
    }
}
```

当前学习阶段先掌握默认 LT：

```cpp
event.events = EPOLLIN;
```

暂时不急着使用：

```cpp
event.events = EPOLLIN | EPOLLET;
```

---

## 13.12 当前 demo

文件：

```text
IPC/EPOLL/epoll_tcp_server.cpp
```

功能：

```text
监听 5555 端口
用 epoll 管理 server_fd 和多个 client_fd
server_fd 可读时 accept 新连接
client_fd 可读时 recv 数据并 echo 回去
客户端关闭时从 epoll 删除 fd 并 close
```

运行方式示例：

```bash
./epoll_tcp_server
```

另开终端连接：

```bash
nc 127.0.0.1 5555
```

---

## 13.13 epoll 最重要结论

```text
epoll_wait 只负责等事件，不负责读写数据。

监听 socket 的 EPOLLIN 表示有新连接，需要 accept。

客户端 socket 的 EPOLLIN 表示有数据，需要 recv。

非阻塞 fd 是 epoll server 的标准搭配。

LT 模式下，数据没读完会继续通知。

ET 模式下，只通知状态变化，必须循环读到 EAGAIN。
```

---

## 13.14 select / poll / epoll 对比

| 模型 | 监听 fd 的方式 | 返回后如何找就绪 fd | fd 数量限制 | 性能特点 | 适合场景 |
|---|---|---|---|---|---|
| select | `fd_set` 位图 | 遍历 `0 ~ max_fd`，用 `FD_ISSET` 判断 | 通常受 `FD_SETSIZE` 限制 | fd 多时扫描成本高 | 少量 fd、老系统兼容 |
| poll | `pollfd` 数组 | 遍历整个数组，看 `revents` | 没有 `FD_SETSIZE` 这种固定限制 | 比 select 灵活，但仍要线性遍历 | 中等数量 fd、接口比 select 清晰 |
| epoll | 内核维护监听集合 | `epoll_wait` 直接返回就绪事件数组 | 适合大量 fd | 大量连接下更高效 | 高并发 TCP/Unix Socket server |

核心区别：

```text
select：每次传 fd_set，返回后遍历 0 到 max_fd。

poll：每次传 pollfd 数组，返回后遍历整个数组。

epoll：先用 epoll_ctl 注册 fd，epoll_wait 直接返回就绪 fd。
```

记忆方式：

```text
select：老模型，有 fd_set 限制。

poll：去掉 fd_set 限制，但仍然要遍历数组。

epoll：事件注册在内核，返回的是就绪事件，更适合大量连接。
```

学习顺序：

```text
理解 select -> 理解 poll -> 实战重点掌握 epoll
```

---

# 14. 当前阶段总结

## 已掌握的 IPC 主线

```text
Pipe -> FIFO -> Signal -> Unix Socket -> TCP Socket -> mmap 文件映射 -> 匿名 mmap -> POSIX Shared Memory -> Semaphore -> Mutex/Condition Variable -> Message Queue -> select/poll/epoll
```

## 每种机制的定位

| 机制 | 主要用途 |
|---|---|
| Pipe | 父子进程简单通信 |
| FIFO | 无亲缘关系本机通信 |
| Signal | 异步通知 |
| Unix Socket | 本机 client/server 通信 |
| TCP Socket | 跨机器网络通信 |
| mmap | 文件映射、高性能文件访问、共享内存基础 |
| POSIX Shared Memory | 无亲缘进程共享内存 |
| Semaphore | 进程间同步、事件通知、资源计数 |
| Mutex/Condition Variable | 互斥访问、等待条件、复杂共享状态同步 |
| Message Queue | 一条一条的消息通信 |

## 核心判断思路

```text
1. 是传数据还是发通知？
2. 是本机还是跨机器？
3. 是简单字节流还是连接模型？
4. 是否需要消息边界？
5. 是否需要共享同一块内存？
6. 共享内存是否需要同步机制？
7. 是简单通知还是复杂条件等待？
8. 是否更适合消息模型？
```

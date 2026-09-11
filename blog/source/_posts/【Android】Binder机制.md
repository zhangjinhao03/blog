---
title: 【Android】Binder机制
date: 2026-09-01 14:43:48
tags: [IPC,Android]
categories: Android
series: Android虚拟机知识
top_img: /img/1400253.png
cover: /img/1400253.png
---

# Android中的IPC通信与Binder机制

## 1.Linux的IPC通信机制

**1.管道:分为匿名管道和有名管道**

匿名管道(pipe):信息单向传输,并且只能在有亲缘关系的父子进程之间使用,故而想要双向信息交流,需要使用两个管道才可(我们常说的管道就是无名管道)(信息也是存在于内核当中)
命名管道(FIFO):该管道类型允许没有亲缘关系的进程进行通信

**2.消息队列**

使用一个链表用于存储消息数据,发送数据则是将数据存储于消息体当中,使用消息队列时发送方和接收方均要定义同一个数据类型,发送方将数据存于消息体当中,接收方在需要时候则会去消息队列访问数据,因而消息队列存在滞后性以及由于每个消息体的内存限制,导致不能传输大数据(消息队列存于内核当中)

**3.共享内存**

以上两种通信方式存在用户态到内核态的一个拷贝过程,因此效率较低,共享内存机制:从物理内存中分出一段内存空间,其他几个进程将自己的一段虚拟空间地址指向该内存地址上,发送消息时就不需要将数据从用户空间拷贝到内核空间，接收消息时只需要去对应的地址上去读消息即可。但由于多进程同时write存在写覆盖,因此引入信号量机制

共享内存机制图:

![image-20260901145846762](image-20260901145846762.png)

**4.信号量**

信号量本质上是一个整型计数器，主要用来实现进程间的互斥与同步，而不是用来缓存进程间通信的数据。
进入共享内存为p操作,信号量个数减一,反之为V操作,信号量个数加一

**5.信号**

Linux系统中为了响应各种各样的事件，提供了几十种信号，使用 kill -l 命令可以进行查看
本质上就是我发出什么命令,对端进程执行对应操作

一旦有信号产生，用户进程对信号的处理方式有三种：

执行默认操作：
    Linux对每种信号都规定了默认的操作，例如SIGTERM信号表示终止进程等。
    捕捉信号：
    可以为信号定义一个信号处理函数，当信号发生时，程序就会执行相应的信号处理函数。
    忽略信号：
    如果不希望处理某些信号，就可以忽略该信号，不做任何处理。
    有两个信号是应用进程无法捕捉和忽略的：
    SIGKILL(9) 和 SIGSTOP(19)，它们用于在任何时候中断或结束某一进程。

**6.socket**

socket是一种用于不同主机或不同进程之间进行网络通信的通用接口，它把底层的传输细节封装起来，让应用只需要通过地址、端口和协议就能完成连接、发送和接收数据。和前面的几种本地 IPC 方式相比，socket 更适合跨机器通信，也常用于客户端和服务器之间的长连接、请求响应和数据流传输场景。

---

## 2.Android中的IPC通信方式

**1.Bundle**

主要用于组件间通信,它保存的数据，是以key-value(键值对)的形式存在的。传递的数据可以是boolean、byte、int、long、float、double、string等基本类型或它们对应的数组，也可以是对象或对象数组。当Bundle传递的是对象或对象数组时，必须实现Serializable 或Parcelable接口,Bundle提供了各种常用类型的putXxx()/getXxx()方法，用于读写基本类型的数据。

**2.AIDL:使用**

1. 创建aidl文件:定义好方法后,rebuild
2. 实现aidl接口的方法:此时生成一个同名.java文件,文件中有个.Stub的子类,该类继承了Binder类,并且在创建.Stub的时候底层自动生成了.asInterface方法主要功能就是检索 Binder 对象是否是本地接口的实现,根据 queryLocalInterface() 方法返回值判断是否使用代理对象，这个检索过程应该由系统底层支持，如果返回为 null，则创建 Stub 的代理对象，反之使用本地对象来传输数据
3. 向客户端公开接口:service重写onBind方法(返回类型IBinder),
4. 客户端远程调用(server端和客户端都有一个要传递的数据对象,该对象必须序列化,然后双方都有一个该数据对象的java类和aidl文件以及用于管理该数据对象的manager对象类和aidl文件(get set方法之类的),接着客户端执行获取类似如下:***MANager.Stub.asInterface()获取到manager对象即可对数据对象进行操作),服务端必须实现接口中的方法
5. 验证 AIDL

aidl用法如下图:

![image-20260901150038543](image-20260901150038543.png)

## 3.Binder机制

原理:一次copy即可完成信息交换

![image-20260901150022313](image-20260901150022313.png)

以上是Binder机制的kernel层的底层原理,实际上就是基于共享内存实现的跨进程通信

Binder实现原理:

1. server端将service通过binder注册到ServiceManager当中(执行addService(name,service),将自己保存在serviceManager的serviceMap当中)
2. client向service Manager发起查询请求(根据name获取service),sm将查询结果(server进程地址)返回
3. client通过使用binder
4. server返回对应数据

![image-20260901150137267](image-20260901150137267.png)

### Binder初始化:

```CSS
binder.c (binder_init函数)执行初始化
初始设备init_binder_device(name)
配置binder_fops
注册misc_register:init_binder_device()函数最后调用了misc_register(&binder_device→miscdev)来注册生成的binder设备
```

### ServiceManager初始化

```C#
init.rc中启动servicemanager(sm是由init启动的)
调用main.cpp的main函数:a 打开/dev/binder设备,b 通过mmap映射设备的内存空间到ServiceManager进程中,c 设置ServiceManager为context manager,d ServiceManager服务进入循环，等待接收数据来进行处理
```

完成Binder driver与ServiceManager的初始化工作后

### Binder框架中的主要结构体

```Lua
IPCThreadState:binder进程中操作Binder的进程的那个线程的对象(该线程对象使用ontransact函数通过系统调用与Binder驱动进行沟通)
ProcessState:进程中操作Binder的进程对象
binder_proc:每个process state对象都会在内核空间中对应一个binder_proc对象
binder_thread:binder驱动中每一个binder_proc对象中有多个线程来处理请求业务。这些线程结构体为binder_thread，它们保存在红黑树结构的threads对象中进行管理
binder_proc_todo_list:每一个binder_proc中的todo列表表示将要做的工作，其中保存的是binder_work结构体
binder_thread_todo_list:每一个binder_thread结构体中也有一个todo列表，列表中也是保存着一个个binder_work结构体
```

上述结构如下图:

![image-20260901150210105](image-20260901150210105.png)

### C/S架构视角下的Binder:

在讲完binder的机构体之后呢,我们从C/S架构的视角再看待一次binder:

在service结构体中有一个IBinder类型的属性,我们接着从上层梳理一下binder中的继承结构,以AMS为例

```Scala
1 public class ActivityManagerService extends IActivityManager.Stub{
这个IActivityManager.Stub的类在java中看不到,只能找到一个同名的aidl,aidl文件通过编译生成上述的IActivitymanager类
该类编译后的代码如下:
2 public interface IActivityManager extends android.os.IInterface{
public static abstract class Stub extends android.os.Binder implements android.app.IActivityManager{
我们发现Stub这个内部类继承了Binder类,
3 public class Binder implements IBinder{
我们发现Binder是实现了IBinder
4 public interface IBinder{
Ibinder是一个接口
```

上述的继承关系大致如下:

![image-20260901150227391](image-20260901150227391.png)

接着我们从C/S的视角来看一下Binder的架构,如下图:

![image-20260901150246749](image-20260901150246749.png)

上述结构图我的理解是这样的: 

```Lua
server端继承Stub,aidl编译后生成一个对应的类,service实现了继承了binder的Stub的内部类,接着在native生成一个BBinder,并最终在内核空间生成了一个自己独有的binder_node此时可以理解为继承了Stub的类具有了binder通信的能力,接着server执行addservice(name,service)将自己注册到ServiceManager中的serviceMap当中
此时呢,client需要进行ipc通信了,则创建一个自己的代理类,然后在最终在native层生成一个bpBinder(实现了IBinder),并最终生成了一个binder_ref对象,然后执行binder_transaction进行通信
```

由于在同进程中呢对象的传递是引用传递,本质上就是一个内存地址,但是在跨进程通信中呢,由于虚拟内存地址的存在引用进程就不能使用了,此时需要将其传递过去进行序列化,然后再反序列化即可

## 4.Android使用Binder跨进程通信实例

题目：在系统中判断并区分应用的冷热启动，在框架层通过IApplicationThread的AIDL接口跨进程将相关冷、热启动信息传递到应用进程，然后在应用进程的UI线程中显示toast提示启动信息。

### 1.如何区分冷热启动

对于区分冷启动和热启动的关键就是在启动时判断是否创建了新的进程，因此我们在ActivityTaskManagerService.startActivity中加入判断的代码：

```java
public final int startActivity(IApplicationThread caller, String callingPackage,
            String callingFeatureId, Intent intent, String resolvedType, IBinder resultTo,
            String resultWho, int requestCode, int startFlags, ProfilerInfo profilerInfo,
            Bundle bOptions) {
        // DEMO ADD：        
        Log.w(TAG,"K8test:startActivity.");

        boolean isCold = isColdStart(intent);
        
        //调用IApplicationThread的接口
        if(caller != null){
            try {
                //通知应用进程启动信息
                caller.notifyStartupInfo(isCold);
            } catch (Exception e) {
            }
        }
        
        return startActivityAsUser(caller, callingPackage, callingFeatureId, intent, resolvedType,
                resultTo, resultWho, requestCode, startFlags, profilerInfo, bOptions,
                UserHandle.getCallingUserId());
    }
```

isColdStart的实现：通过Intent获取当前应用包名，并通过AMS中的进程列表查看已有进程中是否有与当前包名同名的进程，如果没有则说明是新创建的进程则为冷启动，否则为热启动。

```java
// DEMO ADD：
public boolean isColdStart(Intent intent) {
        ActivityManagerService mActivityManagerService = (ActivityManagerService) ServiceManager.getService(Context.ACTIVITY_SERVICE);
        String packageName = intent.getComponent().getPackageName();
        for (ActivityManager.RunningAppProcessInfo processInfo : mActivityManagerService.getRunningAppProcesses()) {
            if (processInfo.processName.equals(packageName)) {
                return false; // Not a cold start
            }
        }
        return true;
    }
```

### 2.IApplicationThread中定义接口

**oneway** 表示在远程调用时(是异步调用，即客户端不会被阻塞), 它只是发送事务数据并立即返回. 

**oneway**修饰了的方法不可以有返回值，也不可以有带out或inout的参数。可以去看看 IApplicationThread.aidl文件中,定义的方法, 都是void类型, 没有返回值.

IApplicationThread.aidl中添加notifyStartupInfo接口的定义

```Java
oneway interface IApplicationThread {
    ......
    // DEMO ADD:
    void notifyStartupInfo(in boolean isCold);
}
```

ActivityThread中实现notifyStartupInfo接口

```java
public final class ActivityThread extends ClientTransactionHandler
        implements ActivityThreadInternal {
    ...
    private class ApplicationThread extends IApplicationThread.Stub {
        ...
       // DEMO ADD:
        public void notifyStartupInfo(boolean isCold) throws RemoteException{
            //
            Log.w(TAG,"mIsColdStart set to: "+isCold);
            Message msg = Message.obtain();
            msg.what = mH.START_UP_INFO;
            msg.obj = isCold;
            mH.sendMessage(msg);
        }
        ...
    }
    ...
}
```

至此，冷启动信息布尔值isCold已从System_server进程传到了应用进程ActivityThread中,上述代码在notifyStartupInfo中定义了Message对象并将其发送给Handler实现跨线程处理。

```
Handler 是 Android 中用于线程间通信和消息调度的机制，最常见的作用是：子线程完成耗时任务后，通过 Handler 切回主线程更新 UI。
Android 不允许子线程直接更新 UI
子线程可以通过 Handler 发送消息到主线程，由主线程处理 UI 更新
```

### 3.跨线程通信

在Handler中添加定义：

```java
class H extends Handler{
    ......
    // DEMO ADD:
    public static final int START_UP_INFO = 190;
    
    ......
    String codeToString(int code) {
            if (DEBUG_MESSAGES) {
                switch (code) {
                    case ...
                    case START_UP_INFO: return "START_UP_INFO";  // DEMO ADD:
                }. # # . 
. # # . 
. . . . 
. . . .
            }
            return Integer.toString(code);
        }
    ......
    

    public void handleMessage(Message msg) {
        if (DEBUG_MESSAGES) Slog.v(TAG, ">>> handling: " + codeToString(msg.what));
        switch (msg.what) {
        // DEMO ADD:
        //发送给主线程显示TOAST
            case START_UP_INFO:
                boolean isColdinfo = (boolean)msg.obj;
                Context context = getApplication().getApplicationContext();
                if(isColdinfo){
                    Toast.makeText(context,"ColdStart" , Toast.LENGTH_SHORT).show();
                }else{
                    Toast.makeText(context,"WarmStart" , Toast.LENGTH_SHORT).show();
                }
                break;
            case ...
            ......
        }
    }
}
```

这样就完成了在应用进程的中UI线程中显示toast提示启动信息。

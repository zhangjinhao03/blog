---
title: 【Android】ART虚拟机调试方法
date: 2025-02-17 14:43:48
tags: [ART,Android]
categories: Android
series: Android虚拟机知识
top_img: /img/1400253.png
cover: /img/1400253.png
---

# ART虚拟机调试方法

本文档为虚拟机运行时调试入门基础

Perfetto工具下载： https://github\.com/google/perfetto

下载Android NDK：https://developer\.android\.com/ndk/downloads?hl=zh\-cn

# **一、本地编译**

## **1\.1 本地编译模块**

### 执行脚本

**1\.执行脚本**

```Python
1.执行脚本-------------------
#执行以下命令
export SKIP_DOWNLOAD_OPERATOR_APPS=true
export XMS_BULDER_DISABLED=true
export SKIP_DOWNLOAD_DECOUPLED_APPS=true
export SKIP_DOWNLOAD_CUST_APPS=true
export SKIP_DOWNLOAD_VENDOR_GOOGLE_APPS=true
export BUILD_TARGET_IS=system
export TARGET_BUILD_USE_PREBUILT_SDKS=false
source build/envsetup.sh

```

### 构建目标

**2\.选择构建目标**

```Python
2.lunch 选择构建目标----------------

#lunch 参数解释：
#missi
# ➤ 项目代号（比如是你的项目名、产品名、代工厂名等）。
#feature_phone_qcom_cn_only64_private_build
# ➤ 表明这是一个面向中国的、仅 64 位的、高通平台 feature phone 构建配置。
#user
# ➤ 构建类型，表示为用户版本（没有 root、带签名、适合量产出货的版本）。

#高通·
lunch missi-feature_phone_qcom_cn_only64_private_build-user
# eng userdebug

#玄戒
lunch missi-feature_phone_xring_cn_only64-user

#玄戒平板
lunch missi-final_pad_xring_cn_only64_private_build-user

#安卓W以后高通
lunch missi-feature_phone_qcom_cn_only64-userdebug
lunch missi-final_phone_qcom_cn_only64-user
```

具体要执行哪个命令可以通过日构建包查看，以O81A的日构建包为例：

![img_v3_02q5_ad226bb9-9e96-4c4a-b031-981c42f9c3dg](img_v3_02q5_ad226bb9-9e96-4c4a-b031-981c42f9c3dg.jpg)

![img_v3_02q5_8cfc9619-04f5-438a-9655-92629845334g](img_v3_02q5_8cfc9619-04f5-438a-9655-92629845334g.jpg)

![img_v3_02q5_c796bf1b-b40d-4a4c-933c-24521740cbcg](img_v3_02q5_c796bf1b-b40d-4a4c-933c-24521740cbcg.jpg)

![img_v3_02q5_2543cebf-3fc3-41f8-8c2b-a6f51634318g](img_v3_02q5_2543cebf-3fc3-41f8-8c2b-a6f51634318g.jpg)

### 编译模块

**3\.本地编译单个模块**

避免记不住太多的参数，推荐使用自定义dev\.sh脚本，见文章末尾附录

```Python
3.本地编译单个模块----------------

#编译 art 模块
make com.android.art -j16

#编译framework 模块
make framework-minus-apex;

#编译framework-services 模块
make services;

#编译miui-framework 模块make services;
make miui-framework;

#编译miui-framework-services 模块
make miui-services
```



**API更新（可选）**

若修改了原生代码或解耦接口（非MIUI添加接口）或添加了xml代码，需要更新API文件后编译

```Python
#生成API声明
#ART模块
m art.module.public.api.stubs.source.module_lib-update-current-api
# libartservice/service/api/system-server-current.txt
m service-art.stubs.source.system_server-update-current-api

#MIUI模块
m miui-api-stubs-docs-update-current-api
#framework模块
m services-non-updatable-stubs-update-current-api

```



---

### 实操1

**实操1：**

例如要本地编译高通代码的art模块，依次执行以下命令

```C++
export SKIP_DOWNLOAD_OPERATOR_APPS=true
export XMS_BULDER_DISABLED=true
export SKIP_DOWNLOAD_DECOUPLED_APPS=true
export SKIP_DOWNLOAD_CUST_APPS=true
export SKIP_DOWNLOAD_VENDOR_GOOGLE_APPS=true
export BUILD_TARGET_IS=system
source build/envsetup.sh

lunch missi-feature_phone_qcom_cn_only64_private_build-user

make com.android.art -j16
```

---

## **1\.2 本地模块替换**

### 本地终端

**1\.本地终端操作**

```Python
1.本地终端命令
adb root #获取root权限
adb disable-verity #此命令禁用它，防止系统在你 remount 或修改 /system 时自动回滚,运行后必须重启设备才会生效
adb reboot #等待重启
adb root #重启后重新获取root权限
adb remount
adb tcpip 5555 #为手机设置一个tcp端口5555 也可以是其他
adb shell ifconfig #查看手机的ip地址
```

![image-20260901150038543](image-36.png)

### 工程云终端

**2\.工程云终端操作**

推荐使用dev\.sh脚本，见文章末尾附录

```Python
1.云上连接工程机
# 在确认模块编译成功后，通过刚才的端口和ip连接手机
cloudtools adb-connect 10.220.75.174:5555
```

出现如下界面即表示连接成功，按ctrl \+ c退出进程（若无法连接请检查手机ip和端口是否设置成功）

![image-20260901150137267](image-61.png)

```Python
连接成功后输入命令
adb devices #检查是否可以远程调试设备
```

如图表示设备连接正常：

![image-20260901150210105](image-37.png)

```Python
2.云上替换已编译通过的模块（一定要编译成功才能替换）
# art模块 push
adb push out/target/product/missi/system/apex/com.android.art.capex /system/apex/

#**out/target/product/missi/system/apex/com.android.art.capex**: 这是本地文件的路径，指向你在编译过程中生成的 com.android.art.capex 文件
#**/system/apex/**: 设备上目标文件夹路径，APEX 模块应该被推送到这个目录下，供系统加载。

# framework模块 push
adb push out/target/product/missi/system/framework/framework.jar /product/pangu/system/framework

# framework services模块 push
adb push out/target/product/missi/system/framework/services.jar /product/pangu/system/framework/

# miui-framework模块 push
adb push out/target/product/missi/system_ext/framework/miui-framework.jar /system_ext/framework

# miui-services模块 push
adb push out/target/product/missi/system_ext/framework/miui-services.jar /system_ext/framework
```

```Python
3.替换成功后重启机器生效（云或本地终端操作都可）
adb reboot

注：若无法正常开机（卡在开机界面）请重新刷一个当天的日构建包后再进行模块替换,记得本地也要repo sync一下
```

---

### 实操2

**实操2：**

在**实操1**中已成功本地编译了art模块，下面将编译好的art模块替换到手机中：



```C++
#本地终端
adb root #获取root权限
adb disable-verity
adb reboot #等待重启
adb root #重启后重新获取root权限
adb remount
adb tcpip 5555
adb shell ifconfig #查看手机的ip地址例如为10.201.15.139
```

```Python
# 工程云终端
# 在确认模块编译成功后，通过刚才的端口和ip连接手机
cloudtools adb-connect 10.201.15.139:5555

# 连接成功后输入命令
adb devices #检查是否可以远程调试设备

# 将编译好的art模块push到手机
adb push out/target/product/missi/system/apex/com.android.art.capex /system/apex/

# 替换art模块
adb reboot
```

---

## **1\.3 刷机相关**

**进入fastboot模式**

使用命令：

```Python
adb reboot bootloader
```

或长按手机“电源键”和“音量\-”键

**退出fastboot模式**

```Python
fastboot reboot
```

**刷机后跳过网络设置和登陆小米账号**

```Python
vim ~/.bashrc

#然后将下面内容粘贴到最下方

# skip
alias adbskip='adb shell settings put secure user_setup_complete 1
  adb shell settings put global device_provisioned 1
  sleep 3
  adb reboot
  sleep 40
  adb root
  adb shell pm disable-user com.xiaomi.account'

#source 一下
source ~/.bashrc

#刷机后执行
adbskip
```

## 1\.4 ide

### 1\.4\.1 compile\_commands\.json

这个文件是什么可以问问AI。简单来说是给clangd这个LSP 提供编译信息，以支撑IDE中代码跳转，补全，分析的功能。公司内部aosp的构建系统有个bug。

![img_v3_02vf_0f8640d3-3e3d-4863-9d9d-94bc0c427ebg](img_v3_02vf_0f8640d3-3e3d-4863-9d9d-94bc0c427ebg.jpg)



build/soog/cc/cc\.go文件中。注释掉503行代码。编译构建的时候加上

```C++
export SOONG_GEN_COMPDB=1
export SOONG_GEN_COMPDB_DEBUG=1
 
```

就可以在

out/soong/development/ide/comdb/compile\_commands\.json找到对应的json文件。 

建议拷贝到art目录下,不做软连接，软连接构建索引比较慢，可能是错觉。

### 1\.4\.2 hypercode

1. clangd

先确保环境有clangd，默认好像有clangd\.

![image 62](image-62.png)



没有就下载。 https://github\.com/llvm/llvm\-project/releases/download/llvmorg\-22\.1\.0/LLVM\-22\.1\.0\-Linux\-X64\.tar\.xz 然后配置PATH环境变量

2. 安装cpp 插件

安装这个插件完全是为了重启hypercode，目前没有重启hypercode方式。安装之后啥也不管。最后卸载它，会提示重启hypercode。

![image-20260901150227391](image-47.png)



> cpp跟clangd是冲突
> 
> 

3. 安装clangd插件



![image-20260901150246749](image-26.png)



可能会提示跟cpp冲突，操作错了会把clangd disable掉，不过没关系，随时可以enable。

4. 卸载 cpp

这个时候卸载cpp，然后就会提示重新reload window了。

然后就可以愉快的看art代码了。 clangd后台会异步构建索引，偶尔可能会有点卡，而且hypercode中不知道为什么构建索引有点慢。所以，不怕麻烦可以用lazyvim, 非常快，非常流畅。



### 1\.4\.3 lazyvim

**部署lazyvim**



可以Google或者AI问问lazyvim是啥。

工程云上lazyvim需要的fzf, ripgrep已经有了，fd需要下载: https://github\.com/sharkdp/fd/releases/download/v10\.3\.0/fd\-v10\.3\.0\-x86\_64\-unknown\-linux\-gnu\.tar\.gz



先下载nvim，解压后配置到环境变量



名称:nvim\-linux\-x86\_64\.tar\.gz

地址:https://kpan\.mioffice\.cn/webfolder/ext/cPraGVSatNv%24uVm31GQvyw%40%40

密码:96a6



然后下载对应的配置信息和插件信息



名称:lazyvim\_offline\_docker\.tar\.gz

地址:https://kpan\.mioffice\.cn/webfolder/ext/4VmJChLSMpP%24uVm31GQvyw%40%40

密码:56PI



cp到\~目录解压即可,会解压到下面三个目录



/home/docker/\.config/nvim

/home/docker/\.local/share/nvim

/hom/docker/\.local/state/vim





最后一步，环境变量中加入:

```Bash
export PATH=/home/docker/.local/nvim/bin:$PATH
export JAVA_HOME=/home/docker/opt/jdk-21.0.2
export PATH=$JAVA_HOME/bin:$PATH
export XDG_CONFIG_HOME=/home/docker/.config
```

没有XDG的设置，nvim找不到\~/\.config下的nvim配置信息,工程云上这个环境变量默认指向 /home/wujiahua/\.xfce

---



字体

名称:nerd\-fonts\-master\.zip

地址:https://kpan\.mioffice\.cn/webfolder/ext/WKnd8DQgSq3%24uVm31GQvyw%40%40

密码:1aBW

下载，解压出来，有个install\.sh,就可以安装所有字体。



配置字体。

![image](image-19.png)



打开对应的json配置

![image](image-72.png)

添加对应的字体, nerd fonts中有很多，可以自己自己尝试，自己选择。

```C++
"terminal.integrated.fontFamily": "MesloLGS NF"
```

**lazyvim使用**

默认leader键是space\.

**文件操作**

```Shell
leader f f # 打开文件
leader f r # 最近打开的文件
leader f . # 当前文件所在目录搜索并打开文件
leader e # toggle neo-tree
# leader e进入neo-tree
y # 复制文件路径
Y # 复制文件名
a # 新建文件
r # 文件重命名



```

打开最近文件

![image](image-15.png)

ctrl n 或者ctrl p是上下选择 ， ctrl g是退出，按esc也行。



当前目录打开文件



![image](image-55.png)

**终端**

```Shell
ctrl + / # toggle terminal
```

![image](image-11.png)

**搜索**

```Shell
leader s b # 当前文件中搜索
leader s B # workspace中搜索
leader s w # 当前文件中搜索光标所在的单词
leader s W # workspace中搜索光标所在的单词
```

当前文件搜索



![image](image-13.png)



当前文件搜索光标所在的单词

![image 73](image-73.png)

**LSP**

```Shell
leader s s # 当前文件搜索symbol
leader s S # workspace中搜索symbol
g d # go to definition
g r # find refenece
g I # find implementation/overriding 
```

搜索当前文件的symbol

![image 2](image-2.png)



搜索当前symbol的使用点

![image 17](image-17.png)



查看一个virtual方法的实现有哪些

![image 32](image-32.png)

**注释**

```Shell
gcc # toggle 注释
```

**Bookmark**

```Shell
BookmarsXXXX
```

**Command**

```Shell
: # 直接输入英文冒号
space s c # command history
space s C # all commands, 等价与 :
```

**Misc**

```Shell
z a # toggle fold
ctrl o # 返回
```

### 1\.4\.4 framework java开发

使用Android Studio

首先确保framework编译成功,然后运行

```C++
export SKIP_DOWNLOAD_OPERATOR_APPS=true
export XMS_BULDER_DISABLED=true
export SKIP_DOWNLOAD_DECOUPLED_APPS=true
export SKIP_DOWNLOAD_CUST_APPS=true
export SKIP_DOWNLOAD_VENDOR_GOOGLE_APPS=true
export BUILD_TARGET_IS=system
export SOONG_GEN_COMPDB=1
export SOONG_GEN_COMPDB_DEBUG=1
export SOONG_GEN_CMAKEFILES=1
export SOONG_GEN_CMAKEFILES_DEBUG=1
source build/envsetup.sh
lunch missi-feature_phone_qcom_cn_only64-userdebug
make com.android.art -j64
make framework -j64
make framework-minus-apex -j64
make miui-framework -j64
// 要开发哪个模块，就传递哪个path, 不要传递frameworks/base,太大了！！ 非常非常慢！！！
aidegen frameworks/base/services/core  -i s -s -n  # android studio , -s文档说是skip build,直接解析
```

- \-i 是 IDE是的意思, e 是eclipse, 会生成对应的\.project和\.classpath文件, 很多ide都能识别出来

- \-s 是skip build的意思

- \-n 是no launch的意思, 有eclipse，可以自动启动，工程云环境没法玩

更详细的信息:

https://android\.googlesource\.com/platform/tools/asuite/\+/refs/heads/main/aidegen/README\.md



获取gradle 信息

名称:gradle\_deps\.tar\.gz

地址:https://kpan\.mioffice\.cn/webfolder/ext/byvZCyI11rz%24uVm31GQvyw%40%40

密码:34oa

解压到/home/docker/\.gradle

使用android studio 打开frameworks/base/service/core目录即可



![image 60](image-60.png)

**推荐插件**



名称:Atom\_Material\_Icons\-101\.0\.0\.zip

地址:https://kpan\.mioffice\.cn/webfolder/ext/qM2FWxkXPrz%24uVm31GQvyw%40%40

密码:9l47





名称:Atom\_Material\_Icons\-101\.0\.0\.zip

地址:https://kpan\.mioffice\.cn/webfolder/ext/qM2FWxkXPrz%24uVm31GQvyw%40%40

密码:9l47



名称:Atom\_Material\_Icons\-101\.0\.0\.zip

地址:https://kpan\.mioffice\.cn/webfolder/ext/qM2FWxkXPrz%24uVm31GQvyw%40%40

密码:9l47





名称:claude\-code\-jetbrains\-plugin\-0\.1\.14\-beta\.zip

地址:https://kpan\.mioffice\.cn/webfolder/ext/aJBaNA%24n9QH%24uVm31GQvyw%40%40

密码:3M84

安装了material主题，安装插件不好找install from disk。



离线安装插件:



![image 22](image-22.png)

**设置**

**字体设置**

![image 57](image-57.png)



![image 9](image-9.png)



![image 38](image-38.png)



![image 65](image-65.png)

**Center bar 设置**

vnc环境，鼠标左键没效果，推荐把一些常用设置放到center bar，效果：

![image 41](image-41.png)



具体设置方式：

打开设置

![image 6](image-6.png)



右键添加action

![image 20](image-20.png)





![image 5](image-5.png)



![image 21](image-21.png)



![image 58](image-58.png)

**AS  搭配 claude**



先升级AS，之所以要手动升级，是因为2025\.2版本之后自带MCP server，应该能帮助claude更懂工程。

https://www\.jetbrains\.com/help/idea/mcp\-server\.html

![image](image.png)



名称:android\-studio\-panda2\-linux\.tar\.gz

地址:https://kpan\.mioffice\.cn/webfolder/ext/zjtLCbCDBKf%24uVm31GQvyw%40%40

密码:e1YH



下载到/home/docker/opt目录,然后使用 `tar xf android-studio-panda2-linux.tar.gz.tar.gz` 解压。

在桌面编辑android studio 快捷键

![image 14](image-14.png)





![image 4](image-4.png)



先删掉Command中的内容，然后输入

```JSON
env XDG_CONFIG_HOME=/home/docker/.config ANDROID_SDK_ROOT=/home/docker/Android ACC_USER_NICKNAME=wujiahua SDK_TEST_BASE_URL=https://pkgs.d.xiaomi.net/artifactory/google-android-remote/ /home/docker/opt/android-studio/bin/studio.sh
```

注意最后是刚才解压出来的路径。





安装cluade 插件。

名称:claude\-code\-jetbrains\-plugin\-0\.1\.14\-beta\.zip

地址:https://kpan\.mioffice\.cn/webfolder/ext/KcFcguBfrf%23%24uVm31GQvyw%40%40

密码:2pXN



打开cluade

![image 44](image-44.png)



输入ide, 第一次可能稍微等一下



![image 18](image-18.png)



弹出来之后选择Android Studio

![image 34](image-34.png)



![image 53](image-53.png)





![image 30](image-30.png)



显然从IDE那里拿到了编译诊断信息。



如果不连接IDE，则会尝试调用javac，显然是错误行为。

![image 16](image-16.png)

---

# **二、常用ADB命令**

## **2\.1 强制编译某个应用为机器码：**

```Python
adb shell cmd package compile -m speed -f com.taobao.taobao
adb shell pm compile -m {verify} -f {package_name}
# 手动编译为verify
参数1可选：
verify
speed-profile
speed
```

## **2\.2 selinux机制调试**

当开发模块涉及读写操作时，如果功能失效可以通过`adb shell setenforce 0`调试拉判断是否为缺少selinux权限的原因：

```Python
#一、动态开关selinux检查机制：
adb shell setenforce 0 //设置成permissive（宽容模式）模式
#不阻止任何访问
#但仍然 **记录所有违规日志**
#-------------------------------------------------------
adb shell setenforce 1 //设置成enforce（强制模式）模式
#严格执行安全策略
#违规访问：**直接拒绝**
#同时记录 AVC 日志

adb shell getprop setenforce //查看当前setenforce的值

#二、查看进程的selinux权限组信息：
adb shell "ps -AZ |grep pid"

#三、修改selinux权限后，需要单独编译selinux_policy模块替换验证
```

**SELinux权限添加**

```Python
若报错信息如下：（日志中检索信息“avc: denied”）
avc: denied { read write } for comm="AdaptorThread" name="video31" dev="tmpfs" ino=18586 scontext=u:r:system_app:s0 tcontext=u:object_r:video_device:s0 tclass=chr_file permissive=0
分析：
缺少的权限：{ read write }
谁缺少的权限：system_app
对哪个类型缺少的权限：video_device
什么格式的文件：chr_file

allow system_app video_device:chr_file { read write };
```

例如dex2oat缺少相关的selinux权限，按照格式添加：

```Python
allow dex2oat trace_data_file:dir{ search };
```

![image 42](image-42.png)

并且device/xiaomi/sepolicy仓库的代码在打包时要加入到system中而非product，否则会不生效

---

## **2\.3  更改GC类型**

默认情况下，在 Android 10 及更高版本中，CC 回收器在分代模式下运行。如需停用分代模式，可以使用 `-Xgc:nogenerational_cc` 命令行参数。或者，也可以按如下方式设置系统属性：

```Python
adb shell setprop dalvik.vm.gctype nogenerational_cc
```

---

# 三、调试手段

## 3\.1 日志调试

### 3\.1\.1 如何添加日志：

**C\+\+代码日志**

```C++
#include "base/logging.h"

LOG(INFO) << "debug:**";
LOG(WARNING) << "debug:**";
LOG(ERROR) << "debug:**";
LOG(DEBUG) << "debug:**";
```

**JAVA代码日志**

**1\.Log日志**

```Java
package com.example.myapp;

import android.os.Bundle;
import android.util.Log;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // 打印一条简单的日志
        Log.d("MainActivity", "Hello, this is a debug log.");

        // 打印一条信息日志
        Log.i("MainActivity", "Hello, this is an info log.");

        // 打印一条警告日志
        Log.w("MainActivity", "Hello, this is a warning log.");

        // 打印一条错误日志
        Log.e("MainActivity", "Hello, this is an error log.");
    }
}

//Log.d：用于打印调试日志，d 代表 debug。
//Log.i：用于打印信息日志，i 代表 info。
//Log.w：用于打印警告日志，w 代表 warning。
//Log.e：用于打印错误日志，e 代表 error。

```

**2\.Slog日志**

```Python
import android.util.Slog;

Slog.d(TAG, "Check install restriction took ");
Slog.w(TAG, "ai is null!");
Slog.i(TAG, "debug:**");
Slog.e(TAG, "initCotaApps pkgName is null, skip parse this tag");
```

**注意：在使用logcat调试时，info，debug类型的日志可能会抓取不到，只有bugreport才能查看到日志。所以本地调试最好使用warning或error类型日志**



---

### **3\.1\.2 抓取日志：**

#### **启动 logcat**

```Python
adb logcat
#这会输出设备上的所有日志内容（非常多）。
```

---

#### **过滤指定的 TAG**

日志级别有以下几种（从低到高）：

- `V`: Verbose（最详细）

- `D`: Debug

- `I`: Info

- `W`: Warn

- `E`: Error

- `F`: Fatal

- `S`: Silent（屏蔽）

```Python
adb logcat MyTag:D *:S
# 含义：
# MyTag:D：只显示标签为 MyTag 且等级为 DEBUG 及以上的日志。
# *:S：屏蔽其他所有日志。
```

```Python
adb logcat *:W
#只显示 Warn 和更严重级别（Error, Fatal）的日志。
```

---

#### **正则匹配过滤\(最常用\)**

```Python
adb logcat | grep "debug:"
```

---

#### **将抓到的日志写入文件**

```Python
adb logcat | grep "debug:" > log.txt
```

---

### **3\.1\.3 抓取bugreport**

通常抓取的日志量很大容易被冲掉时，可以抓取bugreport，另外如果打印详细的堆栈时无法通过logcat获取日志信息，此时也需要抓取bugreport；但bugreport会抓取所有的日志，因此筛选关键信息是通过bugreport调试的关键。

```Python
#抓取bugreport命令
adb bugreport
```

---

**下载glog**

可以使用解析日志工具 glog可以很好帮助筛选关键日志

```Python
sudo apt-get install libgoogle-glog-dev
```

![image 48](image-48.png)

---

### **3\.1\.4 打印堆栈**

**ART C\+\+ 中打印堆栈**

```C++
////需要加头文件
#include "runtime_common.h"

//在日志中最好加入关系信息，方便过滤
Backtrace thread_backtrace(nullptr);
LOG(INFO) << "Backtrace: " << Dumpable<Backtrace>(thread_backtrace) << std::endl;
```

---

**JAVA中打印堆栈**

```Java
new Exception("Print stack trace").printStackTrace();
```

**例**：

在代码中加入打印函数调用的堆栈

![image 8](image-8.png)

在bugreport中可以查看到函数的被调用情况:

![image 39](image-39.png)

---

### 3\.1\.5 开启Art各功能模块调试日志

ART虚拟机中有很多组件,比如gc, compiler, class loader, jit, profiler等,每个组件都有verbose输出，打印组件的工作流程\.

比如在代码仓库看到如下的log代码

```C++
if (VLOG_IS_ON(class_linker)) {
    LogNewVirtuals(methods);
  }
// 或者
 if (!codegen->IsLeafMethod()) {
    VLOG(compiler) << "Intrinsic method is not leaf: " << method->GetIntrinsic()
        << " " << graph->PrettyMethod();
    return nullptr;
  }
```

可以通过以下方式打开verbose功能\.

设置输出某一模块的日志 比如查看compiler的verbose输出,可以通过下面命令设置

```Python
# adb root是前提

adb shell 'setprop dalvik.vm.dex2oat-flags "--runtime-arg -verbose:compiler"' # 不需要重启shell
# 或者通过 这个方式设置，设置完成后通过adb shell stop adb shell start 重启一下shell即可
 adb shell setprop dalvik.vm.extra-opts -verbose:compiler
 
```

然后通过

```C++
adb shell pm compile -m speed -f com.taobao.taobao
```

可以看到log

```C++
adb logcat -s dex2oat64
```

![image 70](image-70.png)



verbose除了可以设置compiler,还可以根据下面这段代码确认可以传递哪些参数。

[art](https://source-v.dun.mi.com/opengrok-v/xref/missi_v_qcom/art/)/[libartbase](https://source-v.dun.mi.com/opengrok-v/xref/missi_v_qcom/art/libartbase/)/[base](https://source-v.dun.mi.com/opengrok-v/xref/missi_v_qcom/art/libartbase/base/)/[logging\.h](https://source-v.dun.mi.com/opengrok-v/xref/missi_v_qcom/art/libartbase/base/logging.h)

```C++
struct LogVerbosity {
    bool class_linker;  // Enabled with "-verbose:class".
    bool collector;
    bool compiler;
    bool deopt;
    bool gc;
    bool heap;
    bool interpreter;  // Enabled with "-verbose:interpreter".
    bool jdwp;
    bool jit;
    bool jni;
    bool monitor;
    bool oat;
    bool profiler;
    bool signals;
    bool simulator;
    bool startup;
    bool third_party_jni;  // Enabled with "-verbose:third-party-jni".
    bool threads;
    bool verifier;
    bool verifier_debug;   // Only works in debug builds.
    bool image;
    bool systrace_lock_logging;  // Enabled with "-verbose:systrace-locks".
    bool agents;
    bool dex;  // Some dex access output etc.
    bool plugin;  // Used by some plugins.
    // MIUI ADD: Performance_SmartGcPolicy
    bool boost;  // Used by turbo schedule
    // END Performance_SmartGcPolicy
  };
```

### 

---

## **3\.2 trace调试**

### **3\.2\.1 抓取trace**

使用脚本抓取trace

将该脚本下载到本地

[dump\_perfetto\_v3\.sh](图片和附件/dump_perfetto_v3.sh)



修改抓取trace的持续时长（单位ms）

![image 46](image-46.png)

修改抓取trace文件的输出目录

![image 66](image-66.png)

```Python
#在脚本所在目录终端下执行脚本
./dump_perfetto_v3.sh
```

---

### **3\.2\.2 抓开机trace**

默认在电脑的当前工作文件夹（可以新建一个）

**1\.修改init\.rc文件**

连接手机adb，并将手机中的init\.rc文件pull出来：

```Bash
# /system/etc/init/hw/init.rc 是init.rc文件在手机中的位置
adb pull /system/etc/init/hw/init.rc
```

打开init\.rc文件进行修改，**绿色带\+号的为需要添加的代码，添加的时候去掉\+号，然后和下面的代码对齐**，可以在文件中使用`Ctrl + F`来搜索

`on zygote-start && property:ro.crypto.state=encrypted && property:ro.crypto.type=file`

来快速定位到需要修改的位置：

```Diff
on zygote-start && property:ro.crypto.state=encrypted && property:ro.crypto.type=file
+     start traced
+     start traced_probes
+     wait_for_prop sys.trace.traced_started 1
+     start perfetto_trace_on_boot
+
      wait_for_prop odsign.verification.done 1
      # A/B update verifier that marks a successful boot.
      exec_start update_verifier_nonencrypted
```

- **Update:**

    - Android V更新后init\.rc文件出现了变化，在Android V上应对init\.rc更改如下：

    ```SQL
    on zygote-start
        # MIUI ADD: Stability_DebugEnhance
        write /proc/bootprof "INIT:zygote-start"
        # END Stability_DebugEnhance
        wait_for_prop odsign.verification.done 1
        # A/B update verifier that marks a successful boot.
        exec_start update_verifier
        start statsd
        start netd
        start zygote
        start zygote_secondary
    
    +     start traced
    +     start traced_probes
    +     wait_for_prop sys.trace.traced_started 1
    +     start perfetto_trace_on_boot
    ```

保存。

**2\.配置抓trace的配置文件**

抓trace的配置文件如下，直接下载到当前的工作文件夹：

[boottrace\.pbtxt](图片和附件/boottrace.pbtxt)

**3\.将文件推入手机**

先将手机remount并重启再remount**（注意，一定要重启一次，不然不生效）**，具体操作如下：

```Bash
adb root # 一定要先root，不然remount不成功
adb remount
adb reboot # 手机重启
# 等待手机重启完毕
adb root
adb remount
```

将上述两个修改后的文件推入手机

```Bash
adb push init.rc /system/etc/init/hw/init.rc
adb push boottrace.pbtxt /data/misc/perfetto-configs/boottrace.pbtxt
```

**4\.重启手机并自动抓trace**

将上述2个修改后的推入手机后，只要手机不刷机，每次开机都会自动抓trace，trace会保存在：

```Bash
# 这是手机里的文件位置
/data/misc/perfetto-traces/
```

默认的trace名称为`boottrace.perfetto-trace`。

提取该trace文件到电脑的当前工作文件夹：

```Bash
adb pull /data/misc/perfetto-traces/boottrace.perfetto-trace
```

---

### 3\.2\.3 抓取mem\.rss

使用下面脚本抓取进程的rss内存使用情况\.

```Shell
echo -e "\033[32m---------------------------使用说明---------------------------
1.直接执行脚本，例如：“./dump_perfetto_v3.sh”,10s后脚本自动
终止，会把结果保存在$out_dir目录中
--------------------------------------------------------------\033[0m"
adb shell perfetto \
  -c - --txt \
  -o /data/misc/perfetto-traces/trace \
<<EOF


data_sources: {
    config {
        name: "linux.process_stats"
        target_buffer: 1
        process_stats_config {
            scan_all_processes_on_start: true
        }
    }
}

data_sources {
  config {
    name: "linux.process_stats"
    process_stats_config {
      scan_all_processes_on_start: true
      proc_stats_poll_ms: 250
    }
  }
}
data_sources {
  config {
    name: "android.heapprofd"
    heapprofd_config {
      sampling_interval_bytes: 4096
      process_cmdline: "dex2oat64"
      shmem_size_bytes: 8388608
      block_client: true
      all_heaps: false
    }
  }
}


# data_sources: {
#     config {
#         name: "android.surfaceflinger.frametimeline"
#     }
# }


#buffers: {
#   size_kb: 522240
#    fill_policy: RING_BUFFER
#}
#buffers: {
 #   size_kb: 2048
 #   fill_policy: RING_BUFFER
#}
#duration_ms: 120000
#flush_period_ms: 30000
#incremental_state_config {
 #   clear_period_ms: 5000
#}

buffers: {
    size_kb: 522240
    fill_policy: RING_BUFFER
}
buffers: {
    size_kb: 2048
    fill_policy: RING_BUFFER
}
duration_ms: 475000
write_into_file: true
file_write_period_ms: 2500
max_file_size_bytes: 2000000000
flush_period_ms: 20000
incremental_state_config {
    clear_period_ms: 5000
}
EOF
# if [ ! -d "result" ];then
#   mkdir result
# fi
out_dir=/home/wujiahua/code/dex2oat/trace
file_path=${out_dir}/systrace_$(date +%Y%m%d%H%M%S)
if [ -n $1 ]; then
    file_path=${file_path}_$1
fi

adb pull /data/misc/perfetto-traces/trace ${file_path}


```

- duration\_ms: 毫秒,profiling时间

- out\_dir:  perfetto trace文件保存目录

可以看到进程rss, swap等内存指标的变化趋势\.

![image 24](image-24.png)





### TODO3\.2\.2 添加trace tag

**C\+\+中添加trace tag**

添加TAG前需要添加头文件：

```C++
#include "base/systrace.h"
```

1\.

![image 10](image-10.png)

**2\.使用ScopedTrace**

ScopedTrace 会在函数进入时插入一个 trace 开始点，并在作用域结束时自动关闭 trace。这对于性能分析或调试非常有用，并且和 Android 的 systrace 工具是兼容的。

例如：

https://source\-v\.dun\.mi\.com/opengrok\-v/xref/missi\_v\_qcom/art/runtime/runtime\.cc\#340

该处的tag就是runtime的析构函数整个生命周期

![image 7](image-7.png)

3\.

![image 52](image-52.png)

https://source\-v\.dun\.mi\.com/opengrok\-v/xref/missi\_v\_qcom/art/runtime/gc/collector/concurrent\_copying\.cc\#1463

https://source\-v\.dun\.mi\.com/opengrok\-v/xref/missi\_v\_qcom/art/libartbase/base/thread\_boost\_utils\.cc\#52

**Java中添加trace tag**

[https://source\-w\.dun\.mi\.com/opengrok\-w/xref/master\-25q2\-qcom\-xiaomi/frameworks/base/core/java/android/app/ActivityThread\.java\#8422](https://source-w.dun.mi.com/opengrok-w/xref/master-25q2-qcom-xiaomi/frameworks/base/core/java/android/app/ActivityThread.java#8422)

### TODO3\.2\.3如何通过trace定位到源码中打点处

---

## 3\.3 dump调试

**dumpsys** 是一种在 Android 设备上运行的工具，可提供有关系统服务的信息。可以使用ADB命令从命令行调用**dumpsys**，获取在连接的设备上运行的所有系统服务的诊断输出，在ART虚拟机中是一种常用的调试手段。

详细命令介绍：https://gityuan\.com/2016/05/14/dumpsys\-command/

### 3\.3\.1 应用package信息

```Python
#查看应用的package信息：
#（可以查看应用的permission权限申请信息）
adb shell dumpsys package [包名]
```

**例：**

我们dump一下淘宝的package信息在终端执行命令：

adb shell dumpsys package com\.taobao\.taobao

执行结果：

![image 51](image-51.png)

可以看到dump的信息很多，最下方有dexopt信息。

---

```Python
#只检查应用编译状态可以使用命令
adb shell dumpsys package [包名] | grep -i dexopt -A 50
#该命令过滤输出dexopt内容,获取的信息更简洁一些
```

**例：**

同样dump一下淘宝，在终端执行命令：

adb shell dumpsys package com\.taobao\.taobao \| grep \-i dexopt \-A 50

执行结果：

![image 74](image-74.png)

---

```Python
#打印系统安装的所有第三方包名：
adb shell pm list packages -3
```

执行结果：

![image 28](image-28.png)

---

```Python
#清理应用缓存数据：
adb shell pm clear pkgName
```

---

### 3\.3\.2 查看Jit中profiles生成的热点函数信息文件

```Python
adb shell cmd package dump-profiles com.taobao.taobao
adb pull data/misc/profman/
```

```Python
// 1.dump应用的profile文件
adb shell pm snapshot-profile com.ss.android.article.news

Profile saved to '/data/misc/profman/com.ss.android.article.news.prof'

// 2.导出profile文件
adb pull /data/misc/profman/com.ss.android.article.news.prof
```

profile文件生成和pull

### 3\.3\.3 查看oatdump：

[get\_oatdump\.sh](图片和附件/get_oatdump.sh)

使用查看boot image信息

```Python
adb shell oatdump --boot-
image=/apex/com.android.art/javalib/boot.art:/system/framework/boot-framework.art --
image=system/framework/arm64/boot-framework.art
```

### 3\.3\.4 单独添加dexdump示例



## 3\.4 simpleperf工具

**simpleperf** 是 Google 为 Android 平台开发的一套 **性能剖析（profiling）工具，通过simpleperf工具可以很好的帮助我们分析虚拟机中的各部分开销情况**

**1\.下载Android NDK**

https://developer\.android\.com/ndk/downloads?hl=zh\-cn

**2\.进入工具目录**

```Shell
cd **android-ndk-r27c/simpleperf/**
```

### **3\.4\.1 抓取冷启动simpleperf文件**

注：生成\.data的文件，命名可根据需要更改，如生成perf\.data：

```Shell
// Host调研抓取方式
# python3 app_profiler.py -p <package> --launch -o perf.data
python3 app_profiler.py -p com.ss.android.ugc.aweme --launch -o perf.data
// 终端抓取方式
adb shell simpleperf record --duration 20 -g -o /data/local/traces/perf.data --app com.phoenix.read
adb pull /data/local/traces/perf.data
// 解析生成html可视化网页（**注意必须Python3.9及以上版本**）
python3 report_html.py -i perf.data -o report.html --ndk_path /home/yanmin/Android/tool/simpleperf/android-ndk-r27d
// 如果出现report.html在浏览器一直转圈圈打不开的话，把html文件的头可以改成下面，我改成下面很快就打开了  
<html><head><link rel="stylesheet" type="text/css" href="[https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.2/css/bootstrap.min.css](https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.2/css/bootstrap.min.css)"></link>
<link rel="stylesheet" type="text/css" href="[https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap4.min.css](https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap4.min.css)"></link>
<script src="[https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js](https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js)"></script>
<script src="[https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js](https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js)"></script>
<script src="[https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.2/js/bootstrap.min.js](https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.2/js/bootstrap.min.js)"></script>
<script src="[https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js](https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js)"></script>
<script src="[https://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js](https://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js)"></script>
<script src="[https://www.gstatic.com/charts/loader.js](https://www.gstatic.com/charts/loader.js)"></script>
```

### **3\.4\.2 解析主线程simpleperf**

抓到的数据是perf\.data，用perfetto ui打开，找到主线程tid，如图tid为4761

![img_v3_02s6_7fd55ca9-0bc4-4075-846e-52044a1f030g](img_v3_02s6_7fd55ca9-0bc4-4075-846e-52044a1f030g.jpg)

![img_v3_02s6_4ea6055d-722c-4f28-a935-89a8e6f7dbdg](img_v3_02s6_4ea6055d-722c-4f28-a935-89a8e6f7dbdg.jpg)

```Shell
# python3 report.py --sort dso -i perf.data --tids <tid>
python3 report.py --sort dso -i perf.data --tids 4761 > a.txt
```

获取到tid后可以解析simpleperf文件

### **3\.4\.3 解析libart\.so**

```Shell
# python3 report.py --dsos <library.so> --sort symbol --tids <tid>
# 若不选择输出到文件中，会将解析内容dump到终端
python3 report.py --dsos /apex/com.android.art/lib64/libart.so --sort symbol --tids 4761
```

默认解析perf\.data文件，可使用\-i \{dir\}自行制定perf文件，如：

```Shell
# python3 report.py --dsos <library.so> --sort symbol --tids <tid>
python3 report.py -i perf.data --dsos /apex/com.android.art/lib64/libart.so --sort symbol --tids 4761
```

可将解析内容输出到txt文件中方便查看

```Shell
python3 report.py -perf.data --dsos /apex/com.android.art/lib64/libart.so --sort symbol --tids 4761 > out.txt
```



---

## 3\.5 Java Heap 内存分析

### 3\.5\.1 heap\_profile

首先确保刷机的版本是userdebug，否则无法抓到三方app的Java Heap信息

![image 3](image-3.png)

#### 3\.5\.1\.1 Java heap sampling

**主要解决内存抖动问题**

Java heap sampling抓取的是创建对象堆栈的采样（采样大小默认是4KB）

https://perfetto\.dev/docs/data\-sources/native\-heap\-profiler\#java\-heap\-sampling

```Shell
tools/heap_profile --name com.ss.android.ugc.aweme --heaps com.android.art --continuous-dump 1000 --duration 10000
```

- \-\-name com\.ss\.android\.ugc\.aweme 指定抓取的应用

- \-\-heaps com\.android\.art 指定Java Heap

- \-\-continuous\-dump 1000 1s抓一次采样

- \-\-duration 10000 连续抓10s

- \-\-interval 采样的大小，默认是4096 \(4KiB\)

![image 27](image-27.png)

[raw\-trace](图片和附件/raw-trace)

#### 3\.5\.1\.2 Java heap dump

**主要解决内存泄漏问题**

Java heap dump抓取的是当前Java heap的快照，不包括堆栈信息，slice堆叠表现为对象间引用关系，注意和Java heap smpling区分

https://perfetto\.dev/docs/data\-sources/java\-heap\-profiler

```Shell
tools/java_heap_dump -n com.ss.android.ugc.aweme
```

- \-\-continuous\-dump 5000 5s抓一次dump

- \-\-wait\-for\-oom 打开tracing直到发生OOM

- \-\-output FILE 

![image 25](image-25.png)

#### 3\.5\.1\.3 No profiles generated

抓不到Java heap sampling可能存在的问题：

1. 确保刷的包是userdebug

2. 使用 adb shell su root setenforce 0 关闭SELinux

3. 去应用商店下载一个新的app

### 3\.5\.2 ReportSample

在AllocWithNewTLAB打点

```C++
mirror::Object* Heap::AllocWithNewTLAB(Thread* self,
                                       AllocatorType allocator_type,
                                       size_t alloc_size,
                                       bool grow,
                                       size_t* bytes_allocated,
                                       size_t* usable_size,
                                       size_t* bytes_tl_bulk_allocated) {
  mirror::Object* ret = nullptr;
  bool take_sample = false;
  size_t bytes_until_sample = 0;
  bool jhp_enabled = GetHeapSampler().IsEnabled();
  ...
  // JavaHeapProfiler: Send the thread information about this allocation in case a sample is
  // requested.
  // This is the fallthrough from both the if and else if above cases => Cases that use TLAB.
  if (jhp_enabled) {
    if (take_sample) {
      // 参数是object和alloc_size
      GetHeapSampler().ReportSample(ret, alloc_size);
      // Update the bytes_until_sample now that the allocation is already done.
      GetHeapSampler().SetBytesUntilSample(bytes_until_sample);
    }
    VLOG(heap) << "JHP:Fallthrough Tlab allocation";
  }
  return ret;
}

void HeapSampler::ReportSample(art::mirror::Object* obj, size_t allocation_size) {
  VLOG(heap) << "JHP:***Report Perfetto Allocation: alloc_size: " << allocation_size;
  uint64_t perf_alloc_id = reinterpret_cast<uint64_t>(obj);
  VLOG(heap) << "JHP:***Report Perfetto Allocation: obj: " << perf_alloc_id;
#ifdef ART_TARGET_ANDROID
  AHeapProfile_reportSample(perfetto_heap_id_, perf_alloc_id, allocation_size);
#endif
}


__attribute__((visibility("default"))) bool
AHeapProfile_reportSample(uint32_t heap_id, uint64_t id, uint64_t size) {
  const AHeapInfo& heap = GetHeap(heap_id);
  if (!heap.enabled.load(std::memory_order_acquire)) {
    return false;
  }
  ...
  if (!client->RecordMalloc(heap_id, size, size, id)) {
    ShutdownLazy(client);
    return false;
  }
  return true;
}

// [external](https://cs.android.com/android/platform/superproject/main/+/main:external/)/[perfetto](https://cs.android.com/android/platform/superproject/main/+/main:external/perfetto/)/[src](https://cs.android.com/android/platform/superproject/main/+/main:external/perfetto/src/)/[profiling](https://cs.android.com/android/platform/superproject/main/+/main:external/perfetto/src/profiling/)/[memory](https://cs.android.com/android/platform/superproject/main/+/main:external/perfetto/src/profiling/memory/)/[client.cc](https://cs.android.com/android/platform/superproject/main/+/main:external/perfetto/src/profiling/memory/client.cc)
// The stack grows towards numerically smaller addresses, so the stack layout
// of main calling malloc is as follows.
//
//               +------------+
//               |SendWireMsg |
// stackptr +--> +------------+ 0x1000
//               |RecordMalloc|    +
//               +------------+    |
//               | malloc     |    |
//               +------------+    |
//               |  main      |    v
// stackend  +-> +------------+ 0xffff
bool Client::RecordMalloc(uint32_t heap_id,
                          uint64_t sample_size,
                          uint64_t alloc_size,
                          uint64_t alloc_address) {
  if (PERFETTO_UNLIKELY(IsPostFork())) {
    return postfork_return_value_;
  }
  AllocMetadata metadata;
  // By the difference between calling conventions, the frame pointer might
  // include the current frame or not. So, using __builtin_frame_address()
  // on specific architectures such as riscv can make stack unwinding failed.
  // Thus, using __builtin_stack_address() or reading the stack pointer in
  // register data directly instead of using __builtin_frame_address() on riscv.
#if PERFETTO_BUILDFLAG(PERFETTO_ARCH_CPU_RISCV)
#if PERFETTO_HAS_BUILTIN_STACK_ADDRESS()
  const char* stackptr = reinterpret_cast<char*>(__builtin_stack_address());
  unwindstack::AsmGetRegs(metadata.register_data);
#else
  char* register_data = metadata.register_data;
  unwindstack::AsmGetRegs(register_data);
  const char* stackptr = reinterpret_cast<char*>(
      GetStackAddress(register_data, unwindstack::Regs::CurrentArch()));
  if (!stackptr) {
    PERFETTO_ELOG("Failed to get stack address.");
    shmem_.SetErrorState(SharedRingBuffer::kInvalidStackBounds);
    return false;
  }
#endif /* PERFETTO_HAS_BUILTIN_STACK_ADDRESS() */
#else
  // 这里拿到callback信息
  const char* stackptr = reinterpret_cast<char*>(__builtin_frame_address(0));
  unwindstack::AsmGetRegs(metadata.register_data);
#endif /* PERFETTO_BUILDFLAG(PERFETTO_ARCH_CPU_RISCV) */
  const char* stackend = GetStackEnd(stackptr);
  if (!stackend) {
    PERFETTO_ELOG("Failed to find stackend.");
    shmem_.SetErrorState(SharedRingBuffer::kInvalidStackBounds);
    return false;
  }
  uint64_t stack_size = static_cast<uint64_t>(stackend - stackptr);
  metadata.sample_size = sample_size;
  metadata.alloc_size = alloc_size;
  metadata.alloc_address = alloc_address;
  metadata.stack_pointer = reinterpret_cast<uint64_t>(stackptr);
  metadata.arch = unwindstack::Regs::CurrentArch();
  metadata.sequence_number =
      1 + sequence_number_[heap_id].fetch_add(1, std::memory_order_acq_rel);
  metadata.heap_id = heap_id;

  struct timespec ts;
  if (clock_gettime(CLOCK_MONOTONIC_COARSE, &ts) == 0) {
    metadata.clock_monotonic_coarse_timestamp =
        static_cast<uint64_t>(base::FromPosixTimespec(ts).count());
  } else {
    metadata.clock_monotonic_coarse_timestamp = 0;
  }

  WireMessage msg{};
  msg.record_type = RecordType::Malloc;
  msg.alloc_header = &metadata;
  msg.payload = const_cast<char*>(stackptr);
  msg.payload_size = static_cast<size_t>(stack_size);

  if (SendWireMessageWithRetriesIfBlocking(msg) == -1)
    return false;

  if (!shmem_.GetAndResetReaderPaused())
    return true;
  return SendControlSocketByte();
}

```

---

## 3\.6 GC调试

**监测GC**

```Python
adb logcat | grep "sticky GC"
```

如果发生GC会有关键字“sticky GC”的日志，并且可以看到当前最大堆和最小堆大小

```Python
09-08 19:48:17.591  9703  9725 I com.miui.home: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:17.745  5273  5273 I dex2oat64: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:17.965 11131 11150 I FuseDaemon: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:17.975 29450 29464 I om.miui.gallery: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:18.123  1995  2009 I com.miui.hybrid: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:18.289 11131 11150 I FuseDaemon: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:18.458  3825  4013 I system_server: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:18.476 29450 29464 I om.miui.gallery: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:18.512  1761  1781 I android.browser: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:18.633   562   582 I iui.micloudsync: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:18.776 11131 11150 I FuseDaemon: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:18.897 11131 11150 I FuseDaemon: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:18.909 29450 29464 I om.miui.gallery: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:19.129 11131 11150 I FuseDaemon: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:19.281 29450 29464 I om.miui.gallery: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:19.428  3825  4013 I system_server: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:19.760 15602 15629 I id.ext.services: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:19.799 29450 29464 I om.miui.gallery: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:19.809 11131 11150 I FuseDaemon: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:20.410 11875 11922 I .miui.analytics: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:20.488 29450 29464 I om.miui.gallery: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:20.616 11131 11150 I FuseDaemon: This is non sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:20.765 29450 29464 I om.miui.gallery: This is sticky GC, maxfree is 33554432 minfree is 8388608
09-08 19:48:20.782  3825  4013 I system_server: This is non sticky GC, maxfree is 33554432 minfree is 8388608
```

**打印GC日志：**

```Python
adb logcat | grep concurrent copying GC
```

**使用 SIGQUIT 获取 GC 性能信息**

如需获得应用的 GC 性能时序，请将 `SIGQUIT` 发送到已在运行的应用，或者在启动命令行程序时将 `-XX:DumpGCPerformanceOnShutdown` 传递给 `dalvikvm`。当应用获得 ANR 请求信号 \(`SIGQUIT`\) 时，会转储与其锁定、线程堆栈和 GC 性能相关的信息。

如需获得 GC 时序转储，请使用以下命令：

```Python
adb shell kill -s QUIT PID
```

这会在 `/data/anr/` 中创建一个文件（名称中会包含日期和时间，例如 anr\_2020\-07\-13\-19\-23\-39\-817）。此文件包含一些 ANR 转储信息以及 GC 时序。您可以通过搜索“Dumping cumulative Gc timings”（转储累计 GC 时序）来确定 GC 时序。这些时序会显示一些需要关注的内容，包括每个 GC 类型的阶段和暂停时间的直方图信息。暂停信息通常比较重要。例如：

```Python
young concurrent copying paused:        Sum: 5.491ms 99% C.I. 1.464ms-2.133ms Avg: 1.830ms Max: 2.133ms
```

本示例中显示平均暂停时间为 1\.83 毫秒，该值应该足够低，在大多数应用中不会导致丢帧，因此不必担心。

需要关注的另一个方面是挂起时间，挂起时间测量在 GC 要求某个线程挂起后，该线程到达挂起点所需的时间。此时间包含在 GC 暂停时间中，所以对于确定长时间暂停是由 GC 缓慢还是线程挂起缓慢造成的很有用。以下是 Nexus 5 上的正常挂起时间示例：

```Python
suspend all histogram:        Sum: 1.513ms 99% C.I. 3us-546.560us Avg: 47.281us Max: 601us
```

还有其他一些需要关注的方面，包括总耗时和 GC 吞吐量。示例：

```Python
Total time spent in GC: 502.251ms
Mean GC size throughput: 92MB/s
Mean GC object throughput: 1.54702e+06 objects/s

```

以下示例说明了如何转储已在运行的应用的 GC 时序：

```Python
adb shell kill -s QUIT PID
adb pull /data/anr/anr_2020-07-13-19-23-39-817
```

此时，GC 时序在 `anr_2020-07-13-19-23-39-817` 中。以下是 Google 地图的输出示例：解析日志

```Python
Start Dumping histograms for 2195 iterations for concurrent copying
MarkingPhase:   Sum: 258.127s 99% C.I. 58.854ms-352.575ms Avg: 117.651ms Max: 641.940ms
ScanCardsForSpace:      Sum: 85.966s 99% C.I. 15.121ms-112.080ms Avg: 39.164ms Max: 662.555ms
ScanImmuneSpaces:       Sum: 79.066s 99% C.I. 7.614ms-57.658ms Avg: 18.014ms Max: 546.276ms
ProcessMarkStack:       Sum: 49.308s 99% C.I. 6.439ms-81.640ms Avg: 22.464ms Max: 638.448ms
ClearFromSpace: Sum: 35.068s 99% C.I. 6.522ms-40.040ms Avg: 15.976ms Max: 633.665ms
SweepSystemWeaks:       Sum: 14.209s 99% C.I. 3.224ms-15.210ms Avg: 6.473ms Max: 201.738ms
CaptureThreadRootsForMarking:   Sum: 11.067s 99% C.I. 0.835ms-13.902ms Avg: 5.044ms Max: 25.565ms
VisitConcurrentRoots:   Sum: 8.588s 99% C.I. 1.260ms-8.547ms Avg: 1.956ms Max: 231.593ms
ProcessReferences:      Sum: 7.868s 99% C.I. 0.002ms-8.336ms Avg: 1.792ms Max: 17.376ms
EnqueueFinalizerReferences:     Sum: 3.976s 99% C.I. 0.691ms-8.005ms Avg: 1.811ms Max: 16.540ms
GrayAllDirtyImmuneObjects:      Sum: 3.721s 99% C.I. 0.622ms-6.702ms Avg: 1.695ms Max: 14.893ms
SweepLargeObjects:      Sum: 3.202s 99% C.I. 0.032ms-6.388ms Avg: 1.458ms Max: 549.851ms
FlipOtherThreads:       Sum: 2.265s 99% C.I. 0.487ms-3.702ms Avg: 1.031ms Max: 6.327ms
VisitNonThreadRoots:    Sum: 1.883s 99% C.I. 45us-3207.333us Avg: 429.210us Max: 27524us
InitializePhase:        Sum: 1.624s 99% C.I. 231.171us-2751.250us Avg: 740.220us Max: 6961us
ForwardSoftReferences:  Sum: 1.071s 99% C.I. 215.113us-2175.625us Avg: 488.362us Max: 7441us
ReclaimPhase:   Sum: 490.854ms 99% C.I. 32.029us-6373.807us Avg: 223.623us Max: 362851us
EmptyRBMarkBitStack:    Sum: 479.736ms 99% C.I. 11us-3202.500us Avg: 218.558us Max: 13652us
CopyingPhase:   Sum: 399.163ms 99% C.I. 24us-4602.500us Avg: 181.851us Max: 22865us
ThreadListFlip: Sum: 295.609ms 99% C.I. 15us-2134.999us Avg: 134.673us Max: 13578us
ResumeRunnableThreads:  Sum: 238.329ms 99% C.I. 5us-2351.250us Avg: 108.578us Max: 10539us
ResumeOtherThreads:     Sum: 207.915ms 99% C.I. 1.072us-3602.499us Avg: 94.722us Max: 14179us
RecordFree:     Sum: 188.009ms 99% C.I. 64us-312.812us Avg: 85.653us Max: 2709us
MarkZygoteLargeObjects: Sum: 133.301ms 99% C.I. 12us-734.999us Avg: 60.729us Max: 10169us
MarkStackAsLive:        Sum: 127.554ms 99% C.I. 13us-417.083us Avg: 58.111us Max: 1728us
FlipThreadRoots:        Sum: 126.119ms 99% C.I. 1.028us-3202.499us Avg: 57.457us Max: 11412us
SweepAllocSpace:        Sum: 117.761ms 99% C.I. 24us-400.624us Avg: 53.649us Max: 1541us
SwapBitmaps:    Sum: 56.301ms 99% C.I. 10us-125.312us Avg: 25.649us Max: 1475us
(Paused)GrayAllNewlyDirtyImmuneObjects: Sum: 33.047ms 99% C.I. 9us-49.931us Avg: 15.055us Max: 72us
(Paused)SetFromSpace:   Sum: 11.651ms 99% C.I. 2us-49.772us Avg: 5.307us Max: 71us
(Paused)FlipCallback:   Sum: 7.693ms 99% C.I. 2us-32us Avg: 3.504us Max: 32us
(Paused)ClearCards:     Sum: 6.371ms 99% C.I. 250ns-49753ns Avg: 207ns Max: 188000ns
Sweep:  Sum: 5.793ms 99% C.I. 1us-49.818us Avg: 2.639us Max: 93us
UnBindBitmaps:  Sum: 5.255ms 99% C.I. 1us-31us Avg: 2.394us Max: 31us
Done Dumping histograms
concurrent copying paused:      Sum: 315.249ms 99% C.I. 49us-1378.125us Avg: 143.621us Max: 7722us
concurrent copying freed-bytes: Avg: 34MB Max: 54MB Min: 2062KB
Freed-bytes histogram: 0:4,5120:5,10240:19,15360:69,20480:167,25600:364,30720:529,35840:405,40960:284,46080:311,51200:38
concurrent copying total time: 569.947s mean time: 259.657ms
concurrent copying freed: 1453160493 objects with total size 74GB
concurrent copying throughput: 2.54964e+06/s / 134MB/s  per cpu-time: 157655668/s / 150MB/s
Average major GC reclaim bytes ratio 0.486928 over 2195 GC cycles
Average major GC copied live bytes ratio 0.0894662 over 2199 major GCs
Cumulative bytes moved 6586367960
Cumulative objects moved 127490240
Peak regions allocated 376 (94MB) / 2048 (512MB)
Start Dumping histograms for 685 iterations for young concurrent copying
ScanCardsForSpace:      Sum: 26.288s 99% C.I. 8.617ms-77.759ms Avg: 38.377ms Max: 432.991ms
ProcessMarkStack:       Sum: 21.829s 99% C.I. 2.116ms-71.119ms Avg: 31.868ms Max: 98.679ms
ClearFromSpace: Sum: 19.420s 99% C.I. 5.480ms-50.293ms Avg: 28.351ms Max: 507.330ms
ScanImmuneSpaces:       Sum: 9.968s 99% C.I. 8.155ms-30.639ms Avg: 14.552ms Max: 46.676ms
SweepSystemWeaks:       Sum: 6.741s 99% C.I. 3.655ms-14.715ms Avg: 9.841ms Max: 22.142ms
GrayAllDirtyImmuneObjects:      Sum: 4.466s 99% C.I. 0.584ms-14.315ms Avg: 6.519ms Max: 24.355ms
FlipOtherThreads:       Sum: 3.672s 99% C.I. 0.631ms-16.630ms Avg: 5.361ms Max: 18.513ms
ProcessReferences:      Sum: 2.806s 99% C.I. 0.001ms-9.459ms Avg: 2.048ms Max: 11.951ms
EnqueueFinalizerReferences:     Sum: 1.857s 99% C.I. 0.424ms-8.609ms Avg: 2.711ms Max: 24.063ms
VisitConcurrentRoots:   Sum: 1.094s 99% C.I. 1.306ms-5.357ms Avg: 1.598ms Max: 6.831ms
SweepArray:     Sum: 711.032ms 99% C.I. 0.022ms-3.502ms Avg: 1.038ms Max: 7.307ms
InitializePhase:        Sum: 667.346ms 99% C.I. 303us-2643.749us Avg: 974.227us Max: 3199us
VisitNonThreadRoots:    Sum: 388.145ms 99% C.I. 103.911us-1385.833us Avg: 566.635us Max: 5374us
ThreadListFlip: Sum: 202.730ms 99% C.I. 18us-2414.999us Avg: 295.956us Max: 6780us
EmptyRBMarkBitStack:    Sum: 132.934ms 99% C.I. 8us-1757.499us Avg: 194.064us Max: 8495us
ResumeRunnableThreads:  Sum: 109.593ms 99% C.I. 6us-4719.999us Avg: 159.989us Max: 11106us
ResumeOtherThreads:     Sum: 86.733ms 99% C.I. 3us-4114.999us Avg: 126.617us Max: 19332us
ForwardSoftReferences:  Sum: 69.686ms 99% C.I. 14us-2014.999us Avg: 101.731us Max: 4723us
RecordFree:     Sum: 58.889ms 99% C.I. 0.500us-185.833us Avg: 42.984us Max: 769us
FlipThreadRoots:        Sum: 58.540ms 99% C.I. 1.034us-4314.999us Avg: 85.459us Max: 10224us
CopyingPhase:   Sum: 52.227ms 99% C.I. 26us-728.749us Avg: 76.243us Max: 2060us
ReclaimPhase:   Sum: 37.207ms 99% C.I. 7us-2322.499us Avg: 54.316us Max: 3826us
(Paused)GrayAllNewlyDirtyImmuneObjects: Sum: 23.859ms 99% C.I. 11us-98.917us Avg: 34.830us Max: 128us
FreeList:       Sum: 20.376ms 99% C.I. 2us-188.875us Avg: 29.573us Max: 998us
MarkZygoteLargeObjects: Sum: 18.970ms 99% C.I. 4us-115.749us Avg: 27.693us Max: 122us
(Paused)SetFromSpace:   Sum: 12.331ms 99% C.I. 3us-94.226us Avg: 18.001us Max: 109us
SwapBitmaps:    Sum: 11.761ms 99% C.I. 5us-49.968us Avg: 17.169us Max: 67us
ResetStack:     Sum: 4.317ms 99% C.I. 1us-64.374us Avg: 6.302us Max: 190us
UnBindBitmaps:  Sum: 3.803ms 99% C.I. 4us-49.822us Avg: 5.551us Max: 70us
(Paused)ClearCards:     Sum: 3.336ms 99% C.I. 250ns-7000ns Avg: 347ns Max: 7000ns
(Paused)FlipCallback:   Sum: 3.082ms 99% C.I. 1us-30us Avg: 4.499us Max: 30us
Done Dumping histograms
young concurrent copying paused:        Sum: 229.314ms 99% C.I. 37us-2287.499us Avg: 334.764us Max: 6850us
young concurrent copying freed-bytes: Avg: 44MB Max: 50MB Min: 9132KB
Freed-bytes histogram: 5120:1,15360:1,20480:6,25600:1,30720:1,35840:9,40960:235,46080:427,51200:4
young concurrent copying total time: 100.823s mean time: 147.187ms
young concurrent copying freed: 519927309 objects with total size 30GB
young concurrent copying throughput: 5.15683e+06/s / 304MB/s  per cpu-time: 333152554/s / 317MB/s
Average minor GC reclaim bytes ratio 0.52381 over 685 GC cycles
Average minor GC copied live bytes ratio 0.0512109 over 685 minor GCs
Cumulative bytes moved 1542000944
Cumulative objects moved 28393168
Peak regions allocated 376 (94MB) / 2048 (512MB)
Total time spent in GC: 670.771s
Mean GC size throughput: 159MB/s per cpu-time: 177MB/s
Mean GC object throughput: 2.94152e+06 objects/s
Total number of allocations 1974199562
Total bytes allocated 104GB
Total bytes freed 104GB
Free memory 10MB
Free memory until GC 10MB
Free memory until OOME 442MB
Total memory 80MB
Max memory 512MB
Zygote space size 2780KB
Total mutator paused time: 544.563ms
Total time waiting for GC to complete: 117.494ms
Total GC count: 2880
Total GC time: 670.771s
Total blocking GC count: 1
Total blocking GC time: 86.373ms
Histogram of GC count per 10000 ms: 0:259879,1:2828,2:24,3:1
Histogram of blocking GC count per 10000 ms: 0:262731,1:1
Native bytes total: 30599192 registered: 8947416
Total native bytes at last GC: 30344912
```

添加gc过程日志

---

### trace中GC信息查询：

```Plain Text
INCLUDE PERFETTO MODULE android.garbage_collection;
SELECT * from android_garbage_collection_events;
```

用这个SQL命令可以在trace里查到每次GC具体的回收信息

![image](image)

## 3\.7 使用LLDB调试ART

### 3\.7\.1 前提

- 参考本文档本地编译章节,在工程云上编译userdebug版本art/dex2oat 等target

- 本地lldb可正常运行, 如遇到找不到python动态库, 需要自己编译对应版本的python

- 手机终端已经刷机,adb 有root权限,开启tcp链接,本文档1\.2章节有具体操作

- 工程云adb已经attach到手机终端

**注意**

如果是windows,建议安装wsl和android studio\. 

- wsl是为了比较友好的shell操作\.

- Android studio是为了安装adb等工具,然后在wsl中使用

安装了android studio ide之后, 在wsl 终端中cd 到`adb.exe` 所在目录, `cp adb.exe adb` 重命名一下,然后配置环境变量\.   可参考:

```Shell
/home/wujiahua/temp $ which adb
/mnt/d/Users/wujiahua/AppData/Local/Programs/android/SDK/platform-tools/adb
```

### 3\.7\.2 部署 lldb server

aosp 工程目录下有对应的lldb\-server和lldb 二进制文件, 调试android中的cpp代码,要使用lldb server模式。

使用下面脚本把`lldb-server` push到手机终端中。



`lldb-server` 我是通过下面命令找到的

```Bash
# 在项目根目录下执行
find . -name lldb-server | grep aarch
#./prebuilts/clang/host/linux-x86/clang-r530567/runtimes_ndk_cxx/aarch64/lldb-server
#./prebuilts/clang/host/linux-x86/clang-r547379/runtimes_ndk_cxx/aarch64/lldb-server
#./prebuilts/clang/host/linux-x86/clang-r536225/runtimes_ndk_cxx/aarch64/lldb-server
#./prebuilts/clang/host/linux-x86/clang-r522817/runtimes_ndk_cxx/aarch64/lldb-server
```

```Shell
#项目根目录下
adb push ./prebuilts/clang/host/linux-x86/clang-r530567/runtimes_ndk_cxx/aarch64/lldb-server /data/local/tmp

```



### 3\.7\.3 测试lldb

**在终端云或者本地执行**

```Shell
./prebuilts/clang/host/linux-x86/clang-r530567/bin/lldb
```

如果正常进入lldb交互环境,说明正常\. 如果报错,根据实际情况解决\.

我遇到的错误是找不到libpython\.so这个动态库\.

**编译安装python**

```Bash
cd /tmp/
export PYTHON_PREFIX=/home/docker/opt/python/3.11.1/
# 注意要根据实际报错找对应的python版本
wget https://www.python.org/ftp/python/3.11.1/Python-3.11.1.tgz
tar xzf Python-3.11.1.tgz
cd Python-3.11.1

./configure --prefix=$PYTHON_PREFIX  --enable-shared  --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi --with-openssl=/usr/
make -j 32
make altinstall

rm /tmp/Python-3.11.1.tgz

```

打开`~/.bashrc` 设置`LD_LIBRARY_PATH`

具体路径就是上面编译构建python的时候自定的`prefix`



```Shell
export LD_LIBRARY_PATH=/home/docker/opt/python3.11/lib:$LD_LIBRARY_PATH
```

注意: 要重新登录 python才会生效



### 3\.7\.4 实战1：编译APK

1. 启动 lldb\-server

```Shell
adb shell '/data/local/tmp/lldb-server p --server --listen unix-abstract:///data/local/tmp/debug.sock'
```

2. attach lldb

工程云上操作

```Shell
./prebuilts/clang/host/linux-x86/clang-r530567/bin/lldb

```

然后执行

```Shell
platform select remote-android
platform connect unix-abstract-connect:///data/local/tmp/debug.sock
process attach --name "dex2oat64" --waitfor # 等待dex2oat二进制被执行


```

3. 启动编译任务

在一个新的终端执行下面adb命令

```Shell
adb shell pm compile -m speed -f com.xiaomi.wujiahua.demo
```

4. 回到lldb 调式窗口

可以看到已经开始调试, 能看到一些汇编代码\.

然后继续执行下面命令

```Shell
# 添加调试符号, 手机终端上的二进制都被stripped,必须通过下面命令添加
target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/bin/dex2oat64 
target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/lib64/libart.so
# libart.so也要加上,二进制文件只是driver,核心代码还是在libart.so中

# 设置断点
b art::Dex2Oat::Compile 
# continue，输入 字母 c
c
```

效果如下

![image 43](image-43.png)

注意1: 打断点不知道方法的qualified name，可以打开下面链接,找到对应的方法

https://cs\.android\.com/android/platform/superproject/main/\+/main:art/dex2oat/dex2oat\.cc;l=1841;drc=1abd2dcf05420499e95d91ed83d4c8de4a6c4c0d

右键复制qualified name 即可

![image 64](image-64.png)

注意2: `adb shell pm compile` 是通过artd拉起的dex2oat，有timeout机制,如果lldb调试时间太长,dex2oat会被系统自动kill,没法继续debug

### 3\.7\.5 实现2：编译Dex

1. 启动 lldb\-server

```Shell
adb shell '/data/local/tmp/lldb-server p --server --listen unix-abstract:///data/local/tmp/debug.sock'
```

2. attach lldb

工程云上操作

```Shell
./prebuilts/clang/host/linux-x86/clang-r530567/bin/lldb

```

然后执行

```Shell
platform select remote-android
platform connect unix-abstract-connect:///data/local/tmp/debug.sock
process attach --name "dex2oat64" --waitfor # 等待dex2oat二进制被执行
```

3. 启动编译任务

通过一下脚本准备一个简单的dex文件

- D8路径要修改

- JAVAC要修改

- JAR要修改

- 还有两个java文件

```Java
public class Caller {
    public static void main(String[] *args*) {
        System.out.println("hello dex2oat!");
    }
}

```

```Java
public class Callee {
    public static void hello() {
        System.out.println("hello dex2oat!");
    }
}

```

```Bash
*#!/bin/bash*
D8=/home/docker/Android/Sdk/build-tools/36.0.0/d8
JAVAC=/usr/bin/javac
JAR=/usr/bin/jar
 
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

cd $SCRIPT_DIR/

rm -rf ./out/
mkdir ./out/
rm -rf *.dex
rm -rf *.jar
rm -rf *.class

$JAVAC Caller.java 
$JAVAC Callee.java

$JAR cf Callee.jar Callee.class
$JAR cf Caller.jar Caller.class

$D8 Callee.jar --output ./out/
mv ./out/classes.dex ./Callee.dex

$D8 Caller.jar --output ./out/
mv ./out/classes.dex ./Caller.dex

adb push  ./Callee.dex /data/local/tmp/
adb push  ./Caller.dex /data/local/tmp/

cd -
```

在一个新的终端执行下面adb命令



```Shell
adb shell 'dex2oat64 --dex-file=/data/local/tmp/Caller.dex  --compiler-filter=speed --oat-file=/data/local/tmp/Caller.odex'
```

4. 回到lldb 调式窗口

可以看到已经开始调试, 能看到一些汇编代码\.

然后继续执行下面命令

```Shell
# 添加调试符号, 手机终端上的二进制都被stripped,必须通过下面命令添加
target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/bin/dex2oat64 
target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/lib64/libart.so
# 设置断点，如何 打断点参考上一节的调试操
b art::Dex2Oat::Compile 
# continue，输入 字母 c
c
```

注意，这个方式不是artd拉起的,应该没有timeout机制,可以长时间debug



### 3\.7\.6 实战3：调试artd

这里调试已经存在的进程，这里选择artd,也可以是一个运行中的app,需要知道进程pid

1. 启动 lldb\-server

```Shell
adb shell '/data/local/tmp/lldb-server p --server --listen unix-abstract:///data/local/tmp/debug.sock'
```

2. attach lldb

工程云上操作

```Shell
./prebuilts/clang/host/linux-x86/clang-r530567/bin/lldb
```

然后执行

```Shell
platform select remote-android
platform connect unix-abstract-connect:///data/local/tmp/debug.sock
```

3. 确定pid

在一个新的终端执行下面adb命令

```Shell
adb shell ps -A | grep artd
```

4. 回到lldb调试窗口

根据上面的pid，执行

```Shell
platform process attach -p 6269

target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/bin/artd

target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/lib64/libart.so

# todo 打断点,触发业务逻辑: 比如终端发起一个apk编译任务
```

### 3\.7\.7 参考

[https://comsoftwhu.github.io/aosp/AndroidRuntime/testAndDebug.html#1-%E7%8E%AF%E5%A2%83%E5%87%86%E5%A4%87]()



### 3\.7\.8 lldb技巧

#### 3\.7\.8\.1 自动化

lldb 客户端连接到lldb server要执行好几条命令，反复copy and paste 影响效率, 创建\~/\.lldbinit文件,复制如下内容，注意路径要根据自己实际环境修改

```Shell
platform select remote-android

platform connect unix-abstract-connect:///data/local/tmp/debug.sock

# 这里会卡住,等待dex2oat被拉起,如果不是这个模式,不要添加这个
process attach --name "dex2oat64" --waitfor 

target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/bin/dex2oat64 

target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/lib64/libart.so

b art::Dex2Oat::Compile
b CompiledMethod::CompiledMethod
b OptimizingCompiler::Compile

c
```

#### 3\.7\.8\.2 lldb 常用命令

```Shell
# 显示所有breakpoint, -v 是verbose
breakpoint list # br l # br l -v 
# 删除 某个breakpoint
breakpoint delete $id # br d $id
br d # delete all 
# 启用禁用某个断电
breakpoint disable <id> # br dis <id>
breakpoint enable <id> # br en <id>

# 打断点
break art::Dex2Oat::Compile
b CompiledMethod::CompiledMethod
# 临时断点
tbreak  OptimizingCompiler::Compile

# 控制执行流
c # continue
n # next
s # step in

# 添加调试符号
# 很多debug版本的c/cpp是没有被stripped,有debug info.
# android 可能是处于磁盘空间的考虑，userdebug出的elf的二进制文件都被stripped
# 需要通过一下命令添加debug info,关联cpp源代码

target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/bin/dex2oat64 

target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/lib64/libart.so


# 查看线程列表
thread list
# 选中某个线程
thread select $id
# 选中某个frame
frame select $id

# 查看变量
frame variable
frame variable -g
# call stack trace
bt

# 查看源代码
list

# 反汇编
dis -s $pc
dis -s $pc -c 8 # 只看8条指令
dis -s $pc-80
dis -s $pc-0x80


# 查看寄存器的值
reg read
# 进制打印某个寄存器的值
p/x $x0
```

#### 3\.7\.8\.3 debug dex2oat的lldbinit内容

注意路徑修改

```C++
platform select remote-android

platform connect unix-abstract-connect:///data/local/tmp/debug.sock

process attach --name "dex2oat64" --waitfor

target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/bin/dex2oat64 

target symbols add /home/docker/code/p16u/out/target/product/missi/symbols/apex/com.android.art.debug/lib64/libart.so

b art::Dex2Oat::Compile
b CompiledMethod::CompiledMethod
b OptimizingCompiler::Compile

b InstructionCodeGeneratorARM64::VisitLoadClass
b LocationsBuilderARM64::VisitLoadClass
b CodeGeneratorARM64::LoadBootImageRelRoEntry
b CompiledMethodStorage::CreateCompiledMethod
b OatWriter::WriteCode
b art::linker::OatWriter::WriteCodeMethodVisitor::VisitMethod

breakpoint set --file oat_writer.cc --line 1710
breakpoint set --file oat_writer.cc --line 1724
breakpoint set --file oat_writer.cc --line 4060 
b Arm64RelativePatcher::PatchPcRelativeReference
b Arm64RelativePatcher::PatchAdrp

c
```

### 3\.7\.9 常见错误

1. adb push art虚拟机报错

```C++
~/c/p16u[1]>adb push out/target/product/missi/system/apex/com.android.art.capex /system/apex/
adb: error: failed to copy 'out/target/product/missi/system/apex/com.android.art.capex' to '/system/apex/com.android.art.capex': remote couldn't create file: Read-only file system
out/target/product/missi/system/apex/com.android.art.capex: 0 files pushed. 6.3 MB/s (3669568 bytes in 0.553s)
```

往/system目录push 文件需要root权限,执行下面命令

```Shell
adb root # 获取root 权限
adb remount # 重新挂载
abd reboot # Now reboot your ddevices for settings to take effect
```

2. Todo

## 3\.8 art镜像调试

### 3\.8\.1 demo

```Java
public class AotICDemo {
  interface Animal {
    int speak();
  }

  static class Dog implements Animal {
    public int speak() {
      return 1;
    }
  }

  static class Cat implements Animal {
    public int speak() {
      return 2;
    }
  }

  static Animal createAnimal(int arg) {
    if (arg > 1000000) {
      return new Cat();
    }
    return new Dog();
  }

  public static int hotMethod(Animal a) {
    return a.speak();
  }

  public static void main(String[] args) {
    int count = Integer.valueOf(args[0]);
    long sum = 0;
    for (int i = 0; i < count; i++) {
      Animal unknownAnimal = createAnimal(i);
      sum += hotMethod(unknownAnimal);
    }
    System.out.println(sum);
  }
}

```

### 3\.8\.2 编译

编译成dex文件

```Bash
#!/bin/bash
ANDROID_HOME=/home/wujiahua/Android
JAVA_HOME=/home/wujiahua/.local/jdk-11
ANDROID_VERSION=36.1.0
D8=$ANDROID_HOME/Sdk/build-tools/$ANDROID_VERSION/d8
JAVAC=$JAVA_HOME/bin/javac
JAR=$JAVA_HOME/bin/jar

rm -rf ./out/
mkdir ./out/
rm -rf *.dex
rm -rf *.jar
rm -rf *.class

$JAVAC $1
$JAR cf demo.jar *.class
$D8 demo.jar --output ./out/
mv ./out/classes.dex ./demo.dex

ls -alh . | grep *.dex

adb push demo.dex /data/local/tmp/

```

编译成odex文件

注意目录结构: oat/arm64

```Bash
adb shell
cd /data/local/tmp
mkdir -p oat/arm64
# odex和art文件除了后缀不一样,其他必须一样
dex2oat \
  --dex-file=demo.dex \
  --oat-file=oat/arm64/demo.odex \
  --app-image-file=oat/arm64/demo.art \
  --compiler-filter=speed \
  --instruction-set=arm64 \
  --resolve-startup-const-strings=true
  
  # 有profile文件, 也可以指定profile
  dex2oat \
  --dex-file=demo.dex \
  --oat-file=oat/arm64/demo.odex \
  --app-image-file=oat/arm64/demo.art \
  --compiler-filter=speed-profile \
  --profile-file=app.prof  \
  --instruction-set=arm64 \
  --resolve-startup-const-strings=true
  
  
```

### 3\.8\.3 执行

```Java
dalvikvm -verbose:class,image -cp demo.dex AotICDemo 200000
# 会自动扫描oat/arm64目录下是是否art镜像和odex二进制代码
```



查看log

```Shell
adb logcat -s dalvikvm # 虽然dalvikvm是dalvikvm64的软链接,但是要写精确的command名称
adb logcat -s dalvikvm64
```

默认尝试从oat/arm64目录下找art文件和odex文件

![image 76](image-76.png)



![image 33](image-33.png)

### 3\.8\.4 dump art

```Java
oatdump --app-image=oat/arm64/demo.art --oat-file=oat/arm64/demo.odex | more
```

在OBJECTS section能看到app class

![image 50](image-50.png)



## 3\.9 dex2oat 调试

dex2oat有一些自己的启动参数,比如控制线程数,比如打印各阶段耗时,比如dump IR\.如果是在adb shell,直接传递即可,但是如果要编译真实的app,得想办法通过adb shell 透传给dex2oat进程\.

- 控制线程数

lldb不方便,通过打印查看某些组件得工作流程,可以设置线程数是1,防止log 错乱\.

```C++
adb shell setprop  dalvik.vm.dex2oat-thread 1
```

- 打印编译耗时

```C++
adb shell setprop dalvik.vm.dex2oat-flags "--dump-stats"
```

![image 63](image-63.png)

- 打印IR

```C++
adb shell 'setprop dalvik.vm.dex2oat-flags "--dump-cfg=/data/local/tmp/dex2oat.cfg"'
```

![image 45](image-45.png)

## 3\.10  profile 调式

构造一个小demo, 通过dalvikvm 启动, 通过jit生成profile文件,然后使用profile文件指导dex2oat 做speed\-profile编译\.

```Java
public class AotICDemo {
    interface Animal {
        int speak();
    }

    static class Dog implements Animal {
        public int speak() {
            return 1;
        }
    }

    static class Cat implements Animal {
        public int speak() {
            return 2;
        }
    }

    static Animal createAnimal(int arg) {
        if (arg > 1000000) {
            return new Cat();
        }
        return new Dog();
    }

    public static int hotMethod(Animal a) {
        return a.speak();
    }

    public static void main(String[] args) {
        int count = Integer.valueOf(args[0]);
        long sum = 0;
        for (int i = 0; i < count; i++) {
            Animal unknownAnimal = createAnimal(i);
            sum += hotMethod(unknownAnimal);
        }
        System.out.println(sum);
    }
}
```

#### 

先使用下面脚本创建dex文件

```Bash
#!/bin/bash
ANDROID_HOME=/home/wujiahua/Android
JAVA_HOME=/home/wujiahua/.local/jdk-11
ANDROID_VERSION=36.1.0
D8=$ANDROID_HOME/Sdk/build-tools/$ANDROID_VERSION/d8
JAVAC=$JAVA_HOME/bin/javac
JAR=$JAVA_HOME/bin/jar

rm -rf ./out/
mkdir ./out/
rm -rf *.dex
rm -rf *.jar
rm -rf *.class

$JAVAC AotICDemo 
$JAR cf demo.jar *.class
$D8 demo.jar --output ./out/
mv ./out/classes.dex ./demo.dex

ls -alh . | grep *.dex

adb push demo.dex /data/local/tmp/

```

然后到/data/local/tmp目录下运行dalvikvm,启动jit,生成profile文件\.

```C++
dalvikvm -cp demo.dex  -Xusejit:true -Xjitsaveprofilinginfo  -Xps-profile-path:app.prof  AotICDemo 200000
```



最后通过下面命令使用profile文件

```C++
dex2oat64 --dex-file=demo.dex --no-watch-dog --compiler-filter=speed-profile --profile-file=app.prof --oat-file=demo.odex -j1 --runtime-arg -verbose:compiler
```

![image 67](image-67.png)

多态inline 成功。



而如果使用speed编译, 则inline失败。

![image 54](image-54.png)

### 3\.11 c1visualizer 查看IR

查看ART IR\.

下载 c1visualizer: 

名称：c1visualizer\-1\.7\.zip

地址：https://kpan\.mioffice\.cn/webfolder/ext/lvYvBxGB5C%23%24uVm31GQvyw%40%40?n=0\.5814392663619927

密码：3P93

下载jdk 1\.8:

名称：zulu8\.90\.0\.19\-ca\-jdk8\.0\.472\-win\_x64\.zip

地址：https://kpan\.mioffice\.cn/webfolder/ext/%24lST2x1lG1r%24uVm31GQvyw%40%40?n=0\.6229758443915041

密码：Wh1w



下载之后，解压出来, 找到etc/c1visualizer\.conf文件\.

![image 56](image-56.png)

设置使用jdk1\.8\.

bin目录下有二进制启动文件\.

![image 12](image-12.png)

dex2oat编译的带上选项: \-\-dump\-cfg=/data/local/tmp/demo\.cfg

adb pull 把cfg文件拿到后直接使用c1visualizer打开\.

![image 31](image-31.png)



然后就可以看某个pass之前和之后的IR了

![image 59](image-59.png)



# 四、调试案例

## **4\.1 类预加载方案在o2s上不生效问题**

近期在O2S开发版上发现大量应用（如微博、百度等）出现类预加载方案失效问题，对此展开调查。

**问题调查**

加入日志代码对方案失效的应用进行追踪（以微博为例），发现方案没有触发的原因是PackagelastUseTime值被置为0，因此无法进入类预加载下一步流程中：

![i8dphwldiy](i8dphwldiy.jpg)

![MmrSmo6WsU](MmrSmo6WsU.jpg)

![image 1](image-1.png)

进一步加入日志发现，在[PackageManagerService](https://gerrit.pt.mioffice.cn/c/platform/frameworks/base/+/5050171/11/services/core/java/com/android/server/pm/PackageManagerService.java)中获取应用的PackagelastUseTime时长为正常值，后在DexOptHelperImpl中执行9秒预编译相关流程时,PackagelastUseTime被置0并且陷入死循环使其一直为0，从而导致类预加载方案失效。

![9HEbdXCbwn](9HEbdXCbwn.jpg)

![b6d34ee4-22f3-4112-b758-19497b77557d 1](b6d34ee4-22f3-4112-b758-19497b77557d-1.jpeg)

**问题原因一**

以京东为例，在应用安装后首次启动时，不等到10s立刻杀掉进程，导致在进程记录ProcessRecord中没有该应用记录，在执行first\-use时会将该应用的PackagelastUseTime设置为0，但是更新PackagelastUseTime的值的位置在first\-use的逻辑中，此时编译状态已变成speed\-profile，无法进入first\-use的逻辑中，因此无法更新PackagelastUseTime的真正值从而陷入死循环。

![191b1f06-881a-4682-9a25-af0bdf9cedbf](191b1f06-881a-4682-9a25-af0bdf9cedbf.jpeg)

![b6d34ee4-22f3-4112-b758-19497b77557d](b6d34ee4-22f3-4112-b758-19497b77557d.jpeg)

**问题原因二**

由于应用启动执行了baseline方案，编译状态已变为speed\-profile，因此在handleFirstUse逻辑中success的值会变为false，而只有success值为true时才会更新PackagelastUseTime的值。在第二次启动应用时，此时save的值已经变为false，因此会将应用的PackagelastUseTime更新为0并不在执行handleFirstUse后续逻辑，从而陷入死循环PackagelastUseTime的值始终为0，无法正常发起类预加载方案。

![image 71](image-71.png)

![jwLfIer7Nh](jwLfIer7Nh.jpg)

![jwLfIer7Nh 1](jwLfIer7Nh-1.jpg)

![oGfPTTrPta](oGfPTTrPta.jpg)

最终调查发现，问题本质原因是重构9秒预编译方案搞乱了应用lastUsageTime的维护逻辑，导致类预加载方案出错。

---

## **4\.2 CloudVerify方案W适配生成vdex文件失败问题**

近期在升W适配Cloud verify方案时，执行脚本时遇到创建vdex文件失败的问题，对此展开掉查：

![image 23](image-23.png)

通过脚本代码发现报错原因应该是未找到vdex文件

在adb shell中查询发现设备上生成了base\.vdex文件，由此判断是primary\.vdex生成失败

![image 75](image-75.png)

在方案代码中发现了打印日志如下

![image 40](image-40.png)

抓取bugreport：

![image 49](image-49.png)

发现是创建文件时没有selinux权限导致创建文件失败

---

**SELinux权限添加**

若报错信息如下：（日志中检索信息“avc: denied”）

avc: denied \{ read write \} for comm="AdaptorThread" name="video31" dev="tmpfs" ino=18586 scontext=u:r:system\_app:s0 tcontext=u:object\_r:video\_device:s0 tclass=chr\_file permissive=0

分析：

缺少的权限：\{ read write \}

谁缺少的权限：system\_app

对哪个类型缺少的权限：video\_device

什么格式的文件：chr\_file

allow system\_app video\_device:chr\_file \{ read write \};

---

由上述权限格式可知，是dex2oat缺少相关的selinux权限，按照格式添加：

```Python
allow dex2oat trace_data_file:dir{ search };
```

![image 29](image-29.png)

并且device/xiaomi/sepolicy仓库的代码在打包时要加入到system中而非product，否则会不生效



经过上述步骤打包后，发现问题仍未解决，

![image 69](image-69.png)

说明报错原因并不是缺少selinux权限，而是原本添加的selinux权限没有生效。

进入w代码中检查相同目录下与v是否有所异同：

![image 68](image-68.png)

![image 35](image-35.png)

最终发现，由于w版本目前是共仓，为了对qcom和mtk、xring等进行区分，在原本selinux配置文件目录下新加了三个文件夹来解耦。

因此将原本selinux配置文件位置移动到qcom目录下重新打包验证，最终方案生效，解决了该问题。

---

## 4\.3 插件dex路径错误问题解析

[插件dex路径错误问题解析](https://mi.feishu.cn/wiki/Vfzfwz5WRiCI4uk6IM4cw5lGnyh)

---



# 五、附件

dev.sh

```bash
#!/bin/bash

# 在源码根目录下添加该脚本
# 使用方法：
# 1.为脚本增加权限
# chmod +x dev.sh
# 2.使用格式
# source dev.sh {make|push} {art|framework|services|miui-framework|miui-services} [ip:port]
# 3.参数介绍
#  1) make|push 模块编译  模块推送至设备
#  2) art|framework|services|miui-framework|miui-services 模块参数
#  3) 可选参数 ip地址:端口，如果添加该参数会在push动作前执行cloudtools adb-connect连接设备，也可不选择该参数
# 4.实例: 
#     source dev.sh make art
#     source dev.sh push art
#     source dev.sh push art 10.201.15.139:5555

# 修改为你实际的 product 名字，比如 missi
PRODUCT=missi

ACTION=$1   # make 或 push
MODULE=$2   # art / framework / services / miui-framework / miui-services
TARGET=$3   # 可选参数，例如 10.201.15.139:5555

if [[ -z "$ACTION" || -z "$MODULE" ]]; then
    echo "用法: source dev.sh {make|push} {art|framework|services|miui-framework|miui-services} [ip:port]"
    return 1
fi

case "$ACTION" in
    make)
        case "$MODULE" in
            art)             make com.android.art -j16 ;;
            framework)       make framework-minus-apex -j16 ;;
            services)        make services -j16 ;;
            miui-framework)  make miui-framework -j16 ;;
            miui-services)   make miui-services -j16 ;;
            *)
                echo "未知模块: $MODULE"
                return 1 ;;
        esac
        ;;
    push)
        # 如果带了 IP:PORT 参数，先连接设备
        if [[ -n "$TARGET" ]]; then
            echo ">>> cloudtools adb-connect $TARGET"
            timeout 3s cloudtools adb-connect "$TARGET" || true
        fi

        case "$MODULE" in
            art)
                echo ">>> Push art 模块"
                adb push out/target/product/$PRODUCT/system/apex/com.android.art.capex /system/apex/
                ;;
            framework)
                echo ">>> Push framework 模块"
                adb push out/target/product/$PRODUCT/system/framework/framework.jar /product/pangu/system/framework/
                ;;
            services)
                echo ">>> Push framework-services 模块"
                adb push out/target/product/$PRODUCT/system/framework/services.jar /product/pangu/system/framework/
                ;;
            miui-framework)
                echo ">>> Push miui-framework 模块"
                adb push out/target/product/$PRODUCT/system_ext/framework/miui-framework.jar /system_ext/framework/
                ;;
            miui-services)
                echo ">>> Push miui-services 模块"
                adb push out/target/product/$PRODUCT/system_ext/framework/miui-services.jar /system_ext/framework/
                ;;
            *)
                echo "未知模块: $MODULE"
                return 1 ;;
        esac
        ;;
    *)
        echo "未知操作: $ACTION"
        echo "用法: source dev.sh {make|push} {art|framework|services|miui-framework|miui-services} [ip:port]"
        return 1
        ;;
esac

```

make.sh

```bash
#!/bin/bash
# 用法示例：
#   source make.sh art
#   source make.sh framework
#   source make.sh services
#   source make.sh miui-framework
#   source make.sh miui-services

# 先确保你已经执行过：
# source build/envsetup.sh && lunch <target>

MODULE=$1

case "$MODULE" in
    art)
        echo ">>> 编译 art 模块"
        make com.android.art -j16
        ;;
    framework)
        echo ">>> 编译 framework 模块"
        make framework-minus-apex -j16
        ;;
    services)
        echo ">>> 编译 framework-services 模块"
        make services -j16
        ;;
    miui-framework)
        echo ">>> 编译 miui-framework 模块"
        make miui-framework -j16
        ;;
    miui-services)
        echo ">>> 编译 miui-framework-services 模块"
        make miui-services -j16
        ;;
    *)
        echo "用法: $0 {art|framework|services|miui-framework|miui-services}"
        ;;
esac
```

push.sh

```bash
#!/bin/bash

# 用法示例：
#   source push.sh art
#   source push.sh framework
#   source push.sh services
#   source push.sh miui-framework
#   source push.sh miui-services

# 设备对应的 product 名字（记得改成你实际的，比如 missi）
PRODUCT=missi

MODULE=$1

case "$MODULE" in
    art)
        echo ">>> Push art 模块"
        adb root && adb remount
        adb push out/target/product/$PRODUCT/system/apex/com.android.art.capex /system/apex/
        ;;
    framework)
        echo ">>> Push framework 模块"
        adb root && adb remount
        adb push out/target/product/$PRODUCT/system/framework/framework.jar /product/pangu/system/framework/
        ;;
    services)
        echo ">>> Push framework-services 模块"
        adb root && adb remount
        adb push out/target/product/$PRODUCT/system/framework/services.jar /product/pangu/system/framework/
        ;;
    miui-framework)
        echo ">>> Push miui-framework 模块"
        adb root && adb remount
        adb push out/target/product/$PRODUCT/system_ext/framework/miui-framework.jar /system_ext/framework/
        ;;
    miui-services)
        echo ">>> Push miui-services 模块"
        adb root && adb remount
        adb push out/target/product/$PRODUCT/system_ext/framework/miui-services.jar /system_ext/framework/
        ;;
    *)
        echo "用法: $0 {art|framework|services|miui-framework|miui-services}"
        ;;
esac

```

dump\_perfetto\_v3\.sh

```bash
echo -e "\033[32m---------------------------使用说明---------------------------
1.直接执行脚本，例如：“./dump_perfetto_v3.sh test”,10s后脚本自动
终止，会把结果保存在同级目录的result中;
--------------------------------------------------------------\033[0m"
adb shell perfetto \
  -c - --txt \
  -o /data/misc/perfetto-traces/trace \
<<EOF


data_sources: {
    config {
        name: "linux.process_stats"
        target_buffer: 1
        process_stats_config {
            scan_all_processes_on_start: true
        }
    }
}
data_sources: {
    config {
        name: "linux.sys_stats"
        sys_stats_config {
            stat_period_ms: 1000
            stat_counters: STAT_CPU_TIMES
            stat_counters: STAT_FORK_COUNT
        }
    }
}
data_sources: {
    config {
        name: "android.log"
        android_log_config {
            log_ids: LID_EVENTS
            log_ids: LID_CRASH
            log_ids: LID_KERNEL
            log_ids: LID_DEFAULT
            log_ids: LID_RADIO
            log_ids: LID_SECURITY
            log_ids: LID_STATS
            log_ids: LID_SYSTEM
        }
    }
}

# data_sources: {
#     config {
#         name: "android.surfaceflinger.frametimeline"
#     }
# }

data_sources: {
    config {
        name: "linux.ftrace"
        ftrace_config {
            symbolize_ksyms: true
            ftrace_events: "ftrace/print"
            ftrace_events: "binder/*"
            ftrace_events: "sched/sched_switch"
            ftrace_events: "power/suspend_resume"
            ftrace_events: "sched/sched_wakeup"
            ftrace_events: "sched/sched_wakeup_new"
            ftrace_events: "sched/sched_waking"
            ftrace_events: "power/cpu_frequency"
            ftrace_events: "power/cpu_idle"
            ftrace_events: "vmscan/mm_vmscan_kswapd_wake"
            ftrace_events: "vmscan/mm_vmscan_kswapd_sleep"
            ftrace_events: "vmscan/mm_vmscan_direct_reclaim_begin"
            ftrace_events: "vmscan/mm_vmscan_direct_reclaim_end"
            ftrace_events: "compaction/mm_compaction_begin"
            ftrace_events: "compaction/mm_compaction_end"
            ftrace_events: "mm_filemap_add_to_page_cache"
            ftrace_events: "mm_filemap_delete_from_page_cache"
            ftrace_events: "power/gpu_frequency"
            ftrace_events: "gpu_mem/gpu_mem_total"
            ftrace_events: "sched/sched_process_exit"
            ftrace_events: "sched/sched_process_free"
            ftrace_events: "task/task_newtask"
            ftrace_events: "task/task_rename"
            ftrace_events: "lowmemorykiller/lowmemory_kill"
            ftrace_events: "oom/oom_score_adj_update"
            ftrace_events: "sched/sched_blocked_reason"
            atrace_categories: "am"
            atrace_categories: "aidl"
            atrace_categories: "webview"
            atrace_categories: "binder_lock"
            atrace_categories: "binder_driver"
            atrace_categories: "camera"
             atrace_categories: "database"
            atrace_categories: "gfx"
            atrace_categories: "hal"
            atrace_categories: "input"
            atrace_categories: "pm"
            atrace_categories: "rs"
            atrace_categories: "res"
            atrace_categories: "rro"
            atrace_categories: "sm"
            atrace_categories: "ss"
            atrace_categories: "video"
            atrace_categories: "view"
            atrace_categories: "wm"
            atrace_categories: "dalvik"
            atrace_categories: "power"
            atrace_categories: "sched"
            atrace_apps: "*"
        }
    }
}

data_sources {
  config {
    name: "android.heapprofd"
    heapprofd_config {
      shmem_size_bytes: 8388608
      sampling_interval_bytes: 4096
      block_client: true
      process_cmdline: "system_server"
      heaps: "com.android.art"
      continuous_dump_config {
        dump_phase_ms: 0
        dump_interval_ms: 1000
      }
    }
  }
}

data_sources {
    config {
        name: "linux.perf"
        perf_event_config {
            timebase {
                frequency: 5000
                counter: HW_CPU_CYCLES
                timestamp_clock: PERF_CLOCK_MONOTONIC
            }
        }
    }
}

data_sources {
    config {
        name: "linux.perf"
        perf_event_config {
            timebase {
                frequency: 5000
                counter: HW_INSTRUCTIONS
                timestamp_clock: PERF_CLOCK_MONOTONIC
            }
        }
    }
}

#buffers: {
#   size_kb: 522240
#    fill_policy: RING_BUFFER
#}
#buffers: {
 #   size_kb: 2048
 #   fill_policy: RING_BUFFER
#}
#duration_ms: 120000
#flush_period_ms: 30000
#incremental_state_config {
 #   clear_period_ms: 5000
#}

buffers: {
    size_kb: 522240
    fill_policy: RING_BUFFER
}
buffers: {
    size_kb: 2048
    fill_policy: RING_BUFFER
}
duration_ms: 15000
write_into_file: true
file_write_period_ms: 2500
max_file_size_bytes: 2000000000
flush_period_ms: 20000
incremental_state_config {
    clear_period_ms: 5000
}
EOF
# if [ ! -d "result" ];then
#   mkdir result
# fi
out_dir=/home/zhangjinhao3/art/trace
file_path=${out_dir}/systrace_$(date +%Y%m%d%H%M%S)
if [ -n $1 ]; then
    file_path=${file_path}_$1
fi

adb pull /data/misc/perfetto-traces/trace ${file_path}


```


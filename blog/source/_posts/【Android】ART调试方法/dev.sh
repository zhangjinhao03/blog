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

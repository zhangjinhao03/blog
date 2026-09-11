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

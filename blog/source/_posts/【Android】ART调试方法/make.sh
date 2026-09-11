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
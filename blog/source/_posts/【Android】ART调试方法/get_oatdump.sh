#!/bin/bash

adb shell ls /system/framework/arm64/*.oat | xargs -n1 adb pull

for file in *.oat; do   
	adb shell oatdump --oat-file=/system/framework/arm64/boot.oat --method-filter=hasOverflowed
	echo "adb shell oatdump --oat-file=/system/framework/arm64/${file} > ${file}.txt"
	adb shell oatdump --oat-file=/system/framework/arm64/${file} > ${file}.txt
done

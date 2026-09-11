---
title: 【Algorithm】10大排序算法
date: 2026-09-07 16:06:10
tags: [Algorithm,Sort]
categories: Algorithm
series: 算法基础
top_img: /img/870135.png
cover: /img/870135.png
---

# 10大排序算法

## 0.头文件

sort.h

```cpp
#ifndef DEF_SORT_H
#define DEF_SORT_H

#include <iostream>
#include <cmath>
#include <algorithm>
#include <vector>


using namespace std;

enum SortMod{
    asc,
    des
};

class Sort{
public:
    Sort(){}
    ~Sort(){}
public:
    void swap(int &num1, int &num2);

    int BubbleSort(vector<int> &nums, SortMod mod);

    int SelectSort(vector<int> &nums, SortMod mod);

    int InsertSort(vector<int> &nums, SortMod mod);

    void QuickSort(vector<int> &nums,int left,int right, SortMod mod);

    void MergeSort(vector<int> &nums,int left,int right, SortMod mod);

    void Merge(vector<int> &nums,int nLeft, int nMid, int nRight, SortMod mod);

    void ShellSort(vector<int> &nums, SortMod mod = asc);

    void HeapBuild(vector<int> &nums,int n,int i, SortMod mod = asc);

    void HeapSort(vector<int> &nums, SortMod mod = asc);

    void CountSort(vector<int> &nums, SortMod mod = asc);

    void RadixSort(vector<int> &nums, SortMod mod = asc);

    void BucketSort(vector<int> &nums, SortMod mod = asc);

};


#endif // DEF_SORT_H

```

sort.cpp

```cpp
#include "sort.h"


namespace {
bool needSwap(int left, int right, SortMod mod) {
    return mod == asc ? left > right : left < right;
}

bool before(int left, int right, SortMod mod) {
    return mod == asc ? left < right : left > right;
}
}

void Sort::swap(int &num1, int &num2){
    int t = num1;
    num1 = num2;
    num2 = t;
}

...
```



## 1.冒泡排序

稳定性：稳定
时间复杂度：O(n^2)
空间复杂度：O(1)

```cpp
int Sort::BubbleSort(vector<int> &nums, SortMod mod){
    int length = nums.size();
    if(length == 0){
        return 0;
    }

    for(int i = 0; i < length - 1; i ++){
        bool swapped = false;
        for(int j = 0; j < length - 1 - i; j ++){
            if(needSwap(nums[j], nums[j + 1], mod)){
                swap(nums[j], nums[j + 1]);
                swapped = true;
            }
        }
        // 如果一轮遍历没有发生交换，说明数组已经有序。
        if(!swapped){
            break;
        }
    }

    return 1;
}
```



## 2.选择排序

稳定性：不稳定
时间复杂度：O(n^2)
空间复杂度：O(1)

```cpp
int Sort::SelectSort(vector<int> &nums, SortMod mod){
    int length = nums.size();
    if(length == 0)return 0;//error

    for(int i = 0; i < length - 1; i ++){
        int p = i;
        for(int j = i + 1; j < length; j ++){
            if(before(nums[j], nums[p], mod)){
                p = j;
            }
        }
        if(p != i){
            swap(nums[i], nums[p]);
        }
    }

    //right
    return 1;
}
```



## 3.插入排序

稳定性：稳定
时间复杂度：O(n^2)
空间复杂度：O(1)

```cpp
int Sort::InsertSort(vector<int> &nums, SortMod mod){
    int length = nums.size();
    if(length == 0)return 0;

    for(int i = 1;i < length; i ++){
        int m = nums[i];
        int j = i - 1;
        while(j >= 0 && needSwap(nums[j], m, mod)){
            nums[j + 1] = nums[j];
            j --;
        }
        nums[j + 1] = m;
    }
    return 1;
}
```



## 4.快速排序

稳定性：不稳定
时间复杂度：平均O(nlogn)，最坏O(n^2)
空间复杂度：O(logn)

```cpp
void Sort::QuickSort(vector<int> &nums,int left, int right, SortMod mod){
    if(left >= right){
        return;
    }
    int l = left;
    int r = right;
    // 使用中间元素做基准，降低已基本有序数组退化的概率。
    int base = nums[left + (right - left) / 2];

    while(l <= r){
        while(before(nums[l], base, mod)){
            l ++;
        }
        while(before(base, nums[r], mod)){
            r --;
        }
        if(l <= r){
            swap(nums[l], nums[r]);
            l ++;
            r --;
        }
    }

    if(left < r){
        QuickSort(nums,left,r,mod);
    }
    if(l < right){
        QuickSort(nums,l,right,mod);
    }
}
```



## 5.归并排序

稳定性：稳定

时间复杂度：O(nlogn)

空间复杂度：O(n)   归并排序需要一个与原数组相同长度的数组做辅助来排序。

归并排序采用分治思想，把待排序序列分成N个子序列，子序列排序后，合并两个子序列实现排序

```cpp
void Sort::Merge(vector<int> &nums,int left, int mid, int right, SortMod mod){
    vector<int> tmp(right-left+1);
    int i = left;
    int j = mid + 1;
    int index = 0;
    while(i <= mid &&  j <= right){
        tmp[index++] = before(nums[j], nums[i], mod) ? nums[j++] : nums[i++];
    }
    while( i <= mid){
        tmp[index++] = nums[i++];
    }
    while(j <= right){
        tmp[index++] = nums[j++];
    }
    index = 0;
    for(int i = left; i <= right; i ++){
        nums[i] = tmp[index++];
    }
}

void Sort::MergeSort(vector<int> &nums,int left,int right, SortMod mod){
    if (left >= right) {
        return;
    }
    int mid = left + (right - left) / 2;
    MergeSort(nums,left,mid,mod);//分治
    MergeSort(nums,mid+1,right,mod);//分治
    Merge(nums,left,mid,right,mod);//归并
}

```





## 6.希尔排序

稳定性：不稳定

时间复杂度：一般介于O(nlogn)和O(n^2)之间

空间复杂度：O(1)

希尔排序是先将任意间隔为N的元素有序，刚开始可以是N=n/2，接着让N=N/2，让N一直缩小，当N=1,时，此时序列间隔为1有序。

```cpp
void Sort::ShellSort(vector<int> &nums, SortMod mod){
    int length = nums.size();
    for(int gap = length / 2; gap > 0; gap /= 2){
        for(int i = gap; i < length; i ++){
            int m = nums[i];
            int j = i - gap;
            while(j >= 0 && needSwap(nums[j], m, mod)){
                nums[j + gap] = nums[j];
                j -= gap;
            }
            nums[j + gap] = m;
        }
    }
}
```



## 7.堆排序

稳定性：不稳定

时间复杂度：O(nlogn)

空间复杂度：O(1)

大顶堆：arr[i] >= arr[2i+1] && arr[i] >= arr[2i+2]

小顶堆：arr[i] <= arr[2i+1] && arr[i] <= arr[2i+2]

1、将待排序序列构建成大根堆，此堆为初始无序堆

2、将堆顶元素和最后一个元素交换，此时得到新的N-1无序堆和有序序列

3、重复2直到无序堆为1，此时有序序列为N-1

```cc
void Sort::HeapBuild(vector<int> &nums,int n,int i, SortMod mod){
    while(true){
        int left = 2 * i + 1;
        int right = 2 * i + 2;
        int target = i;

        if (left < n && before(nums[target], nums[left], mod)) {
            target = left;
        }

        if (right < n && before(nums[target], nums[right], mod)) {
            target = right;
        }

        if (target == i) {
            break;
        }
        swap(nums[i], nums[target]);
        i = target;
    }
}

void Sort::HeapSort(vector<int> &nums, SortMod mod){
    int n = nums.size();
    if(n <= 1){
        return;
    }

    for (int i = n/2-1; i >= 0; i--)
    {
        HeapBuild(nums,n,i,mod);
    }
    for (int i = n-1;i > 0; i--)
    {
        swap(nums[0],nums[i]);
        HeapBuild(nums,i,0,mod);
    }
}
```



## 8.计数排序

稳定性：稳定

时间复杂度：O(n+k)，k为最大值和最小值的范围

空间复杂度：O(n+k)

计数排序适合整数范围较集中的数据，通过统计每个数字出现的次数来确定元素位置。

```cpp
void Sort::CountSort(vector<int> &nums, SortMod mod){
    int length = nums.size();
    if(length <= 1){
        return;
    }

    int minValue = nums[0];
    int maxValue = nums[0];
    for(int num : nums){
        if(num < minValue){
            minValue = num;
        }
        if(num > maxValue){
            maxValue = num;
        }
    }

    vector<int> count(maxValue - minValue + 1, 0);
    for(int num : nums){
        count[num - minValue] ++;
    }

    // 前缀和记录每个值在结果数组中的结束位置，用于保持稳定性。
    for(int i = 1; i < count.size(); i ++){
        count[i] += count[i - 1];
    }

    vector<int> result(length);
    for(int i = length - 1; i >= 0; i --){
        int index = nums[i] - minValue;
        result[--count[index]] = nums[i];
    }

    if(mod == asc){
        nums = result;
    }else{
        for(int i = 0; i < length; i ++){
            nums[i] = result[length - 1 - i];
        }
    }
}
```

## 9.基数排序

稳定性：稳定

时间复杂度：O(d*n)，d为最大数字位数

空间复杂度：O(n+r)，r为基数，这里是10

基数排序按个位、十位、百位依次进行稳定计数排序，适合整数排序。

```cpp
void Sort::RadixSort(vector<int> &nums, SortMod mod){
    int length = nums.size();
    if(length <= 1){
        return;
    }

    vector<int> negative;
    vector<int> nonNegative;
    for(int num : nums){
        if(num < 0){
            negative.push_back(-num);
        }else{
            nonNegative.push_back(num);
        }
    }

    auto radixAsc = [](vector<int> &arr){
        if(arr.size() <= 1){
            return;
        }
        int maxValue = arr[0];
        for(int num : arr){
            if(num > maxValue){
                maxValue = num;
            }
        }

        vector<int> output(arr.size());
        for(int exp = 1; maxValue / exp > 0; exp *= 10){
            vector<int> count(10, 0);
            for(int num : arr){
                count[(num / exp) % 10] ++;
            }
            for(int i = 1; i < 10; i ++){
                count[i] += count[i - 1];
            }
            for(int i = arr.size() - 1; i >= 0; i --){
                int digit = (arr[i] / exp) % 10;
                output[--count[digit]] = arr[i];
            }
            arr = output;
        }
    };

    radixAsc(negative);
    radixAsc(nonNegative);

    int index = 0;
    if(mod == asc){
        // 负数绝对值越大，真实值越小，所以需要反向放回。
        for(int i = negative.size() - 1; i >= 0; i --){
            nums[index++] = -negative[i];
        }
        for(int num : nonNegative){
            nums[index++] = num;
        }
    }else{
        for(int i = nonNegative.size() - 1; i >= 0; i --){
            nums[index++] = nonNegative[i];
        }
        for(int num : negative){
            nums[index++] = -num;
        }
    }
}
```





## 10.桶排序

稳定性：取决于桶内排序，这里桶内使用插入排序，整体稳定

时间复杂度：平均O(n+k)，最坏O(n^2)

空间复杂度：O(n+k)

桶排序把数据按范围分到多个桶中，桶内排序后再按桶顺序合并。



```cpp
void Sort::BucketSort(vector<int> &nums, SortMod mod){
    int length = nums.size();
    if(length <= 1){
        return;
    }

    int minValue = nums[0];
    int maxValue = nums[0];
    for(int num : nums){
        if(num < minValue){
            minValue = num;
        }
        if(num > maxValue){
            maxValue = num;
        }
    }

    int bucketSize = max(1, static_cast<int>(sqrt(length)));
    int bucketCount = (maxValue - minValue) / bucketSize + 1;
    vector<vector<int>> buckets(bucketCount);

    for(int num : nums){
        buckets[(num - minValue) / bucketSize].push_back(num);
    }

    int index = 0;
    if(mod == asc){
        for(int i = 0; i < bucketCount; i ++){
            InsertSort(buckets[i], asc);
            for(int num : buckets[i]){
                nums[index++] = num;
            }
        }
    }else{
        for(int i = bucketCount - 1; i >= 0; i --){
            InsertSort(buckets[i], des);
            for(int num : buckets[i]){
                nums[index++] = num;
            }
        }
    }
}
```


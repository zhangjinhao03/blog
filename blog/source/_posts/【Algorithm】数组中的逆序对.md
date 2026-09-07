---
title: 【Algorithm】数组中的逆序对
date: 2024-02-22 10:48:34
tags: [Algorithm,Sort,Merge]
categories: Markdown
top_img: /img/870135.png
cover: /img/870135.png
---

# 数组中的逆序对

{% note purple 'fas fa-wand-magic-sparkles' %}
题目
{% endnote %}

在数组中的两个数字，如果前面一个数字大于后面的数字，则这两个数字组成一个逆序对。输入一个数组，求出这个数组中的逆序对的总数。

**示例:**

```tex
输入: [7,5,6,4]
输出: 5
```

**限制：**

```tex
0 <= 数组长度 <= 50000
```

{% note orange 'fas fa-lightbulb' flat %}
题解
{% endnote %}

对于数组[7，5，6，4],若要计算其中的逆序对个数，及 [7,5],[7,6],[7,4],[5,4],[6,4],可以发现，若将所有逆序对依次交换其在数组中的位置，我们将会得到一个有序的数组，因此，我们可以用排序的思想来解决该题。

**归并排序**

归并排序是利用归并的思想实现的排序方法，该算法 采用经典的分治策略(分治法将问题分成一些小的问题然后递归求解，而治的阶段则将分的阶段得到的各答案"修补"在一起，即分而治之)。

具体可以查看：{% post_link 【Algorithm】10大排序算法 10大排序算法%}

归并排序是建立在归并操作上的一种有效的排序算法，归并排序对序列的元素进行逐层折半分组，然后从最小分组开始比较排序，合并成一个大的分组，逐层进行，最终所有的元素都是有序的。



因此要求数组中的逆序对数，只需要计算通过归并排序，将数组中逆序对交换的次数即可。代码如下：

```cpp
class Solution {
public:
    int mergeSort(vector<int> &tmp,vector<int> &nums, int left, int right) {
        if (left >= right) return 0;
        int l = left;
        int mid = (left + right) / 2;
        int r = mid + 1;
        int ans = mergeSort(tmp,nums,l,mid) + mergeSort(tmp,nums,r, right);
        int index = 0;
        while (l <= mid && r <= right) {
            if (nums[l] <= nums[r]) {
                tmp[index ++] = nums[l ++];
                ans += (r - (mid + 1));
            } else {
                tmp[index ++] = nums[r ++];
            }
        }

        while (l <= mid) {
            tmp[index ++] = nums[l ++];
            ans += (r - (mid + 1));
        }

        while (r <= right) {
            tmp[index ++] = nums[r ++];
        }

        index = 0;
        for (int i = left; i <= right; i ++) {
            nums[i] = tmp[index ++];
        }
        return ans;
    }
    int reversePairs(vector<int>& record) {
        int n = record.size();
        int left = 0;
        int right = n - 1;
        vector<int> tmp(n);
        return mergeSort(tmp, record, left, right);
    }
};
```


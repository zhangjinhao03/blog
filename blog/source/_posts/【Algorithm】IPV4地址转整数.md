---
title: 【Algorithm】IPV4地址转整数
date: 2026-09-08 15:30:02
tags: [Algorithm,String]
categories: Algorithm
series: 每日算法题
top_img: /img/870135.png
cover: /img/870135.png
---

# IPV4地址转整数

{% note purple 'fas fa-wand-magic-sparkles' %}
题目
{% endnote %}

IPv4地址字符串为点'.'分隔的四段数字，由 4 小节组成，每节的范围为 0 ~ 255，请编写函数将其转换为32比特无符号整数，其中字符串最左边的一段在最高位一侧，最右边在最低位一侧。例如202.106.0.20转换为0xCA6A0014

本题使用ACM模式作答

**示例**

输入

```tex
202.106.0.20
6.7.8.999
```

输出

```tex
CA6A0014
X
```

{% note orange 'fas fa-lightbulb' flat %}
题解
{% endnote %}

**思路**

程序分为两步：

1. 判断 IPv4 字符串是否合法，并解析出四个数字。
2. 将四个数字按字节拼接成一个 32 位整数，再转换为 8 位大写十六进制字符串。

对于：

```text
202.106.0.20
```

四段数字分别占据 32 位整数中的不同位置：

```text
202       106       0       20
最高 8 位  次高 8 位  次低 8 位  最低 8 位
```

数学表达式为：

```text
202 << 24 | 106 << 16 | 0 << 8 | 20
```

结果是：

```text
0xCA6A0014
```

**完整代码**

```cpp
#include <iostream>
#include <string>
using namespace std;

// 解析 IPv4 字符串，成功时把 32 位结果写入 result
bool parseIPv4(const string& ip, unsigned int& result) {
    result = 0;
    int num = 0;      // 当前段正在累积的十进制数
    int digits = 0;   // 当前段已经读了多少位
    int cnt = 0;      // 已完成的段数

    // 末尾补一个 '.'，方便统一处理最后一段
    for (size_t i = 0; i <= ip.size(); ++i) {
        char c = (i == ip.size() ? '.' : ip[i]);

        if (c == '.') {
            // 每段必须有数字，且范围必须在 0~255
            if (digits == 0 || num > 255) return false;

            // 每解析完一段，就左移 8 位并拼接到结果中
            result = (result << 8) | static_cast<unsigned int>(num);
            ++cnt;
            num = 0;
            digits = 0;
        } else if (c >= '0' && c <= '9') {
            // 继续累加当前段数字
            num = num * 10 + (c - '0');
            ++digits;

            // 一旦超过 255，直接判非法
            if (num > 255) return false;
        } else {
            // 只允许数字和点
            return false;
        }
    }

    // 必须刚好有 4 段
    return cnt == 4;
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    string ip;
    while (cin >> ip) {
        unsigned int val;
        if (!parseIPv4(ip, val)) {
            cout << 'X' << '\n';
            continue;
        }

        // 转为 8 位大写十六进制字符串
        const char* hex = "0123456789ABCDEF";
        string ans(8, '0');
        for (int i = 7; i >= 0; --i) {
            ans[i] = hex[val & 0xF];
            val >>= 4;
        }

        cout << ans << '\n';
    }
    return 0;
}
```


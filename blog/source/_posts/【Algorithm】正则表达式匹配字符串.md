---
title: 【Algorithm】正则表达式匹配字符串
date: 2026-09-10 14:54:03
tags: [Algorithm,String]
categories: Algorithm
series: 每日算法题
top_img: /img/870135.png
cover: /img/870135.png
---

{% note purple 'fas fa-wand-magic-sparkles' %}
题目
{% endnote %}

实现简单的正则表达式匹配，本题中模式字符串所包含的字符的范围为字母、"."、"\*"、"?"

"."匹配任何单个字符

"*"与模式字符串前一个字符组成一组，匹配零个或多个前面的字符

"?"与模式字符串前一个字符组成一组，匹配一个或多个前面的字符

匹配应该覆盖到整个输入的字符串(而不是局部的)，测试用例中不会出现超出匹配字符范围之外的字符，也不会出现非法的模式字符串。 使用语言提供的正则表达式库将算作无效答案。

本题使用ACM模式作答

**输入描述**

输入的第一行为需要检测匹配的用例数。 接下来的每一行包括两个字符串，前一个字符串为待匹配的字符串，后一个字符串为模式字符串。待匹配字符串的长度不超过10。 

```tex
5
a a.
a a.*
ab .*
ab .?
b a?
```

**输出描述**

对于每一个测试用例，如果匹配则输出一行true，如果不匹配则输出一行false。

```tex
false
true
true
true
false
```



{% note orange 'fas fa-lightbulb' flat %}
题解
{% endnote %}

```cpp
#include <iostream>
#include <string>
#include <vector>
using namespace std;

class RegexMatcher {
private:
    string text;
    string pattern;
    vector<vector<int>> memo;

    // 判断 text[i] 是否能够匹配 pattern[j] 这个基本单元
    bool isMatch(int i, int j) {
        if (i >= static_cast<int>(text.size())) {
            return false;
        }

        return pattern[j] == '.' || pattern[j] == text[i];
    }

    // 判断 text[i..] 是否能够与 pattern[j..] 完全匹配
    bool dfs(int i, int j) {
        // 模式字符串已经处理完，只有输入字符串也处理完才算匹配
        if (j == static_cast<int>(pattern.size())) {
            return i == static_cast<int>(text.size());
        }

        int& result = memo[i][j];
        if (result != -1) {
            return result;
        }

        bool matched = false;

        // 当前基本单元后面有 * 或 ?
        if (j + 1 < static_cast<int>(pattern.size()) &&
            (pattern[j + 1] == '*' || pattern[j + 1] == '?')) {
            char modifier = pattern[j + 1];

            if (modifier == '*') {
                // * 匹配 0 次，直接跳过当前基本单元和 *
                matched = dfs(i, j + 2);

                // * 匹配至少 1 次，并继续使用当前基本单元
                if (!matched && isMatch(i, j)) {
                    matched = dfs(i + 1, j);
                }
            } else {
                // ? 至少匹配 1 次，因此不能直接跳过
                if (isMatch(i, j)) {
                    // 匹配 1 次后结束当前组
                    matched = dfs(i + 1, j + 2);

                    // 匹配 1 次后继续匹配当前基本单元
                    if (!matched) {
                        matched = dfs(i + 1, j);
                    }
                }
            }
        } else {
            // 普通字符或 '.' 必须匹配当前字符
            if (isMatch(i, j)) {
                matched = dfs(i + 1, j + 1);
            }
        }

        result = matched ? 1 : 0;
        return matched;
    }

public:
    bool match(const string& input, const string& p) {
        text = input;
        pattern = p;

        // 多开一行和一列，覆盖字符串或模式处理完的状态
        memo.assign(text.size() + 1,
                    vector<int>(pattern.size() + 1, -1));

        return dfs(0, 0);
    }
};

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int testCases;
    cin >> testCases;

    RegexMatcher matcher;

    while (testCases--) {
        string text;
        string pattern;
        cin >> text >> pattern;

        cout << boolalpha << matcher.match(text, pattern) << endl;
    }

    return 0;
}
```


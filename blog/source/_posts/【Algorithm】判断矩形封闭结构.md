---
title: "【Algorithm】判断矩形封闭结构"
date: 2026-09-10 15:02:31
tags:
  - Algorithm
  - String
categories: Algorithm
series: 每日算法题
top_img: /img/870135.png
cover: /img/870135.png
---

{% note purple 'fas fa-wand-magic-sparkles' %}
题目
{% endnote %}

有一个9x9的正方形棋盘，规定横向为x轴，纵向为y轴，并以左上角格子为坐标原点(0,0)。那么棋盘中每个格子的位置都可以用(x,y)进行表示(x,y∈[0,8]) 现在我们会在棋盘上按顺序种植任意数量的1x1大小的树苗。每棵小树苗在种植后沿指定生长方向一直生长，直至达到最大生长高度或者遇到障碍。 在种植完所有树苗后(所有树苗均结束生长)，我希望可以判断当前棋盘上是否 存在矩形封闭结构? 1、最大生长高度(maxGrowLength)：不包含初始大小在内的树苗最大占用格子数量(最大生长高度为7的树苗，初始位置(8,0)且向下生长时，至多覆盖从(8,0)到(8,7)的所有8个格子) 2、生长方向(growDirection)：上、下、左、右 3、障碍(停止生长的条件)：当前树苗生长方向上的下一个格子超出棋盘、已 经存在其他树苗的情况下，停止生长 4、种植顺序：当且仅当上一种植的树苗结束生长后，才会种植下一个树苗(无需考虑生长之间的抢占问题) 5、矩形封闭结构：棋盘上存在的一个矩形，其四边完全由树苗组成 树苗配置结构如下，请实现checkTreeFormClosedLoop函数，对所有输入的树苗配置进行处理，判断树苗是否可以在棋盘中形成矩形封闭结构。请注章:树苗配置的输入顺序即为种植顺序，如果树苗种植的位置本身超出棋盘或被其他树苗占有，则放弃种植当前树苗，直接开始下一棵树苗的种植。

本题使用ACM模式作答

**示例**

输入

```tex
0 0 1 7
8 0 2 7 
8 8 3 7
0 8 0 7
```

输出

```tex
true
```

{% note orange 'fas fa-lightbulb' flat %}
题解
{% endnote %}

```cpp
#include <iostream>
#include <vector>
using namespace std;

struct Tree {
    int x;
    int y;
    int direction;
    int maxGrowLength;
};

// 判断坐标是否在棋盘范围内
bool inBoard(int x, int y) {
    return x >= 0 && x < 9 && y >= 0 && y < 9;
}

// 判断棋盘上是否存在矩形封闭结构
bool checkTreeFormClosedLoop(const vector<Tree>& trees) {
    // board[y][x] == true 表示该位置已经有树苗
    bool board[9][9] = {};

    // 方向：上、下、左、右
    const int dx[4] = {0, 0, -1, 1};
    const int dy[4] = {-1, 1, 0, 0};

    // 按照输入顺序种植树苗
    for (const Tree& tree : trees) {
        int x = tree.x;
        int y = tree.y;

        // 方向不合法时，放弃当前树苗
        if (tree.direction < 0 || tree.direction >= 4) {
            continue;
        }

        // 初始位置越界，或者已经被占用，放弃当前树苗
        if (!inBoard(x, y) || board[y][x]) {
            continue;
        }

        // 种植初始位置
        board[y][x] = true;

        // 继续生长 maxGrowLength 格
        for (int step = 0; step < tree.maxGrowLength; ++step) {
            int nextX = x + dx[tree.direction];
            int nextY = y + dy[tree.direction];

            // 越界或遇到已有树苗，停止生长
            if (!inBoard(nextX, nextY) || board[nextY][nextX]) {
                break;
            }

            // 占用下一个格子
            x = nextX;
            y = nextY;
            board[y][x] = true;
        }
    }

    // 枚举矩形的左右边界和上下边界
    for (int x1 = 0; x1 < 9; ++x1) {
        for (int x2 = x1 + 1; x2 < 9; ++x2) {
            for (int y1 = 0; y1 < 9; ++y1) {
                for (int y2 = y1 + 1; y2 < 9; ++y2) {
                    bool closed = true;

                    // 检查上边和下边
                    for (int x = x1; x <= x2; ++x) {
                        if (!board[y1][x] || !board[y2][x]) {
                            closed = false;
                            break;
                        }
                    }

                    if (!closed) {
                        continue;
                    }

                    // 检查左边和右边
                    for (int y = y1; y <= y2; ++y) {
                        if (!board[y][x1] || !board[y][x2]) {
                            closed = false;
                            break;
                        }
                    }

                    if (closed) {
                        return true;
                    }
                }
            }
        }
    }

    return false;
}

int main() {
    vector<Tree> trees;
    int x, y, d, m;

    // 输入没有给出树苗数量，因此持续读取到 EOF
    while (cin >> x >> y >> d >> m) {
        trees.push_back({x, y, direction, maxGrowLength});
    }

    cout << boolalpha << checkTreeFormClosedLoop(trees) << endl;
    return 0;
}
```


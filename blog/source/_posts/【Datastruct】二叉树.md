---
title: 【Datastruct】二叉树
date: 2022-11-12 15:28:39
tags: [C,BST,BinaryTree,Datastruct]
categories: Datastruct
series: 数据结构基础
top_img: /img/922387.jpg
cover: /img/922387.jpg
---

# 二叉树

## 1.二叉树的代码实现

BinaryTree.h

```c
#pragma once
#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <queue>
#include <stack>

using namespace std;

typedef struct node {
    int nValue;
    struct node* pLeft;
    struct node* pRight;
}BinaryTree;

BinaryTree* CreateNode(int data) {//创建二叉树节点
    BinaryTree* root = (BinaryTree*)malloc(sizeof(BinaryTree));
    root->nValue = data;
    root->pLeft = NULL;
    root->pRight = NULL;
    return root;
}

BinaryTree* CreateBinaryTree() {//创建二叉树
    BinaryTree* pRoot = NULL;
    //根
    pRoot = (BinaryTree*)malloc(sizeof(BinaryTree));
    pRoot->nValue = 1;

    //根的左
    pRoot->pLeft = (BinaryTree*)malloc(sizeof(BinaryTree));
    pRoot->pLeft->nValue = 2;
    //左的左
    pRoot->pLeft->pLeft = (BinaryTree*)malloc(sizeof(BinaryTree));
    pRoot->pLeft->pLeft->nValue = 4;
    pRoot->pLeft->pLeft->pLeft = NULL;
    pRoot->pLeft->pLeft->pRight = NULL;

    //左的右
    pRoot->pLeft->pRight = (BinaryTree*)malloc(sizeof(BinaryTree));
    pRoot->pLeft->pRight->nValue = 5;
    pRoot->pLeft->pRight->pLeft = NULL;
    pRoot->pLeft->pRight->pRight = NULL;

    //根的右
    pRoot->pRight = (BinaryTree*)malloc(sizeof(BinaryTree));
    pRoot->pRight->nValue = 3;
    pRoot->pRight->pLeft = NULL;
    pRoot->pRight->pRight = NULL;

    return pRoot;
}

void LevelTraversal(BinaryTree* pTree) {//二叉树层序遍历
    if (pTree == NULL) return;

    queue<BinaryTree*> q;

    q.push(pTree);

    while (!q.empty()) {
        pTree = q.front();
        q.pop();
        cout << pTree->nValue << " ";

        if (pTree->pLeft != NULL) {
            q.push(pTree->pLeft);
        }
        if (pTree->pRight != NULL) {
            q.push(pTree->pRight);
        }
    }
    cout << endl;
}

//递归实现三序遍历
void PreOrderTraversal_recursion(BinaryTree* pTree) {
    if (pTree == NULL) {
        return;
    }
    cout << pTree->nValue << " ";
    PreOrderTraversal_recursion(pTree->pLeft);
    PreOrderTraversal_recursion(pTree->pRight);
}
void InOrderTraversal_recursion(BinaryTree* pTree) {
    if (pTree == NULL) {
        return;
    }
    InOrderTraversal_recursion(pTree->pLeft);
    cout << pTree->nValue << " ";
    InOrderTraversal_recursion(pTree->pRight);
}
void LastOrderTraversal_recursion(BinaryTree* pTree) {
    if (pTree == NULL) {
        return;
    }
    LastOrderTraversal_recursion(pTree->pLeft);
    LastOrderTraversal_recursion(pTree->pRight);
    cout << pTree->nValue << " ";
}


//非递归实现三序遍历
void PreOrderTraversal(BinaryTree* pTree) {
    if (pTree == NULL)return;

    stack<BinaryTree*>s;
    while (1) {
        while (pTree) {
            //输出
            cout << pTree->nValue << " ";
            //保存
            s.push(pTree);
            //处理左
            pTree = pTree->pLeft;
        }
        if (s.empty()) {
            break;
        }
        //弹出
        pTree = s.top();
        s.pop();
        //右侧
        pTree = pTree->pRight;
    }
    cout << endl;
}

void InOrderTraversal(BinaryTree* pTree) {
    if (pTree == NULL)return;

    stack<BinaryTree*>s;
    while (1) {
        while (pTree) {
            //保存
            s.push(pTree);
            //处理左
            pTree = pTree->pLeft;
        }
        if (s.empty()) {
            break;
        }
        //弹出
        pTree = s.top();

        //输出
        cout << pTree->nValue << " ";

        s.pop();
        //右侧
        pTree = pTree->pRight;
    }
    cout << endl;
}


void LastOrderTraversal(BinaryTree* pTree) {
    if (pTree == NULL)return;

    stack<BinaryTree*> s;

    BinaryTree* pMark = NULL;
    while (1) {
        while (pTree) {
            //保存
            s.push(pTree);
            //处理左
            pTree = pTree->pLeft;
        }
        if (s.empty()) {
            break;
        }
        //栈顶元素右侧
        if (s.top()->pRight == NULL || s.top()->pRight == pMark) {
            //弹出
            pMark = s.top();
            s.pop();

            printf("%d ",pMark->nValue);
        }
        else {
            pTree = s.top()->pRight;
        }
    }
    cout << endl;
}
```

## 2.二叉搜索树的代码实现

BST.h

```c
#pragma once
#include "BinaryTree.h"

void AddNode_BST(BinaryTree** pTree, int data);
BinaryTree* CreateBST() {
    int nNum;
    int nLen;
    int i;

    BinaryTree* pTree = NULL;

    printf("please input the number of nodes：\n");
    cin >> nLen;
    for (int i = 0; i < nLen; i++) {
        cin >> nNum;
        AddNode_BST(&pTree,nNum);
    }
    return pTree;
}


void AddNode_BST(BinaryTree **pTree,int data) {
    BinaryTree* pTemp = NULL;
    pTemp = (BinaryTree*)malloc(sizeof(BinaryTree));
    pTemp->nValue = data;
    pTemp->pLeft = NULL;
    pTemp->pRight = NULL;

    if (*pTree == NULL) {
        *pTree = pTemp;
        return;
    }
    BinaryTree* pNode = *pTree;
    while (pNode) {
        if (pNode->nValue > data) {
            //左侧
            if (pNode->pLeft == NULL) {
                pNode->pLeft = pTemp;
                return;
            }
            pNode = pNode->pLeft;
        }
        else if(pNode->nValue < data){
            //右侧
            if (pNode->pRight == NULL) {
                pNode->pRight = pTemp;
                return;
            }
            pNode = pNode->pRight;
        }else {
            printf("data error.\n");
            free(pTemp);
            pTemp = NULL;
            return;
        }
    }
}



void Search_BST(BinaryTree* pTree,int nNum,BinaryTree ** pDel,BinaryTree **pFather) {
    while (pTree) {
        if (pTree->nValue == nNum) {
            *pDel = pTree;
            return;
        }
        else if (pTree->nValue > nNum) {
            *pFather = pTree;
            pTree = pTree->pLeft;
        }
        else {
            *pFather = pTree;
            pTree = pTree->pRight;
        }
    }
    *pFather = NULL;
}


void DelNode_BST(BinaryTree **pTree,int nNum) {
    BinaryTree* pDel = NULL;
    BinaryTree* pFather = NULL;

    Search_BST(*pTree,nNum,&pDel,&pFather);
    
    //未到到
    if (pDel == NULL)return;
    //两个孩子
    BinaryTree* pMark;
    if (pDel->pLeft != NULL && pDel->pRight != NULL) {
        pMark = pDel;

        //左子树的最右
        pFather = pDel;
        pDel = pDel->pLeft;

        while (pDel->pRight != NULL) {
            pFather = pDel;
            pDel = pDel->pRight;
        }

        //值覆盖
        pMark->nValue = pDel->nValue;
    }

    //0个或1个孩子
    //换根
    if (pFather == NULL) {
        *pTree = pDel->pLeft ? pDel->pLeft : pDel->pRight;
        free(pDel);
        pDel = NULL;
        return;
    }
    else {
        if (pDel == pFather->pLeft) {
            pFather->pLeft = pDel->pLeft ? pDel->pLeft : pDel->pRight;
        }
        else {
            pFather->pRight = pDel->pLeft ? pDel->pLeft : pDel->pRight;
        }

    }

}
```

main.cpp

```cpp
#include "BinaryTree.h"
#include "BST.h"


int main() {
    BinaryTree* pTree = CreateBST();
    //LevelTraversal(pTree);
    //PreOrderTraversal(pTree);
    InOrderTraversal(pTree);
    //LastOrderTraversal(pTree);
    DelNode_BST(&pTree,10);
    InOrderTraversal(pTree);
    return 0;
}
```

## 3.二叉树的四序遍历

### 前序

```cpp
//递归
void PreOrderTraversal(BinaryTree* pTree) {
    if (pTree == NULL) {
        return;
    }
    cout << pTree->nValue << " ";
    PreOrderTraversal(pTree->pLeft);
    PreOrderTraversal(pTree->pRight);
}
```



```cpp
//非递归
void PreOrderTraversal(BinaryTree* pTree) {
    if (pTree == NULL)return;

    stack<BinaryTree*>s;
    while (1) {
        while (pTree) {
            //输出
            cout << pTree->nValue << " ";
            //保存
            s.push(pTree);
            //处理左
            pTree = pTree->pLeft;
        }
        if (s.empty()) {
            break;
        }
        //弹出
        pTree = s.top();
        s.pop();
        //右侧
        pTree = pTree->pRight;
    }
    cout << endl;
}
```



### 中序

```cpp
//递归
void InOrderTraversal(BinaryTree* pTree) {
    if (pTree == NULL) {
        return;
    }
    InOrderTraversal(pTree->pLeft);
    cout << pTree->nValue << " ";
    InOrderTraversal(pTree->pRight);
}
```



```cpp
//非递归
void InOrderTraversal(BinaryTree* pTree) {
    if (pTree == NULL)return;

    stack<BinaryTree*>s;
    while (1) {
        while (pTree) {
            //保存
            s.push(pTree);
            //处理左
            pTree = pTree->pLeft;
        }
        if (s.empty()) {
            break;
        }
        //弹出
        pTree = s.top();

        //输出
        cout << pTree->nValue << " ";

        s.pop();
        //右侧
        pTree = pTree->pRight;
    }
    cout << endl;
}
```





### 后序

```cpp
//递归
void LastOrderTraversal(BinaryTree* pTree) {
    if (pTree == NULL) {
        return;
    }
    LastOrderTraversal(pTree->pLeft);
    LastOrderTraversal(pTree->pRight);
    cout << pTree->nValue << " ";
}
```



```cpp
//非递归
void LastOrderTraversal(BinaryTree* pTree) {
    if (pTree == NULL)return;

    stack<BinaryTree*> s;

    BinaryTree* pMark = NULL;
    while (1) {
        while (pTree) {
            //保存
            s.push(pTree);
            //处理左
            pTree = pTree->pLeft;
        }
        if (s.empty()) {
            break;
        }
        //栈顶元素右侧
        if (s.top()->pRight == NULL || s.top()->pRight == pMark) {
            //弹出
            pMark = s.top();
            s.pop();

            printf("%d ",pMark->nValue);
        }
        else {
            pTree = s.top()->pRight;
        }
    }
    cout << endl;
}
```



### 层序

```cpp
void LevelTraversal(BinaryTree* pTree) {
    if (pTree == NULL) return;
    queue<BinaryTree*> q;

    q.push(pTree);

    while (!q.empty()) {
        pTree = q.front();
        q.pop();
        cout << pTree->nValue << " ";

        if (pTree->pLeft != NULL) {
            q.push(pTree->pLeft);
        }
        if (pTree->pRight != NULL) {
            q.push(pTree->pRight);
        }
    }
}
```

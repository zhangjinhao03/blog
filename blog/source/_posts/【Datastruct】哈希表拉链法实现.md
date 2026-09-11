---
title: 【Datastruct】哈希表拉链法实现
date: 2023-09-07 15:29:06
tags: [C,Hash,Datastruct]
categories: Datastruct
series: 数据结构基础
top_img: /img/922387.jpg
cover: /img/922387.jpg
---

# 哈希表拉链法实现C语言版



```c
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

typedef struct hash {
    int nValue;
    struct hash* pNext;
}Hash;

Hash** CreateHashTable(int arr[], int nLength) {
    if (arr == NULL || nLength <= 0) return NULL;
    
    Hash** pHash = NULL;
    pHash = (Hash**)malloc(sizeof(Hash*) * nLength);
    memset(pHash,0,sizeof(Hash*) * nLength);
    int nIndex;
    Hash* pTemp = NULL;
    int i;
    for (i = 0; i < nLength; i++) {
        nIndex = arr[i]%nLength;
        pTemp = (Hash*)malloc(sizeof(Hash));
        pTemp->nValue = arr[i];
        pTemp->pNext = pHash[nIndex];
        pHash[nIndex] = pTemp;
    }
    return pHash;
}

void HashSearch(Hash **pHash,int nLength,int nNum) {
    if (pHash == NULL) return;
    int nIndex = nNum % nLength;
    Hash* pTemp = pHash[nIndex];
    while (pTemp) {
        if (pTemp->nValue == nNum) {
            printf("%d\n", pTemp->nValue);
            return;
        }
        pTemp = pTemp->pNext;
    }
    printf("failed.\n");
}


int main() {
    int arr[] = { 10,116,2,18,99,333,15,25,90,376 };
    Hash** pHash = CreateHashTable(arr,sizeof(arr)/sizeof(arr[0]));
    HashSearch(pHash,sizeof(arr)/sizeof(arr[0]),333);
    return 0;
}
```

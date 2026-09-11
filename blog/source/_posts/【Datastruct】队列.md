---
title: 【Datastruct】队列
date: 2022-11-12 15:28:52
tags: [C,Queue,Datastruct]
categories: Datastruct
series: 数据结构基础
top_img: /img/922387.jpg
cover: /img/922387.jpg
---



# 队列



```c
#include <stdio.h>
#include <stdlib.h>

//队列
//尾增头删
typedef struct node {
    int nValue;
    node* pNext;
}node;


typedef struct Queue {
    node* phead;
    node* pTail;
    int length;
}Queue;

void InitQueue(Queue** queue) {
    *queue = (Queue*)malloc(sizeof(Queue));
    (*queue)->phead = NULL;
    (*queue)->pTail = NULL;
    (*queue)->length = 0;
}

void Push(Queue* queue, int nValue) {
    if (queue == NULL) {
        printf("queue is not exist.\n");
        exit(1);
    }
    node* pTemp = (node*)malloc(sizeof(node));
    pTemp->nValue = nValue;
    pTemp->pNext = NULL;

    if (queue->phead == NULL) {
        queue->phead = pTemp;
    }
    else {
        queue->pTail->pNext = pTemp;
    }
    queue->pTail = pTemp;
    queue->length++;
}


int Pop(Queue* queue) {
    if (queue == NULL) {
        printf("queue is not exist.\n");
        exit(1);
    }

    if (queue->length == 0) {
        printf("empty.\n");
        return -1;
    }
    node* pDel = queue->phead;
    int nNum = pDel->nValue;
    
    queue->phead = queue->phead->pNext;
    free(pDel);
    pDel = NULL;
    queue->length--;

    if (queue->length == 0)
    {
        queue->pTail = NULL;
    }
    return nNum;

}

int Top(Queue* queue) {
    if (queue == NULL) {
        printf("queue is not exist.\n");
        exit(0);
    }
    if (queue->length == 0){
        printf("empty.\n");
        return -1;
    }
    return queue->phead->nValue;
}


int Empty(Queue* queue) {
    if (queue->length == 0) {
        return 1;
    }
    else {
        return 0;
    }
}

int Clear(Queue* queue) {
    node* pTemp;
    node* pNode = queue->phead;
    while (pNode) {
        pTemp = pNode->pNext;
        free(pNode);
        pNode = pTemp;
    }
    queue->phead = NULL;
    queue->pTail = NULL;
    queue->length = 0;
}





int main()
{
    
    return 0;
}
```

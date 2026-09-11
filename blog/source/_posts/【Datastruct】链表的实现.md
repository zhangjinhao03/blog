---
title: 【Datastruct】链表的实现
date: 2022-11-14 18:14:32
tags: [C,List,Datastruct]
categories: Datastruct
series: 数据结构基础
top_img: /img/922387.jpg
cover: /img/922387.jpg
---

# 链表

纯C语言实现版本

 ```c
 #include<stdio.h>
 #include<stdlib.h>
 
 
 typedef struct ListNode {
 	int val;
 	struct ListNode* next;
 }ListNode;
 
 typedef struct ListHead {
 	struct ListNode* head;
 	struct ListNode* end;
 	int size;
 }ListHead;
 //创建链表
 ListHead* create_list() {
 	ListHead* list = (ListHead*)malloc(sizeof(ListHead));
 	list->end = NULL;
 	list->head = NULL;
 	return list;
 }
 
 //创建节点
 ListNode* create_node(int n) {
 	ListNode* pNode = (ListNode*)malloc(sizeof(ListNode));
 	pNode->val = n;
 	pNode->next = NULL;
 	return pNode;
 }
 
 //尾部添加节点
 void push_back(ListHead* list,int n) {
 	ListNode* pTemp = create_node(n);
 	if (list->head == NULL) {
 		list->head = pTemp;
 		list->end = pTemp;
 		return;
 	}
 	ListNode* pNode = list->head;
 	while (pNode->next != NULL) {
 		pNode = pNode->next;
 	}
 	pNode->next = pTemp;
 	list->end = pTemp;
 	return;
 }
 
 //头添加
 void push_front(ListHead* list, int n) {
 	ListNode* pTemp = create_node(n);
 	if (list->head == NULL) {
 		list->head = pTemp;
 		list->end = pTemp;
 		return;
 	}
 	ListNode* pNode = list->head;
 	list->head = pTemp;
 	pTemp->next = pNode;
 	return;
 }
 
 //删除链表
 void delete_list(ListHead* list) {
 	if (list->head == NULL) {
 		return;
 	}
 	ListNode* pNode = list->head;
 	ListNode* pTemp;
 	while (pNode != NULL) {
 		pTemp = pNode->next;
 		free(pNode);
 		pNode = pTemp;
 	}
 	list->head = NULL;
 	list->end = NULL;
 }
 
 //遍历打印链表
 void print_list(ListHead* list) {
 	ListNode* pNode = list->head;
 	if (pNode == NULL) {
 		printf("empty.\n");
 		return;
 	}
 	while (pNode != NULL) {
 		printf("%d\n", pNode->val);
 		pNode = pNode->next;
 	}
 	return;
 }
 
 //删除链表第index个元素
 int delete_index(ListHead* list,int index) {
 	ListNode* pNode = list->head;
 	if (pNode == NULL) {//判断链表是否为空
 		return 0;
 	}
 	if (index == 1) {//删除头节点
 		list->head = pNode->next;
 		free(pNode);
 		return 1;
 	}
 	int counter = 1;
 	while (pNode->next && counter < index-1) {
 		pNode = pNode->next;
 		counter++;
 	}
 	if (pNode->next == NULL || counter > index - 1) {//访问非法
 		return 0;
 	}
 	ListNode* pTemp = pNode->next;
 	pNode->next = pNode->next->next;
 	free(pTemp);
 	return 1;
 }
 
 //删除链表中所有值为n的元素
 int delete_num(ListHead* list,int n) {
 	ListNode* pNode = list->head;
 	if (pNode == NULL) {//判断链表是否为空
 		return 0;
 	}
 
 	if (pNode->val == n) {
 		list->head = pNode->next;
 		free(pNode);
 		return 1;
 	}
 
 	while (pNode->next) {
 		ListNode* pTemp = pNode->next;
 		if (pTemp->val == n) {
 			pNode->next = pNode->next->next;
 			free(pTemp);
 
 		}
 		else {
 			pNode = pNode->next;
 		}
 	}
 
 	return 1;//删除成功
 }
 
 //在第index个元素前插入元素n
 int insert_before(ListHead* list,int index,int n) {
 	ListNode* pNode = list->head;
 	if (pNode == NULL) {//判断链表是否为空
 		return 0;
 	}
 	if (index == 1) {
 		ListNode* pTemp = create_node(n);
 		pTemp->next = list->head;
 		list->head = pTemp;
 		return 1;
 	}
 	int counter = 1;
 	while (pNode->next && counter < index - 1) {
 		pNode = pNode->next;
 		counter++;
 	}
 
 	if (pNode->next == NULL || counter > index - 1) {
 		return 0;
 	}
 	ListNode* pTemp = create_node(n);
 	pTemp->next = pNode->next;
 	pNode->next = pTemp;
 	return 1;
 }
 
 //在第index个元素后插入元素n
 int insert_behind(ListHead* list,int index,int n) {
 	ListNode* pNode = list->head;
 	if (pNode == NULL) {//判断链表是否为空
 		return 0;
 	}
 	int counter = 1;
 	while (pNode && counter < index) {
 		pNode = pNode->next;
 		counter++;
 	}
 	if (pNode == NULL || counter > index) {
 		return 0;
 	}
 	ListNode* pTemp = create_node(n);
 	pTemp->next = pNode->next;
 	pNode->next = pTemp;
 	return 1;
 }
 
 //链表倒置
 void reverse_list(ListHead* list){
 	if (list->head == NULL || list->head->next == NULL) {//空链表和只有一个元素的链表
 		return;
 	}
 	//三个指针的办法
 	ListNode* pPro = NULL;
 	ListNode* pCur = list->head;
 	ListNode* pNext = list->head->next;
 	
 	while (pCur) {
 		pCur->next = pPro;
 		pPro = pCur;
 		pCur = pNext;
 		if (pNext) {
 			pNext = pNext->next;
 		}
 	}
 	list->head = pPro;
 }
 
 
 
 int main() {
 	printf("deal create_list.\n");
 	ListHead* list = create_list();
 	print_list(list);
 	printf("deal push_front.\n");
 	push_front(list, 5);
 	push_front(list, 4);
 	push_front(list, 3);
 	push_front(list, 2);
 	push_front(list, 1);
 	print_list(list);
 	printf("deal reverse_list.\n");
 	reverse_list(list);
 	print_list(list);
 	printf("deal delete_list.\n");
 	delete_list(list);
 	print_list(list);
 	return 0;
 }
 
 
 ```


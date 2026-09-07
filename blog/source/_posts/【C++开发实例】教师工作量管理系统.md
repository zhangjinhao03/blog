---
title: 【C++开发实例】教师工作量管理系统
date: 2022-11-16 19:50:22
tags: [CPP,List]
categories: Markdown
top_img: /img/img9.jpg
cover: /img/img9.jpg
---

# 教师工作量管理系统（链表应用）

> ### 题目描述
>
> 教师工作量管理系统问题描述：
> 已知一学校有4门课程（课程编号、课程名称，课时）,5个教师（教师号、姓名、性别、职称），在计算教师工作量时，其计算方法如下表：

| 班级数目 |    单个教学任务总课时     |
| :------: | :-----------------------: |
|   <=2    | 1.5*(理论课时＋实验课时） |
|    3     |  2*(理论课时＋实验课时）  |
|   >=4    | 2.5*(理论课时＋实验课时） |

> 编写一程序，完成以下功能：
> 1)能从文件导入教师的授课信息，文件格式如下：
> 教师编号 课程编号 上课学期
>
> 2)能从键盘录入教师授课信息；
>
> 3)能根据上课学期、课程编号删除授课信息；
>
> 4)能根据上课学期、课程编号修改授课教师；
>
> 5)能计算每个学期的教师工作量；
>
> 6)查询指定教师编号查询授课历史；
>
> 7)能将授课信息导出到文件。

### 初始信息

将课程信息、教师信息分别用结构体数组进行存储

```cpp
//存储课程信息
struct Course {
	int id;//课程编号
	int TheoryCHour;//理论学时
	int ExperiCHour;//实验学时
	char name[20];//课程名称
}cr[4];
//存储教师信息
struct Teacher {
	int id;//教师号
	char name[20];//姓名
	char sex[10];//性别
	char prof[20];//职称
}tr[5];
```

由于只有4门课程和5名教师，所以设置初始化函数来存储初始信息

```cpp
void InitTeacherInfo() {//教师信息初始化
	tr[0].id = 1001;
	strcpy(tr[0].name, "艾雪");
	strcpy(tr[0].sex, "女");
	strcpy(tr[0].prof, "副教授");

	tr[1].id = 1002;
	strcpy(tr[1].name, "张三");
	strcpy(tr[1].sex, "男");
	strcpy(tr[1].prof, "讲师");
	tr[2].id = 1003;
	strcpy(tr[2].name, "罗翔");
	strcpy(tr[2].sex, "男");
	strcpy(tr[2].prof, "教授");
	tr[3].id = 1004;
	strcpy(tr[3].name, "李四");
	strcpy(tr[3].sex, "男");
	strcpy(tr[3].prof, "副教授");
	tr[4].id = 1005;
	strcpy(tr[4].name, "王梅");
	strcpy(tr[4].sex, "女");
	strcpy(tr[4].prof, "助教");
}

void InitCourseInfo() {//课程信息初始化
	cr[0].id = 5001;
	cr[0].TheoryCHour = 28;
	cr[0].ExperiCHour = 8;
	strcpy(cr[0].name, "数据结构");
	cr[1].id = 5002;
	cr[1].TheoryCHour = 24;
	cr[1].ExperiCHour = 4;
	strcpy(cr[1].name, "单片机");
	cr[2].id = 5003;
	cr[2].TheoryCHour = 30;
	cr[2].ExperiCHour = 8;
	strcpy(cr[2].name, "c语言程序设计");
	cr[3].id = 5004;
	cr[3].TheoryCHour = 26;
	cr[3].ExperiCHour = 4;
	strcpy(cr[3].name, "数据库系统");
}
```

### 菜单部分

通过参数decide传入不同的值来打印角标在不同的位置，为了实现角标移动效果，在run()函数中调用语句

```cpp
system("cls");
```

来进行清屏处理

当键盘读取到w或↑时，对decide值进行减处理，反之加处理，当decide值越界时进行重置

```cpp
void printMenu1(int decide) {
	system("cls");
	printf("\n\n\n\n\n   -------------------------------\n");
	switch (decide) {
	case 1:
		printf("       >1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 2:
		printf("        1.从文件导入授课信息\n");
		printf("       >2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 3:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("       >3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 4:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("       >4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 5:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("       >5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 6:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("       >6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 7:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("       >7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 8:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("       >8.退出\n");
		break;
	}
	printf("   -------------------------------\n");
	printf("   ----按w s或↑↓选择菜单选项 ---\n");
}
```

### 数据结构

将教师授课信息及工作量信息用链表进行存储。在run函数中创建头节点。当信息增加时在链表尾部进行节点增加。信息修改只需遍历链表找到对应信息位置从而修改其值即可。删除信息同理需遍历链表找到对应信息位置删除节点，使被删除节点的前驱和后继相连。

```cpp
//链表定义
typedef struct Workload {
	int TheoryCHour;//课时
	int ExperiCHour;//课时
	int ClassNum;//班级数
	char term[10];
	struct Workload* next;
}Workload, * WorkList;
//存储教师授课信息
typedef struct Node {
	int tId;//教师号
	int cId;//课程编号
	char term[10];//学期
	struct Node* next;
}Node, * LinkList;
```

节点增加

```cpp
//节点增加
void ListAdd(LinkList L, int tid, int cid, char str[]) {
	int j;
	LinkList p, s;
	p = L;
	while (p->next) {
		p = p->next;
	}
	s = (LinkList)malloc(sizeof(Node));
	s->cId = cid;
	s->tId = tid;
	strcpy(s->term, str);
	p->next = s;
	s->next = NULL;
}
```

链表遍历

```cpp
//遍历
void TraverseList(LinkList L) {
	LinkList p, q;
	p = L->next;
	printf("教师授课历史\n\n\n");
	while (p) {
		printf("%d %d %s\n", p->cId, p->tId, p->term);
		p = p->next;
	}
	printf("\n\n\n");
}
```

### 功能实现

#### 查询历史信息

即遍历链表输出所有授课信息，直接调用遍历函数即可

```cpp
void InfoShow(LinkList L) {
	TraverseList(L);
}
```

#### 从键盘录入信息

输入题目要求的教师编号，课程编号和上课学期存储到相应变量，存储成功后调用节点增加函数即可实现存储信息

```cpp
void InfoInput(LinkList L) {
	int cid, tid;
	char str[10];
	printf("     信息录入:\n");
	printf("     请输入教师编号:\n");
	printf("     ");
	scanf("%d", &tid);
	printf("     请输入课程编号:\n");
	printf("     ");
	scanf("%d", &cid);
	printf("     请输入上课学期:\n");
	printf("     ");
	scanf("%s", str);
	ListAdd(L, tid, cid, str);//节点增加函数
	printf("信息录入成功！\n");
}
```

#### 信息删除和修改

输入课程编号和上课学期通过遍历链表查找信息，若未找到，打印“未查到该授课信息”退出函数，若找到在对应节点位置进行信息的修改和删除。

```cpp
void InfoDelete(LinkList L) {
	int cid;
	int flag = 0;
	char str[10];
	printf("     信息删除:\n");
	printf("     请输入课程编号:\n");
	printf("     ");
	scanf("%d", &cid);
	printf("     请输入上课学期:\n");
	printf("     ");
	scanf("%s", str);
	LinkList p, q;
	p = L;
	while (p->next) {
		if (p->next->cId == cid && !strcmp(p->next->term, str)) {
			flag = 1;
			break;
		}
		p = p->next;
	}
	if (!flag) {
		printf("未查到该授课信息\n");
		return;
	}
	q = p->next;
	p->next = q->next;
	free(q);//回收资源
	printf("信息删除成功！\n");
}

void InfoAlter(LinkList L) {
	int cid, tid;
	int flag = 0;
	char str[10];
	printf("     信息修改:\n");
	printf("     请输入课程编号:\n");
	printf("     ");
	scanf("%d", &cid);
	printf("     请输入上课学期:\n");
	printf("     ");
	scanf("%s", str);
	LinkList p;
	p = L;
	while (p->next) {
		if (p->next->cId == cid && !strcmp(p->next->term, str)) {
			flag = 1;
			break;
		}
		p = p->next;
	}
	if (!flag) {
		printf("未查到该授课信息\n");
		return;
	}
	p = p->next;
	printf("     当前授课信息为:\n");
	printf("     %d %d %s\n", p->cId, p->tId, p->term);
	printf("     是否修改？（y/n）\n     ");//询问是否修改
	char s;
	getchar();//吸收回车
	scanf("%c", &s);
	if (s == 'y' || s == 'Y') {
		printf("     请输入教师编号:\n");
		printf("     ");
		scanf("%d", &tid);
		printf("     请输入课程编号:\n");
		printf("     ");
		scanf("%d", &cid);
		printf("     请输入上课学期:\n");
		printf("     ");
		scanf("%s", str);
		p->tId = tid;
		p->cId = cid;
		strcpy(p->term, str);
		printf("信息修改成功！\n");
	}
	else {
		return;
	}
}
```

#### 工作量计算

是这里最复杂的一个函数，需要对两个链表进行操作。首先用户输入教师编号，并传参给函数，然后遍历教师信息查到后打印。接着遍历授课信息链表查找含有该教师编号的节点，一旦找到便存储到工作量信息链表中。

##### 如何存储到工作量信息链表中？

这里假设A教师有5次授课信息在授课信息链表中，其中1学期2次，2学期2次，3学期一次。由于工作量的计算是按照学期划分的，因此采用如下存储方式：

当第一次在授课信息链表中找到含有该教师编号的节点，直接存储到工作量信息链表中。

从第二次找到该教师编号的节点起，都遍历一次工作量信息链表，若有学期相同的节点，则不创建新节点存储工作量信息，而是和上一次存储的工作量信息进行叠加,班级数加一。

若遍历工作量信息链表后没有学期相同的节点，则再创建新节点存储。

##### 工作量信息计算

遍历工作量信息链表，对于每一个节点的课时，班级数来分类计算结果并输出。

```cpp
void WorkCalcul(LinkList L, int tid) {
	int i, flag = 0, j;
	LinkList p;
	WorkList w, s, tp;
	w = (WorkList)malloc(sizeof(Workload));
	w->next = NULL;
	s = w;
	p = L->next;
	for (i = 0; i < 5; i++) {
		if (tr[i].id == tid) {
			flag = 1;
			break;
		}
	}
	if (!flag) {
		printf("教师信息不存在:\n");
		return;
	}

	printf("教师信息:\n");
	printf("编号:%d\n", tr[i].id);
	printf("姓名:%s\n", tr[i].name);
	printf("性别:%s\n", tr[i].sex);
	printf("职称:%s\n", tr[i].prof);
	while (p) {
		if (p->tId == tid) {
			s = w;
			while (s->next) {
				if (!strcmp(s->next->term, p->term)) {
					for (i = 0; i < 4; i++) {
						if (cr[i].id == p->cId) {
							s->next->ExperiCHour += cr[i].ExperiCHour;
							s->next->TheoryCHour += cr[i].TheoryCHour;
						}
					}
					s->next->ClassNum++;
					break;
				}
				s = s->next;
			}
			if (!s->next) {
				tp = (WorkList)malloc(sizeof(Workload));
				tp->ClassNum = 1;
				strcpy(tp->term, p->term);
				for (i = 0; i < 4; i++) {
					if (cr[i].id == p->cId) {
						tp->ExperiCHour = cr[i].ExperiCHour;
						tp->TheoryCHour = cr[i].TheoryCHour;
					}
				}
				tp->next = NULL;
				s->next = tp;
			}
		}
		p = p->next;
	}
	printf("教师工作量:\n");
	s = w->next;
	while (s) {
		printf("学期:%s ", s->term);
		if (s->ClassNum <= 2) {
			printf("工作量:%.2f\n", (s->ExperiCHour + s->TheoryCHour) * 1.5);
		}
		else if (s->ClassNum == 3) {
			printf("工作量:%.2f\n", (s->ExperiCHour + s->TheoryCHour) * 2);
		}
		else {
			printf("工作量:%.2f\n", (s->ExperiCHour + s->TheoryCHour) * 2.5);
		}
		s = s->next;
	}
}
```

### 文件导入和输出

使用文件读取和写入操作，写入时直接将信息打印在txt文本中,读取时，先读取文本中字符串，再对字符串进行分解，分离出字符串中的int类型变量和字符串变量。这里注意不同的集成开发环境的编码方式不同，若和txt文本不是同一种编码方式则会出现乱码情况。

### 完整代码

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <conio.h>
#include <string.h>

//存储课程信息
struct Course {
	int id;//课程编号
	int TheoryCHour;//课时
	int ExperiCHour;//课时
	char name[20];//课程名称
}cr[4];
//存储教师信息
struct Teacher {
	int id;//教师号
	char name[20];//姓名
	char sex[10];//性别
	char prof[20];//职称
}tr[5];
//存储每学期工作量
typedef struct Workload {
	int TheoryCHour;//课时
	int ExperiCHour;//课时
	int ClassNum;
	char term[10];
	struct Workload* next;
}Workload, * WorkList;
//存储教师授课信息
typedef struct Node {
	int tId;//教师号
	int cId;//课程编号
	char term[10];
	struct Node* next;
}Node, * LinkList;
//节点增加
void ListAdd(LinkList L, int tid, int cid, char str[]) {
	int j;
	LinkList p, s;
	p = L;
	while (p->next) {
		p = p->next;
	}
	s = (LinkList)malloc(sizeof(Node));
	s->cId = cid;
	s->tId = tid;
	strcpy(s->term, str);
	p->next = s;
	s->next = NULL;
}
//遍历
void TraverseList(LinkList L) {
	LinkList p, q;
	p = L->next;
	printf("教师授课历史\n\n\n");
	while (p) {
		printf("%d %d %s\n", p->cId, p->tId, p->term);
		p = p->next;
	}
	printf("\n\n\n");
}

//1.从文件导入教师的授课信息
//教师编号 课程编号 上课学期
//
//7.能将授课信息导出到文件
//
//
//

void InitTeacherInfo() {
	tr[0].id = 1001;
	strcpy(tr[0].name, "艾雪");
	strcpy(tr[0].sex, "女");
	strcpy(tr[0].prof, "副教授");

	tr[1].id = 1002;
	strcpy(tr[1].name, "张三");
	strcpy(tr[1].sex, "男");
	strcpy(tr[1].prof, "讲师");
	tr[2].id = 1003;
	strcpy(tr[2].name, "罗翔");
	strcpy(tr[2].sex, "男");
	strcpy(tr[2].prof, "教授");
	tr[3].id = 1004;
	strcpy(tr[3].name, "李四");
	strcpy(tr[3].sex, "男");
	strcpy(tr[3].prof, "副教授");
	tr[4].id = 1005;
	strcpy(tr[4].name, "王梅");
	strcpy(tr[4].sex, "女");
	strcpy(tr[4].prof, "助教");
}

void InitCourseInfo() {
	cr[0].id = 5001;
	cr[0].TheoryCHour = 28;
	cr[0].ExperiCHour = 8;
	strcpy(cr[0].name, "数据结构");
	cr[1].id = 5002;
	cr[1].TheoryCHour = 24;
	cr[1].ExperiCHour = 4;
	strcpy(cr[1].name, "单片机");
	cr[2].id = 5003;
	cr[2].TheoryCHour = 30;
	cr[2].ExperiCHour = 8;
	strcpy(cr[2].name, "c语言程序设计");
	cr[3].id = 5004;
	cr[3].TheoryCHour = 26;
	cr[3].ExperiCHour = 4;
	strcpy(cr[3].name, "数据库系统");
}

void printMenu1(int decide) {
	system("cls");
	printf("\n\n\n\n\n   -------------------------------\n");
	switch (decide) {
	case 1:
		printf("       >1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 2:
		printf("        1.从文件导入授课信息\n");
		printf("       >2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 3:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("       >3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 4:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("       >4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 5:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("       >5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 6:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("       >6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 7:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("       >7.授课信息导出到文件\n");
		printf("        8.退出\n");
		break;
	case 8:
		printf("        1.从文件导入授课信息\n");
		printf("        2.授课信息录入\n");
		printf("        3.授课信息删除\n");
		printf("        4.授课教师修改\n");
		printf("        5.工作量计算\n");
		printf("        6.查询授课历史\n");
		printf("        7.授课信息导出到文件\n");
		printf("       >8.退出\n");
		break;
	}
	printf("   -------------------------------\n");
	printf("   ----按w s或↑↓选择菜单选项 ---\n");
}

void InfoInput(LinkList L) {
	int cid, tid;
	char str[10];
	printf("     信息录入:\n");
	printf("     请输入教师编号:\n");
	printf("     ");
	scanf("%d", &tid);
	printf("     请输入课程编号:\n");
	printf("     ");
	scanf("%d", &cid);
	printf("     请输入上课学期:\n");
	printf("     ");
	scanf("%s", str);
	ListAdd(L, tid, cid, str);
	printf("信息录入成功！\n");
}

void InfoDelete(LinkList L) {
	int cid;
	int flag = 0;
	char str[10];
	printf("     信息删除:\n");
	printf("     请输入课程编号:\n");
	printf("     ");
	scanf("%d", &cid);
	printf("     请输入上课学期:\n");
	printf("     ");
	scanf("%s", str);
	LinkList p, q;
	p = L;
	while (p->next) {
		if (p->next->cId == cid && !strcmp(p->next->term, str)) {
			flag = 1;
			break;
		}
		p = p->next;
	}
	if (!flag) {
		printf("未查到该授课信息\n");
		return;
	}
	q = p->next;
	p->next = q->next;
	free(q);//回收资源
	printf("信息删除成功！\n");
}

void InfoAlter(LinkList L) {
	int cid, tid;
	int flag = 0;
	char str[10];
	printf("     信息修改:\n");
	printf("     请输入课程编号:\n");
	printf("     ");
	scanf("%d", &cid);
	printf("     请输入上课学期:\n");
	printf("     ");
	scanf("%s", str);
	LinkList p;
	p = L;
	while (p->next) {
		if (p->next->cId == cid && !strcmp(p->next->term, str)) {
			flag = 1;
			break;
		}
		p = p->next;
	}
	if (!flag) {
		printf("未查到该授课信息\n");
		return;
	}
	p = p->next;
	printf("     当前授课信息为:\n");
	printf("     %d %d %s\n", p->cId, p->tId, p->term);
	printf("     是否修改？（y/n）\n     ");
	char s;
	getchar();//吸收回车
	scanf("%c", &s);
	if (s == 'y' || s == 'Y') {
		printf("     请输入教师编号:\n");
		printf("     ");
		scanf("%d", &tid);
		printf("     请输入课程编号:\n");
		printf("     ");
		scanf("%d", &cid);
		printf("     请输入上课学期:\n");
		printf("     ");
		scanf("%s", str);
		p->tId = tid;
		p->cId = cid;
		strcpy(p->term, str);
		printf("信息修改成功！\n");
	}
	else {
		return;
	}
}

void InfoShow(LinkList L) {
	TraverseList(L);
}

void WorkCalcul(LinkList L, int tid) {
	int i, flag = 0, j;
	LinkList p;
	WorkList w, s, tp;
	w = (WorkList)malloc(sizeof(Workload));
	w->next = NULL;
	s = w;
	p = L->next;
	for (i = 0; i < 5; i++) {
		if (tr[i].id == tid) {
			flag = 1;
			break;
		}
	}
	if (!flag) {
		printf("教师信息不存在:\n");
		return;
	}

	printf("教师信息:\n");
	printf("编号:%d\n", tr[i].id);
	printf("姓名:%s\n", tr[i].name);
	printf("性别:%s\n", tr[i].sex);
	printf("职称:%s\n", tr[i].prof);
	while (p) {
		if (p->tId == tid) {
			s = w;
			while (s->next) {
				if (!strcmp(s->next->term, p->term)) {
					for (i = 0; i < 4; i++) {
						if (cr[i].id == p->cId) {
							s->next->ExperiCHour += cr[i].ExperiCHour;
							s->next->TheoryCHour += cr[i].TheoryCHour;
						}
					}
					s->next->ClassNum++;
					break;
				}
				s = s->next;
			}
			if (!s->next) {
				tp = (WorkList)malloc(sizeof(Workload));
				tp->ClassNum = 1;
				strcpy(tp->term, p->term);
				for (i = 0; i < 4; i++) {
					if (cr[i].id == p->cId) {
						tp->ExperiCHour = cr[i].ExperiCHour;
						tp->TheoryCHour = cr[i].TheoryCHour;
					}
				}
				tp->next = NULL;
				s->next = tp;
			}
		}
		p = p->next;
	}
	printf("教师工作量:\n");
	s = w->next;
	while (s) {
		printf("学期:%s ", s->term);
		if (s->ClassNum <= 2) {
			printf("工作量:%.2f\n", (s->ExperiCHour + s->TheoryCHour) * 1.5);
		}
		else if (s->ClassNum == 3) {
			printf("工作量:%.2f\n", (s->ExperiCHour + s->TheoryCHour) * 2);
		}
		else {
			printf("工作量:%.2f\n", (s->ExperiCHour + s->TheoryCHour) * 2.5);
		}
		s = s->next;
	}
}

void run() {
	char keyIn;
	int decide = 1;
	LinkList L;
	L = (LinkList)malloc(sizeof(Node));
	L->next = NULL;
begin:
	printMenu1(decide);
	while (1) {
		keyIn = _getch();
		if (keyIn == 13) {
			break;//回车检测
		}
		switch (keyIn)
		{
		case 'w':
		case 'W':
		case 72:
			decide--;
			break;
		case 's':
		case 'S':
		case 80:
			decide++;
			break;
		default:
			break;
		}
		if (decide > 8) {
			decide = 1;
		}
		else if (decide < 1) {
			decide = 8;
		}
		printMenu1(decide);
	}
	if (decide == 1) {//1.从文件导入授课信息
		system("cls");
		int tid = 0, cid = 0;
        int flag = 0;
        char term[10];

        FILE* p;
        char ch;
        char str[10005];//用来存储txt文件中的字符串
        int i, num[256] = { 0 };
        if ((p = fopen("D:\\test.txt", "r")) == NULL)  //以只读的方式打开test。
        {
            printf("ERROR");
        }
        int k = 0;
        for (; ch != '\n';)
        {
            ch = fgetc(p);   //ch得到p所指文件中的每一个字符
            if (ch != 32) {
                str[k] = ch;
                k++;
            }
            else {
                int j = 0;
                for (j = 0; str[j] != '\0'; j++) {
                    if (!flag)
                        tid = tid * 10 + str[j] - '0';
                    else
                        cid = cid * 10 + str[j] - '0';
                }
                k = 0;
                flag = 1;
            }
        }
        strcpy(term, str);
        printf("\n%d %d %s\n", tid, cid, str);
        ListAdd(L, tid, cid, str);
        printf("从文件录入信息录入成功！\n");
        fclose(p);	//关闭文件
		printf("按任意键返回上一级");
		getch();
		goto begin;
	}
	else if (decide == 2) {//2.授课信息录入
		system("cls");
		InfoInput(L);
		printf("按任意键返回上一级");
		getch();
		system("cls");
		goto begin;
	}
	else if (decide == 3) {//3.授课信息删除
		system("cls");
		InfoDelete(L);
		printf("按任意键返回上一级");
		getch();
		goto begin;
	}
	else if (decide == 4) {//4.授课教师修改
		system("cls");
		InfoAlter(L);
		printf("按任意键返回上一级");
		getch();
		goto begin;
	}
	else if (decide == 5) {//5.工作量计算
		system("cls");
		int id;
		printf("请输入教师编号:\n");
		scanf("%d", &id);
		WorkCalcul(L, id);
		printf("按任意键返回上一级");
		getch();
		goto begin;
	}
	else if (decide == 6) {//6.查询授课历史
		system("cls");
		InfoShow(L);
		printf("按任意键返回上一级");
		getch();
		goto begin;
	}
	else if (decide == 7) {//7.授课信息导出到文件
		system("cls");
		FILE* f;
		f = fopen("D:\\info.txt", "w");//导入文件路径
		if (f != NULL)
		{
			LinkList p, q;
			p = L->next;
			fputs("教师授课信息:\n", f);
			while (p) {
				fprintf(f, "%d %d %s\n", p->cId, p->tId, p->term);
				p = p->next;
			}
			fclose(f);
			f = NULL;
		}
		printf("授课信息已导出到文件D:\\info.txt\n");
		printf("按任意键返回上一级");
		getch();
		goto begin;
	}
	else if (decide == 8) {//退出
		system("cls");
		printf("\n\n\n\n\n   -------------------------------\n");
		printf("\n\n\n\n               Bye~\n\n\n\n\n");
		printf("   -------------------------------\n\n\n\n\n\n");
	}


}

int main() {
	InitTeacherInfo();//教师信息初始化
	InitCourseInfo();//课程信息初始化
	run();

	return 0;
}
```


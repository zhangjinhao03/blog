---
title: 【JAVA】毕业设计题目的分配
date: 2021-10-30
tags: Java
categories: Java
top_img: /img/img7.jpg
cover: /img/img7.jpg
---

以此博客记录大二上学期我的一次java作业

> ## 毕业设计题目的分配
>
> 毕业设计分配过程如下： 
> 1. 指导教师出题目； 
> 2. 学生选择。 学生选择时常常会有两种目标： 选择自己感兴趣的题目；选择自己感兴趣的教师。 
> 3. 若教授可以带5名学生，副教授带4名学生，讲师带3名学生，请编写程序，完成毕业设计分配，让学生以选择导师或题目的形式灵活分配。 
>
> ps: 为了降低难度，假设题目的数量和学生的数量刚好相等。 
> 尽你所学对程序功能进行完善，可不局限于题目基本要求。 请考虑面向对象思想，设计几个类，类中包含何种数据、何种方法。

在前面改了很多次后面java老师又加了很多要求...

> #### 题目要求重新整理
>
> 1.首先一个教师出多道题,题数根据教师等级决定,并且题目数量要可以更改,程序灵活性要体现
> 2.一个学生只能选一道题选过以后其他学生不能再选,当题目已被选过时要有提示
> 3.为了方便学生选题,在选择时要把题目是否已被选过显示出来
> 4.教师要能够对学生成绩评判,学生成绩要能显示出来
> 5.学生选的题目要可更换
> 6.毕业设计题目分配的展示

## 学生类

```java
public class Students {
	protected int num;//学号
	protected int score;//得分
	protected String name;//姓名
	protected String sex;//性别
	protected String teacher;//学生选择的题目的出题教师
	protected String que;//选择的题目
	public Students (){}
	public Students(String name,String sex,int num,String teacher,String que){//构造方法中初始化
		this.name = name;
		this.sex = sex;
		this.num = num;
		this.teacher = teacher;
		this.que = que;
	}
	public void setName(String name){
		this.name = name;
	}
	public void setSex(String sex){
		this.sex = sex;
	}
	public void setNum(int a){
		this.num = a;
	}
	public void setTeacher(String a){
		this.teacher = a;
	}
	public void setQuestion(String a){
		this.que = a;
	}
	public void setScore(int a){
		this.score = a;
	}
	public String getName(){
		return name;
	}
	public String getSex(){
		return sex;
	}
	public int getNum(){
		return num;
	}
	public String getTeacher(){
		return teacher;
	}
	public String getQuesion(){
		return que;
	}
	public int getScore(){
		return score;
	}
	public void show() {//学生信息打印
		System.out.println("姓名: "+name+"; 性别: "+sex+"; 学号: "+num+"; 指导教师: "+teacher+"; 题目: "+que+";");
	}
}
```

## 教师类

教师类复杂些,因为学生选题时 题目是否已经选过的功能实现在教师类中完成了
这里我添加了索引变量dex来记录选择该教师的学生,stnums是教师出题数目,这样当dex<stnums时,学生可选择该教师,否则不行,教师出的题目使用字符串型数组来储存
这里最难理解的是a数组和b数组

##### a数组

由于学生选题后,要实现毕业设计题目的分配,因此在分配时会首先显示教师信息,对应显示选择该教师的题目的学生,由a数组记录选择该教师的学生的编号(一个编号要对应一个学生),这样方便信息展出

##### b数组

当学生选择题目标准来选题时,判断该题目是否被选用b数组来记录,即0未选/1已选,b中数据与question相对应
如:question[1]被选,则b[1]=1,question[4]未被选,则b[4]=0,

```java
public class Teachers {//教师类
	protected String name;//姓名
	protected String level;//职务
	protected int stnums = 0;//出题数
	public int dex = 0;//已选学生数
	public int a[] = new int[10];//记选课学生编号数组
	public String[] question = new String[5]; //开设的题目
	public int b[] = new int[10];//记录题目是否被选，0未选/1已选
	public Teachers(){}
	public Teachers(String name,String level,int stnums){//初始化构造方法
		this.name = name;
		this.level = level;
		this.stnums = stnums;
	}
	public void setName(String name){
		this.name = name;
	}
	public void setlevel(String level){
		this.level = level;
	}
	public void setnum(int stnums){
		this.stnums = stnums;
	}
	public String getName(){
		return name;
	}
	public String getlevel(){
		return level;
	}
	public int getnum(){
		return stnums;
	}
	public void show() {//教师信息打印
		System.out.println("姓名: "+name+"; 职务: "+level+"; 开设题目: ");
		for(int i = 0;i < stnums;i++) {
			System.out.println(question[i]);
		}
	}
	public void showplus() {//教师姓名职务打印
		System.out.println("姓名: "+name+"; 职务: "+level);
	}
}

```

## 清屏类

该类的作用不大,而且使用受限,只有鼠标在命令框中才能实现,它的功能类似C语言的system(“cls”);只是为了程序运行的观赏性添加的,可以去掉

注释:该类是我从另一个博主那学来的,这里有他的博客链接,尊重版权
https://blog.csdn.net/qq_18144681/article/details/51222405?utm_source=app&app_version=4.15.0&code=app_1562916241&uLinkId=usr1mkqgl919blen

```java
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
public class Clear {//清屏程序 用于更新页面
	public Clear() {}
	@SuppressWarnings("deprecation")//去除警告(不重要,不加也没事,只是笔者是强迫症,看着黄标警告烦)
	public static void clear() throws AWTException
    {
        Robot r = new Robot();
        r.mousePress(InputEvent.BUTTON3_MASK);       // 按下鼠标右键
        r.mouseRelease(InputEvent.BUTTON3_MASK);    // 释放鼠标右键
        r.keyPress(KeyEvent.VK_CONTROL);             // 按下Ctrl键
        r.keyPress(KeyEvent.VK_R);                    // 按下R键
        r.keyRelease(KeyEvent.VK_R);                  // 释放R键
        r.keyRelease(KeyEvent.VK_CONTROL);            // 释放Ctrl键
        r.delay(100);       

    }

}
```

## main类

这里我将菜单中的每一个功能都用一个方法来实现

```java
package MainPackage;

import java.awt.AWTException;
import java.util.Scanner;

//！！！本程序作者： YYDS 的张缙豪大神！！！
//@敲代码的猫
//----------------------------------------------------------------------------------------
public class MainClass {
//----------------------------------------------------------------------------------------
	public static void teaShow(int n, Teachers[] tea, int teaNum) {// 指导教师信息
		// TODO teaShow
		for (int i = 0; i < n; i++) {
			System.out.print((i + 1) + ": ");// 教师编号
			tea[i].show();
		}
	}

//----------------------------------------------------------------------------------------
	@SuppressWarnings("static-access")
	public static void teaAdd(int teaNum, Teachers[] tea, int at) throws AWTException {// 指导教师信息添加
		// TODO teaAdd
		@SuppressWarnings("resource")
		Scanner input = new Scanner(System.in);
		Clear r = new Clear();
		String str1, str2, s;
		int flag = 1;
		System.out.println("请完善指导教师信息：");
		for (int i = 1; i <= teaNum; i++) {
			// 教师信息初始化
			r.clear();
			tea[i + at - teaNum - 1] = new Teachers();
			System.out.println("第" + i + "条信息");
			System.out.println("请输入指导教师姓名：");
			str1 = input.next();
			tea[i + at - teaNum - 1].setName(str1);// at - teaNum为已添加教师数
			do {// 通过do-while解决输入错误后重新输入问题
				flag = 250;
				System.out.println("请输入指导教师职务：(教授/副教授/讲师)");
				str2 = input.next();
				tea[i + at - teaNum - 1].setlevel(str2);
				if (str2.equals("教授")) {// 教师带学生人数初始化
					flag = 1;
				} else if (str2.equals("副教授")) {
					flag = 2;
				} else if (str2.equals("讲师")) {
					flag = 3;
				} else {
					System.out.println("输入错误，请重新输入！");
					flag = 250;
				}
			} while (flag == 250);
			if (flag == 1) {// 设置教师出题数目
				tea[i + at - teaNum - 1].setnum(5);
			} else if (flag == 2) {
				tea[i + at - teaNum - 1].setnum(4);
			} else {
				tea[i + at - teaNum - 1].setnum(3);
			}
			// ----------------------------
			System.out.println("是否对教师出题数目进行更改？(Y/N)");// 教师开设题目初始化
			s = input.next();
			if (s.charAt(0) == 'Y' || s.charAt(0) == 'y') {
				dexchange(tea, at);
			} else {
				System.out.println("教师出题：");
				for (int j = 0; j < tea[i + at - teaNum - 1].getnum(); j++) {
					System.out.println("请输入第" + (j + 1) + "题：");
					tea[i + at - teaNum - 1].question[j] = input.next();
				}
			}
		}
	}
//----------------------------------------------------------------------------------------
	@SuppressWarnings("static-access")
	public static void stuAdd(int n, int stunum, Teachers[] tea, int at, Students[] stu) throws AWTException {// 学生信息添加
		// TODO stuAdd
		String str01, str02, str03, str04 = "", tta = "教师", pro = "题目", str = "";
		@SuppressWarnings("resource")
		Scanner input = new Scanner(System.in);
		Clear r = new Clear();
		int num, flag = 0, f = 0, f1 = 0, kong = 0, kong1 = 0;
		for (int i = stunum - n; i < stunum; i++) {
			r.clear();
			System.out.println("第" + (i + 1) + "名学生：");
			stu[i] = new Students();//
			System.out.println("请输入学生姓名：");
			str01 = input.next();
			stu[i].setName(str01);
			System.out.println("请输入学生性别：（男/女）");
			str02 = input.next();
			stu[i].setSex(str02);
			System.out.println("请输入学生学号：");
			num = input.nextInt();
			stu[i].setNum(num);
			// -----------------------------------------------------------学生选题部分
			System.out.println("请输入学生选课标准：(教师/题目)");// 根据学生选题标准进行分配
			do {
				f = 0;
				str03 = input.next();
				if (str03.equals("题目") || str03.equals("教师")) {
					f = 1;
				} else {
					System.out.println("输入错误，请重新输入：");
				}
			} while (f == 0);
			if (str03.equals(tta)) {// str03 --> 教师/题目
				System.out.println("请输入学生喜欢的指导教师：");
				do {
					f1 = 0;// 判断教师带学生人数是否已满
					kong = 0;
					str04 = input.next();
					for (int j = 0; j < at; j++) {
						if (tea[j].getName().equals(str04)) {// str04-->教师姓名
							kong = 1;// 确实是否有该教师姓名
							if (tea[j].dex == tea[j].stnums) {
								f1 = 0;
								System.out.println("该教师课题人数已满，请重新选择：");
							} else {
								f1 = 1;
								str = str04;
								stu[i].setTeacher(str);
								System.out.println("该教师开设了如下课程：");
								for (int k = 0; k < tea[j].stnums; k++) {
									System.out.print(tea[j].question[k] + "  ");
									if (tea[j].b[k] == 1) {
										showR();
									} else {
										showN();
									}
								}
								System.out.println("请选择：");
								do {
									flag = 0;// 判断输入合法性
									kong1 = 0;// 判断人满
									str04 = input.next();
									for (int k = 0; k < tea[j].stnums; k++) {
										if (tea[j].question[k].equals(str04)) {
											kong1 = 1;
											if (tea[j].b[k] == 0) {
												stu[i].setQuestion(str04);
												tea[j].b[k] = 1;
												tea[j].a[tea[j].dex] = i;
												tea[j].dex++;
												flag = 1;
												break;
											} else {
												flag = 0;
											}
										}
										if (flag == 1)
											break;
									}
									if (flag == 0 && kong1 == 1) {
										System.out.println("该选题人数已满，请重新选择：");
									} else if (flag == 0 && kong1 == 0) {
										System.out.println("无此题目，请重新输入：");
									}
								} while (flag == 0);
							}
						}
					}
					if (kong == 0) {
						System.out.println("查无此人，请重新输入：");
					}
				} while (f1 == 0);
			} else if (str03.equals(pro)) {
				System.out.println("所有题目展示：");
				queshow(tea, at);
				System.out.println("请输入感兴趣的题目：");
				do {
					flag = 0;
					kong = 0;
					str04 = input.next();
					for (int j = 0; j < at; j++) {
						for (int k = 0; k < tea[j].getnum(); k++) {
							if (tea[j].question[k].equals(str04)) {
								kong = 1;// 找到题目标记
								if (tea[j].b[k] == 0) {
									tea[j].b[k] = 1;
									tea[j].a[tea[j].dex] = i;
									tea[j].dex++;
									flag = 1;
									str = tea[j].getName();
									stu[i].setTeacher(str);
									stu[i].setQuestion(str04);
									break;
								} else {
									flag = 0;
									break;
								}
							}
						}
						if (flag == 1)
							break;
					}
					if (flag == 0 && kong == 1) {
						System.out.println("该选题已被选，请重新选择：");
					}
					if (flag == 0 && kong == 0) {
						System.out.println("查无此题，请重新输入：");
					}
				} while (flag == 0);
			}
		}
	}

//----------------------------------------------------------------------------------------
	public static void stuShow(int stunum, Students[] stu) {// 学生信息展示
		// TODO stuShow
		for (int i = 0; i < stunum; i++) {
			stu[i].show();
		}
	}

//----------------------------------------------------------------------------------------
	public static void graShow(Students[] stu, Teachers[] tea, int at) {// 毕业设计分配展示
		// TODO graShow
		for (int i = 0; i < at; i++) {
			tea[i].showplus();
			System.out.println("所带学生：");
			for (int j = 0; j < tea[i].dex; j++) {
				stu[tea[i].a[j]].show();
			}
			System.out.println("\n\n");
		}
	}

//----------------------------------------------------------------------------------------
	public static void stuExchange(int stunum, Teachers[] tea, int at, Students[] stu) {// 学生更改题目
		// TODO stuExchange
		// 分为信息录入和信息删除
		String str03, str04 = "", tta = "教师", pro = "题目", str = "", s;
		@SuppressWarnings("resource")
		Scanner input = new Scanner(System.in);
		int n, dex = 0, flag = 0, kong = 0, kong1 = 0, f = 0, f1 = 0, x = 0;
		System.out.println("请输入学生学号：");
		n = input.nextInt();// 用于学号对比的中间变量
		System.out.println("该学生信息如下：");
		for (int i = 0; i < stunum; i++) {
			if (stu[i].num == n) {
				stu[i].show();
				dex = i;
				System.out.print("\n");
			}
		}
		System.out.println("是否更改选题？(Y/N)");
		s = input.next();
		if (s.charAt(0) == 'Y' || s.charAt(0) == 'y') {
			// 先前信息删除
			for (int i = 0; i < at; i++) {
				if (stu[dex].getTeacher().equals(tea[i].getName())) {
					tea[i].dex--;
					for (int j = 0; j < tea[i].dex; j++) {
						if (tea[i].a[j] == dex) {
							x = 1;
						}
						if (x == 1) {
							tea[i].a[j] = tea[i].a[j + 1];
						}
					}
					break;
				}
			}
			// 重新选题后信息录入
			System.out.println("请输入学生选课标准：(教师/题目)");
			do {
				f = 0;
				str03 = input.next();
				if (str03.equals("题目") || str03.equals("教师")) {
					f = 1;
				} else {
					System.out.println("输入错误，请重新输入：");
				}
			} while (f == 0);
			if (str03.equals(tta)) {
				System.out.println("请输入学生喜欢的指导教师：");
				do {
					flag = 0;
					f1 = 0;
					kong = 0;
					str04 = input.next();
					for (int j = 0; j < at; j++) {
						if (tea[j].getName().equals(str04)) {
							kong = 1;// 确实是否有该教师姓名
							if (tea[j].dex == tea[j].stnums) {
								f1 = 0;
								System.out.println("该教师课题人数已满，请重新选择：");
							} else {
								f1 = 1;
								str = str04;
								System.out.println("该教师开设了如下课程：");
								for (int k = 0; k < tea[j].stnums; k++) {
									System.out.println(tea[j].question[k]);
								}
								System.out.println("请选择：");
								do {
									flag = 0;
									kong1 = 0;
									str04 = input.next();
									for (int k = 0; k < tea[j].stnums; k++) {
										if (tea[j].question[k].equals(str04)) {
											kong1 = 1;
											if (tea[j].b[k] == 0) {
												tea[j].b[k] = 1;
												tea[j].a[tea[j].dex] = dex;
												tea[j].dex++;
												flag = 1;
												break;
											} else {
												flag = 0;
											}
										}
										if (flag == 1)
											break;
									}
									if (flag == 0 && kong1 == 1) {
										System.out.println("该选题人数已满，请重新选择：");
									} else if (flag == 0 && kong1 == 0) {
										System.out.println("无此题目，请重新输入：");
									}
								} while (flag == 0);
							}

						}
					}
					if (kong == 0) {
						System.out.println("查无此人，请重新输入：");
					}
				} while (f1 == 0);
			} else if (str03.equals(pro)) {
				System.out.println("所有题目展示：");
				queshow(tea, at);
				System.out.println("请输入感兴趣的题目：");
				do {
					flag = 0;
					kong = 0;
					str04 = input.next();
					for (int j = 0; j < at; j++) {
						for (int k = 0; k < tea[j].getnum(); k++) {
							if (tea[j].question[k].equals(str04)) {
								kong = 1;// 找到题目标记
								if (tea[j].b[k] == 0) {
									tea[j].b[k] = 1;
									tea[j].a[tea[j].dex] = dex;
									tea[j].dex++;
									flag = 1;
									str = tea[j].getName();
									break;
								} else {
									flag = 0;
									break;
								}
							}
						}
						if (flag == 1)
							break;
					}
					if (flag == 0 && kong == 1) {
						System.out.println("该选题已被选，请重新选择：");
					}
					if (flag == 0 && kong == 0) {
						System.out.println("查无此题，请重新输入：");
					}
				} while (flag == 0);
			}
			stu[dex].setQuestion(str04);
			stu[dex].setTeacher(str);

		}
	}

//----------------------------------------------------------------------------------------
	public static void juDge(Students[] stu, Teachers[] tea, int at) {// 成绩评判
		// TODO judge
		@SuppressWarnings("resource")
		Scanner input = new Scanner(System.in);
		int flag = 0;
		System.out.println("请输入指导教师姓名:");
		do {
			String s = input.next();
			int n;
			for (int i = 0; i < at; i++) {
				if (tea[i].getName().equals(s)) {
					flag = 1;
					System.out.println("请为学生打分:");
					for (int j = 0; j < tea[i].dex; j++) {
						System.out.println("第" + (j + 1) + "名学生： ");
						stu[tea[i].a[j]].show();
						System.out.println("该生选题为： ");
						System.out.print(stu[tea[i].a[j]].getQuesion());
						System.out.println("该学生的成绩为：");
						n = input.nextInt();
						stu[tea[i].a[j]].setScore(n);
					}
				}
			}
			if (flag == 0) {
				System.out.println("查无此人请重新输入:");
			}
		} while (flag == 0);
	}

//----------------------------------------------------------------------------------------
	public static void scoShow(Students[] stu, Teachers[] tea, int at) {// 成绩显示
		// TODO judge
		@SuppressWarnings("resource")
		Scanner input = new Scanner(System.in);
		System.out.println("请输入指导教师姓名:");
		String s = input.next();
		Students t = new Students();
		for (int i = 0; i < at; i++) {
			if (tea[i].getName().equals(s)) {
				System.out.print("该指导教师开设的毕业设计题目为： ");
				for (int j = 0; j < tea[i].getnum(); j++) {
					System.out.println(tea[i].question[j]);
				}
				System.out.print("\n");
				System.out.println("学生成绩如下： ");
				int p;
				for (int j = 0; j < tea[i].dex; j++) {
					p = j;
					for (int k = j; k < tea[i].dex; k++) {
						if (stu[tea[i].a[p]].score > stu[tea[i].a[k]].score) {
							p = k;
						}
					}
					t = stu[tea[i].a[j]];
					stu[tea[i].a[j]] = stu[tea[i].a[p]];
					stu[tea[i].a[p]] = t;
				}
				for (int j = 0; j < tea[i].dex; j++) {
					System.out.print(stu[tea[i].a[j]].getName() + ": ");
					System.out.print(stu[tea[i].a[j]].getScore() + " ");
					if (stu[tea[i].a[j]].getScore() < 60) {
						System.out.print("差");
					} else if (stu[tea[i].a[j]].getScore() >= 60 && stu[tea[i].a[j]].getScore() < 90) {
						System.out.print("良");
					} else if (stu[tea[i].a[j]].getScore() >= 90) {
						System.out.print("优");
					}
					System.out.print("\n");
				}
				break;
			}
		}

	}

//----------------------------------------------------------------------------------------
	public static void dexchange(Teachers[] tea, int at) {// 出题数目更改
		// TODO dexchange
		@SuppressWarnings("resource")
		Scanner input = new Scanner(System.in);
		String s = "", str = "";
		int n, flag = 0;
		System.out.println("请输入教师姓名:");
		do {
			str = input.next();
			for (int i = 0; i < at; i++) {
				if (tea[i].getName().equals(str)) {
					flag = 1;
					System.out.println("是否确认更改(Y/N)注：默认:教授5/副教授4/讲师3");
					s = input.next();
					if (s.charAt(0) == 'Y' || s.charAt(0) == 'y') {
						System.out.println("请输入更改后出题数目：");
						n = input.nextInt();
						tea[i].setnum(n);// 控制教师所出题目数量，以保证出题数更改后先前题目会丢失！！！
						System.out.println("题目数已更改！请重新出题:");
						for (int j = 0; j < tea[i].getnum(); j++) {
							System.out.println("请输入第" + (j + 1) + "题：");
							tea[i].question[j] = input.next();
						}
					}
					break;
				}
			}
			if (flag == 0) {
				System.out.println("查无此人请重新输入：");
			}
		} while (flag == 0);
	}

//----------------------------------------------------------------------------------------
	public static void queshow(Teachers[] tea, int at) {// 所有题目展示
		// TODO dexchange
		for (int i = 0; i < at; i++) {
			for (int j = 0; j < tea[i].getnum(); j++) {
				System.out.print(tea[i].question[j] + "  ");
				if (tea[i].b[j] == 1) {
					showR();// 已经被选
				} else {
					showN();// 未被选择
				}
			}
		}
	}

//----------------------------------------------------------------------------------------
	public static void showR() {// 输出“该题已经被选”
		System.out.println("该题目已经被选");
	}

//----------------------------------------------------------------------------------------
	public static void showN() {// 输出“该题未被选”
		System.out.println("该题目可选择");
	}

//----------------------------------------------------------------------------------------
	@SuppressWarnings("static-access")
	public static void main(String[] args) throws AWTException {// 主类（菜单显示，菜单选项）
// TODO main
		@SuppressWarnings("resource")
//----------------------------------------------------------------------------------------
//初始化设置
		Scanner input = new Scanner(System.in);
		Clear r = new Clear();
		@SuppressWarnings("unused")
		String select = "", balabala = "";
		int teaNum = 0, at = 3, stunum = 0, num = 0, n = 0;
		Teachers[] tea = new Teachers[20];
		Students[] stu = new Students[20];
		tea[0] = new Teachers("唐长老", "教授", 5);
		tea[1] = new Teachers("莉莉", "副教授", 4);
		tea[2] = new Teachers("叶飞", "讲师", 3);
		tea[0].question[0] = "新式算法的应用设计";
		tea[0].question[1] = "网络安全软件的设计";
		tea[0].question[2] = "单片机嵌入式的设计";
		tea[0].question[3] = "教师管理系统的设计";
		tea[0].question[4] = "教务在线系统的设计";
		tea[1].question[0] = "医院管理系统的设计";
		tea[1].question[1] = "销售管理系统的设计";
		tea[1].question[2] = "班级管理系统的设计";
		tea[1].question[3] = "财务管理系统的设计";
		tea[2].question[0] = "菜单管理系统的设计";
		tea[2].question[1] = "游戏运行系统的设计";
		tea[2].question[2] = "图书管理系统的设计";
//----------------------------------------------------------------------------------------
		System.out.println("本程序作者：敲代码的猫 ||注：添加学生和教师人数不要超过10");
		System.out.println("确认？（Y/N）(选N也得确认，呵)");
		select = input.next();
//----------------------------------------------------------------------------------------
		do {
			r.clear();
			System.out.println("    毕业设计题目分配菜单选项：");
			System.out.println("      1. 当前指导教师信息显示");
			System.out.println("      2. 指导教师信息添加");
			System.out.println("      3. 学生信息添加");
			System.out.println("      4. 学生信息展示");
			System.out.println("      5. 毕业设计题目分配");
			System.out.println("      6. 学生更换题目");
			System.out.println("      7. 指导教师评判成绩");
			System.out.println("      8. 成绩显示");
			System.out.println("      9. 教师出题数目更改");
			System.out.println("      0. 退出\n\n");
			System.out.print("请输入数字键输入菜单选项：");
			n = input.nextInt();
			switch (n) {
			case 1:
				r.clear();
				System.out.println("指导教师信息显示:");//
				teaShow(at, tea, teaNum);
				System.out.println("\n按任意键返回上一级");
				balabala = input.next();
				break;
			case 2:
				r.clear();
				System.out.println("指导教师信息添加:\n\n");//
				System.out.println("请输入添加指导教师人数：");
				teaNum = input.nextInt();
				at += teaNum;
				teaAdd(teaNum, tea, at);
				System.out.println("\n按任意键返回上一级");
				balabala = input.next();
				break;
			case 3:
				r.clear();
				System.out.println("学生信息添加:");//
				System.out.println("请输入学生人数：");
				num = input.nextInt();
				stunum += num;
				stuAdd(num, stunum, tea, at, stu);
				System.out.println("\n按任意键返回上一级");
				balabala = input.next();
				break;
			case 4:
				r.clear();
				System.out.println("学生信息展示:");//
				System.out.println("\n当前学生信息：");
				stuShow(stunum, stu);
				System.out.println("\n按任意键返回上一级");
				balabala = input.next();
				break;
			case 5:
				r.clear();
				System.out.println("毕业设计题目分配:\n\n");//
				graShow(stu, tea, at);
				System.out.println("\n按任意键返回上一级");
				balabala = input.next();
				break;
			case 6:
				r.clear();
				System.out.println("学生更换设计题目:");//
				stuExchange(stunum, tea, at, stu);
				System.out.println("\n按任意键返回上一级");
				balabala = input.next();
				break;
			case 7:
				r.clear();
				System.out.println("指导教师评判成绩:\n\n");//
				juDge(stu, tea, at);
				System.out.println("\n按任意键返回上一级");
				balabala = input.next();
				break;
			case 8:
				r.clear();
				System.out.println("成绩显示:");//
				scoShow(stu, tea, at);
				System.out.println("\n按任意键返回上一级");
				balabala = input.next();
				break;
			case 9:
				r.clear();
				System.out.println("教师出题数目更改:");//
				System.out.println("！注：学生已选题的教师信息不能更改！");
				dexchange(tea, at);
				System.out.println("\n按任意键返回上一级");
				balabala = input.next();
				break;
			case 0:// 退出
				r.clear();
				break;
			default:
				r.clear();
				System.out.println("出现错误,按任意键返回");//
				balabala = input.next();
				break;
			}
		} while (n != 0);
//----------------------------------------------------------------------------------------	
		System.out.println("已退出");//
		/*
		 * 模板 教师信息初始 3个 教师信息添加 教师信息展示 学生信息录入 学生信息展示 学生选题（教师\题目） 毕业设计题目分配展示
		 */

		/*
		 * 第二次更改 1.填加学生更换题目功能 2.添加教师评分功能 3.添加成绩显示功能，并且成绩分为优良差，还要排序=_=
		 */

		/*
		 * 第三次更改 1.填写错误如何更改// 2.人数更改功能，即传说中的可扩展性// 3.一个教师出可多个题目
		 */

		/*
		 * 第四次 待改进bug 1.教师信息添加（在信息添加过一次后，第二次添加报错）//
		 */

		/*
		 * 第五次更改 1.教师出题已被选择的题目会显示被选择
		 * 
		 */
	}
}
```


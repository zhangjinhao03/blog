---
title: 【C++】面向对象
date: 2026-09-07 19:00:15
tags: [CPP]
categories: CPP
series: C++知识整理
top_img: /img/img12.png
cover: /img/img12.png
---

# C++面向对象



## 类与对象



## 构造函数 / 析构函数



## 拷贝构造 / 拷贝赋值



## 默认构造、移动构造、移动赋值



## 面向对象设计六大原则

### 1. 单一职责原则（SRP）

一个类应该只有一个引起它变化的原因。类的职责应尽量单一，避免将多个不相关的功能集中在同一个类中。

例如，文件读写、业务计算和日志记录应尽量拆分到不同的类中。

### 2. 开闭原则（OCP）

软件实体应当对扩展开放，对修改关闭。

新增功能时，优先通过继承、组合、策略等方式进行扩展，而不是频繁修改已有的稳定代码。

### 3. 里氏替换原则（LSP）

子类必须能够替换父类出现在程序中的位置，并且不破坏程序的正确性。子类重写父类行为时，应保持父类原有的语义和约束。

如果子类无法自然地替换父类，通常说明继承关系设计不合理。

### 4. 接口隔离原则（ISP）

不应该强迫一个类依赖它不需要的接口。接口应该保持精简，并按照职责拆分为多个小接口，避免使用庞大而臃肿的接口。

### 5. 依赖倒置原则（DIP）

高层模块不应该依赖低层模块，二者都应该依赖抽象；抽象不应该依赖细节，细节应该依赖抽象。

在 C++ 中，可以通过抽象基类、接口、模板和依赖注入等方式降低模块之间的耦合。

### 6. 迪米特法则（LoD）

迪米特法则也叫最少知识原则。一个对象应该尽量少了解其他对象的内部结构，只与直接的朋友进行通信。

应避免过度深入访问对象内部结构，例如：

```cpp
order->GetUser()->GetAccount()->GetBalance();
```

可以通过更高层的接口封装具体访问过程，减少对象之间的耦合。

---

## 封装







## 继承

- 对象布局



### 访问权限

访问权限：`public` / `protected` / `private`







### 虚基类表

虚基类表用于解决虚继承中的问题，不是普通虚函数多态的核心机制。

**菱形继承**

如下情况：

```cpp
  class A {
  public:
      int value;
  };

  class B : public A {
  };

  class C : public A {
  };

  class D : public B, public C {
  };
```

此时 D 中有两份 A：

```tex
   A
  / \
 B   C
  \ /
   D	
```

因此下面代码会产生二义性

```CPP
D d;
// d.value = 10; // 不知道使用 B::A 还是 C::A
```

### 虚继承

**解决方法：**使用**虚继承**

```cpp
  class A {
  public:
      int value;
  };

  class B : virtual public A {
  };

  class C : virtual public A {
  };

  class D : public B, public C {
  };
```

此时 D 中只保留一份共享的 A

不同编译器通常会通过额外的指针或表来定位虚基类 A。这类表通常称为：**虚基类表**

它记录的信息可以简单理解为：

```tex
当前对象中的虚基类在哪里
如何找到共享的 A 子对象
```

**虚基类表结构**

```
 B 子对象                                                             
  ┌──────────────┐                                                                      
  │ vbptr        │ ─────┐                                                      
  ├──────────────┤      │                                                 
  │ B 的数据      │      ↓                                                
  └──────────────┘   虚基类表                                        
                    ┌──────────────┐                                                       
                    │ A 的偏移量    │                                       
                    └──────────────┘
```

通过 B* 访问 A 时：

 B 对象地址 + 虚基类表中的偏移量 = A 对象地址

虚基类表可能保存：

```tex
虚基类 A 相对于当前子对象的偏移
其他运行时调整信息
```

例如：

```tex
B 的虚基类表：
A 相对于 B 的偏移 = 24

C 的虚基类表：                                                            
A 相对于 C 的偏移 = 12
```

实际数字由编译器根据对象布局决定。

**访问过程**

```CPP
  D d;
  B* b = &d;
  b->value = 10;

  访问过程可以抽象为：
  1. b 指向 D 中的 B 子对象
  2. 通过 B 内部的 vbptr 找到虚基类表
  3. 从虚基类表读取 A 的偏移量
  4. 根据偏移量找到共享的 A
  5. 访问 A::value
      
  通过 C* 访问时，也会使用 C 对应的虚基类表，但最终找到的是同一个 A：
      
  C* c = &d;                                                          
  b->value = 10;                                                             
  c->value = 20;                                                               
  // b->value 和 c->value 都是 20
```



## 多态

同一个父类指针，指向不同的子类对象，调用同一个函数时，表现出不同的行为。

**例如：**

动物都会叫：

狗叫：汪汪

猫叫：喵喵

它们都属于“动物”，但叫声不同。

**没有多态的写法**

```cpp
class Animal {
public:
	void speak() {
		std::cout << "动物叫\n";
	}
  };

class Dog : public Animal {
public:
	void speak() {
		std::cout << "汪汪\n";
	}
};

int main() {
    Dog dog;
    Animal* animal = &dog;
    animal->speak();
    return 0;
}
```

实际输出是：动物叫

原因是：

```cpp
Animal* animal = &dog;
```

虽然 animal 指向 Dog 对象，但 speak() 不是虚函数。通过父类指针调用时，编译器按照指针类型 Animal* 决定调用哪个函数。

### 1.使用 virtual 实现多态

```cpp
  #include <iostream>

  class Animal {
  public:
      virtual void speak() {
          std::cout << "动物叫\n";
      }
  };

  class Dog : public Animal {
  public:
      void speak() override {
          std::cout << "汪汪\n";
      }
  };

  class Cat : public Animal {
  public:
      void speak() override {
          std::cout << "喵喵\n";
      }
  };

  int main() {
      Dog dog;
      Cat cat;

      Animal* animal1 = &dog;
      Animal* animal2 = &cat;

      animal1->speak();
      animal2->speak();

      return 0;
  }
```

输出：

```tex
汪汪
喵喵
```

这里的关键是：

```cpp
virtual void speak()
```

它告诉 C++：

通过父类指针调用 speak() 时，不要只看指针类型，要根据实际指向的对象类型决定调用哪个函数。

```cpp
void speak() override
```

表示子类明确重写了父类的虚函数



虚函数会在运行时根据对象的真实类型调用对应函数

### 2.多态的三个必要条件

通常需要：

  1. 父类和子类存在继承关系
  2. 父类函数声明为 virtual
  3. 通过父类指针或父类引用调用函数

### 3.虚函数表

虚函数（Virtual Function）是通过一张虚函数表（Virtual Table）来实现的。简称为**vtable**。

对象中通常还会隐藏保存一个指向虚函数表的指针：**vptr**

可以简单理解为：

Animal 对象 → Animal 的虚函数表

Dog 对象    → Dog 的虚函数表

Cat 对象    → Cat 的虚函数表

**例：**

```cpp
Animal* animal = new Dog();
animal->speak();
```

执行过程可以理解为：

  1. animal 的静态类型是 Animal*
  2. animal 实际指向 Dog 对象
  3. 找到 Dog 对象对应的虚函数表
  4. 从虚函数表中找到 Dog::speak()
  5. 调用 Dog::speak()

 最终调用的是：

```cpp
Dog::speak()
```

而不是：

```cpp
Animal::speak()
```

**例：**

```cpp
  class Animal {
  public:
      virtual void speak() {
          std::cout << "Animal\n";
      }
  };

  class Dog : public Animal {
  public:
      void speak() override {
          std::cout << "Dog\n";
      }
  };
```

调用：

```cpp
  Animal* animal = new Dog();
  animal->speak();
```

animal 虽然是 Animal*，但实际指向 Dog 对象，所以调用 Dog::speak()。

内部可以简单理解为：

Dog 对象

```
  ┌──────────────┐
  │ vptr         │ ──> Dog 的虚函数表
  ├──────────────┤
  │ Dog 对象数据  │
  └──────────────┘
```

虚函数表中保存着虚函数地址：

Dog 的虚函数表：

speak → Dog::speak

**虚函数表创建时机**

**虚函数表**在构造函数调用后才建立

例如：

```cpp
  class Animal {
  public:
      virtual void speak();
  };

  class Dog : public Animal {
  public:
      void speak() override;
  };
```

编译器会为包含虚函数的类生成类似的表：

```tex
  Animal 的虚函数表：
  speak → Animal::speak

  Dog 的虚函数表：
  speak → Dog::speak
```

这些表通常是程序中的静态只读数据，程序运行时已经存在。它们不是每创建一个对象就重新创建一份。

**虚函数指针什么时候创建:**

vptr 通常是对象内部隐藏的一个指针。

创建对象时，构造函数会把对象中的 vptr 设置为对应类的虚函数表地址。

```cpp
Dog dog;
```

创建 dog 对象时，可以简单理解为：

1. 先构造 Animal 部分
  2. vptr 暂时指向 Animal 的虚函数表
  3. 再构造 Dog 部分
  4. vptr 修改为指向 Dog 的虚函数表



### 4.虚析构函数

多态场景下，父类析构函数通常应该声明为虚函数。

将可能会被继承的**父类的析构函数**设置为**虚函数**，可以保证当我们new一个子类，然后使用基类指针指向该子类对象，释放基类指针时可以释放掉**子类的空间**，防止内存泄漏。

如果基类的析构函数不是虚函数，在特定情况下会导致派生类无法被析构。

C++默认的析构函数不是虚函数是因为虚函数需要额外的**虚函数表**和**虚表指针**，占用**额外的内存**。

### 5.纯虚函数和抽象类

有时父类只想规定接口，不想提供具体实现。

例如所有动物都应该会叫，但“动物”本身并没有确定的叫声：

```cpp
  class Animal {
  public:
      virtual void speak() = 0;
  };
```

这里的：

```cpp
= 0
```

叫做纯虚函数。

包含纯虚函数的类叫做：抽象类

抽象类不能直接创建对象：

```cpp
Animal animal; // 错误
```

但可以使用父类指针或引用：

```cpp
Animal* animal;
```

子类必须重写纯虚函数：

```cpp
  class Dog : public Animal {
  public:
      void speak() override {
          std::cout << "汪汪\n";
      }
  };

```













---

### TODO

`override`、`final`

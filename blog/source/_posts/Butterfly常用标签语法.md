---
title: Butterfly常用标签语法
date: 2026-08-10 00:00:00
tags:
  - Butterfly
  - Hexo
categories: Docs
top_img: /img/830179.jpg
cover: /img/830179.jpg
---

# Butterfly 常用标签语法

## 1. Label 高亮标签

用于显示彩色文字块。

```md
{% label 例子 purple %}
```

{% label 例子 purple %}

可用颜色：

- `blue`
- `pink`
- `red`
- `purple`
- `orange`
- `green`

示例：

```md
{% label 例子 purple %}
{% label 提示 blue %}
{% label 警告 red %}
```

{% label 例子 purple %}
{% label 提示 blue %}
{% label 警告 red %}

## 2. Note 提示块

用于展示提示、警告、信息块。

### 基本写法

```md
{% note info %}
这里是提示内容
{% endnote %}
```

{% note info %}
这里是提示内容
{% endnote %}

### 完整写法

```md
{% note [color] [icon] [style] %}
Any content (support inline tags too.)
{% endnote %}
```

{% note [color] [icon] [style] %}
Any content (support inline tags too.)
{% endnote %}

### 常见类型

- `default`
- `primary`
- `success`
- `info`
- `warning`
- `danger`

### 示例

```md
{% note warning %}
这里是警告内容
{% endnote %}
```

{% note warning %}
这里是警告内容
{% endnote %}

## 3. 按钮

用于生成可点击按钮。

```md
{% btn https://github.com,github %}
```

{% btn https://github.com,github %}

示例：

```md
{% btn https://github.com,github %}
{% btn https://butterfly.js.org,Butterfly %}
```

{% btn https://github.com,github %}
{% btn https://butterfly.js.org,Butterfly %}

## 4. Tab 标签页

用于分组展示内容。

```md
{% tabs 示例 %}
<!-- tab 第一项 -->
内容1
<!-- endtab -->

<!-- tab 第二项 -->
内容2
<!-- endtab -->
{% endtabs %}
```

{% tabs 示例 %}
<!-- tab 第一项 -->
内容1
<!-- endtab -->

<!-- tab 第二项 -->
内容2
<!-- endtab -->
{% endtabs %}

## 5. 折叠块

用于隐藏和展开内容。

```md
{% hideToggle 点击展开 %}
这里是折叠内容
{% endhideToggle %}
```

{% hideToggle 点击展开 %}
这里是折叠内容
{% endhideToggle %}

## 6. 引用块

普通 Markdown 也可以直接写：

```md
> 这是一段引用内容
```

> 这是一段引用内容

## 7. 文章中的图片

### 文章资源文件夹写法

当开启：

```yml
post_asset_folder: true
```

时，可以这样写：

```md
![图片名](图片.jpg)
```

图片放在同名文件夹里，例如：

```text
source/_posts/文章名.md
source/_posts/文章名/图片.jpg
```

## 8. 目录编号

如果不想让右侧目录自动编号，在主题配置中设置：

```yml
toc:
  number: false
```

## 9. 常用说明

- `label` 适合做短标识
- `note` 适合做提示框
- `btn` 适合做跳转按钮
- `tabs` 适合分组内容
- `hideToggle` 适合折叠长内容

## 10. 常用 Icon 对照表

| 场景 | 图标类名 | 说明 |
|---|---|---|
| 提示 | `fas fa-info-circle` | 信息提示 |
| 成功 | `fas fa-check-circle` | 成功、完成 |
| 警告 | `fas fa-exclamation-triangle` | 警告 |
| 错误 | `fas fa-times-circle` | 错误、失败 |
| 灯泡 | `fas fa-lightbulb` | 灵感、建议 |
| 书本 | `fas fa-book` | 文档、教程 |
| 星标 | `fas fa-star` | 推荐、重点 |
| 链接 | `fas fa-link` | 外部链接 |
| 下载 | `fas fa-download` | 下载 |
| 代码 | `fas fa-code` | 代码相关 |
| 文件 | `fas fa-file-alt` | 文件、文章 |
| 文件夹 | `fas fa-folder-open` | 分类、目录 |
| 搜索 | `fas fa-search` | 搜索 |
| 首页 | `fas fa-home` | 首页 |
| 归档 | `fas fa-archive` | 归档 |
| 标签 | `fas fa-tags` | 标签 |
| 日历 | `fas fa-calendar-alt` | 日期 |
| 用户 | `fas fa-user` | 个人信息 |
| GitHub | `fab fa-github` | GitHub 链接 |
| 邮件 | `fas fa-envelope` | 邮箱 |
| 微信 | `fab fa-weixin` | 微信 |
| 微博 | `fab fa-weibo` | 微博 |

## 11. 说明

- `fas` 表示实心图标
- `fab` 表示品牌图标
- 图标名要写完整，比如 `fas fa-book`

{% note purple 'fas fa-lightbulb' flat %}
灯泡
{% endnote %}

{% note purple 'fas fa-magic' %}
  这里是魔法棒提示块
  {% endnote %}

{% note purple 'fas fa-wand-magic-sparkles' %}
  这里是魔法棒提示块2
  {% endnote %}

{% note pink 'fas fa-bell' %}
  这里是铃铛2
  {% endnote %}

参考文档：

https://butterfly.js.org/posts/ceeb73f/

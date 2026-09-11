---
title: 【GIT】Git基础
date: 2024-10-12 16:19:05
tags: [Git]
categories: GIT
top_img: /img/img6.jpg
cover: /img/img6.jpg
---

# Git Help

> 本文档集合了各种软件管理工具包括repo、git、github、gerrit的基础知识和使用指南，帮助刚入职的软件工程师快速上手这些工具的使用。

## 1.Git工作流程

![流程图](流程图.jpg)

注：

Workspace：工作区

Index / Stage ：暂存区

Repository：仓库区

Remote：远程仓库

### 工作区

程序员进行开发改动的地方，是你当前看到的，也是最新的。平常我们开发就是拷贝远程仓库中的一个分支，基于该分支进行开发。在开发过程中就是对工作区的操作。

### 暂存区

.git目录下的index文件, 暂存区会记录添加文件的相关信息(文件名、大小、timestamp...)，不保存文件实体, 通过id指向每个文件实体。可以使用`git status`查看暂存区的状态。暂存区标记了你当前工作区中，哪些内容是被git管理的。当你完成某个需求或功能后需要提交到远程仓库，那么第一步就是通过`git add`先提交到暂存区，被git管理。

### 本地仓库

保存了对象被提交过的各个版本，比起工作区和暂存区的内容，它要更旧一些。`git commit`后同步index的目录树到本地仓库，方便从下一步通过`git push`同步本地仓库与远程仓库的同步。

### 远程仓库

远程仓库的内容可能被分布在多个地点的处于协作关系的本地仓库修改，因此它可能与本地仓库同步，也可能不同步，但是它的内容是最旧的。

### 小结

- 任何对象都是在工作区中诞生和被修改；

- 任何修改都是从进入index区才开始被版本控制；

- 只有把修改提交到本地仓库，该修改才能在仓库中留下痕迹；

- 与协作者分享本地的修改，可以把它们push到远程仓库来共享。

  下图直观的阐述了四个区域之间的关系。

![工作流程](工作流程.jpg)

## 2.Git环境配置

### github

首先需要有一个[github](https://github.com/)账户，如果没有需要先注册。

注册后回到git bash中输入如下命令

```bash
git config --global user.name "yourname"
git config --global user.email "youremail"
```

yourname是你注册时的用户名；

youremail是你注册时的电子邮箱；

可以执行以下两条命令，检查是否输入正确

```bash
git config user.name
git config user.email
```

然后创建SSH

```bash
ssh-keygen -t rsa -C "youremail" #youremail是你注册时的电子邮箱；
```

这个时候已经生成了.ssh的文件夹，在你的电脑中找到这个文件夹。

```bash
~
$ cd ~/.ssh

~/.ssh 
$ ls

~/.ssh
$ cat id_rsa.pub
```

或直接在文件夹中找到id_rsa.pub打开复制其中的内容。

ssh是一个秘钥，其中，`id_rsa`是你这台电脑的私人秘钥，不能给别人看。`id_rsa.pub`是公共秘钥。把这个公钥放在GitHub上，这样当你链接GitHub自己的账户时，它就会根据公钥匹配你的私钥，当能够相互匹配时，才能够顺利的通过git上传你的文件到GitHub上。

在github.com界面点击右上角的个人头像会弹出菜单，

![image-20241014200929001](image-20241014200929001.png)

点击setting，找到SSH keys的设置选项，点击`New SSH key`把你的`id_rsa.pub`里面的信息复制进去。

![image-20241014195518574](image-20241014195518574.png)

密钥标题什么都可以，完成后点击 `Add SSH key`。

执行如下命令查看是否成功：

```bash
ssh -T git@github.com #关联验证
```

出现如下信息时说明配置成功！

```bash
Hi yourname! You've successfully authenticated, but GitHub does not provide shell access.
```

### gerrit

在本地生成公私钥对. 然后将公钥传到Gerrit的服务器上

1.在本地命令中执行

```bash
ssh-keygen -t rsa -b 4096
```

`~/.ssh/`目录下多了几个文件

其中`~/.ssh/id_rsa`就是私钥，`~/.ssh/id_rsa.pub`就是公钥内容

2.在命令行执行

```bash
cat ~/.ssh/id_rsa.pub
```

将其内容复制. 粘贴到Gerrit的配置界面

![image-20241015111720466](image-20241015111720466.png)

![image-20241014200311500](image-20241014200311500.png)

**配置本地信息**

配置你的名字与邮箱, 此处xxxxx是你的邮箱前缀

```bash
git config --global user.email xxxxx@xiaomi.com
```

```bash
git config --global user.name xxxxx
```

## 3.常用Git命令

```bash
#创建版本库
git clone <url>       #克隆远程版本库
git init              #初始化本地版本库

#修改和提交
git status             #查看状态
git diff               #查看变更内容
git add .              #跟踪所有改动过的文件
git add <file>         #跟踪指定文件
git mv <old> <new>     #文件改名
git rm <file>          #删除文件
git rm --cached <file> #停止跟踪文件但不删除
git commit -m "commit message"
                       #提交所有更新过的文件
git commit --amend     #修改最后一次提交
git commit -sa         #发起提交并追加签名

#查看提交历史
git log                #查看提交历史
git log -p <file>      #查看指定文件的提交历史
git blame <file>       #以列表方式查看指定文件的提交历史

#撤销
git reset --hard HEAD  #撤销工作目录中所有未提交文件的修改内容
git checkout HEAD <file>
                       #撤销指定的未提交文件的修改内容
git revert <commit>    #撤销指定的提交

#分支与标签
git branch             #显示所有本地分支
git checkout <branch/tag>
                       #切换到指定分支或标签
git branch <new-branch>#创建新分支
git branch -d <branch> #删除本地分支
git branch -D <branch> #强制删除本地分支
git branch -r          #查看远程所有分支
git tag                #列出所有本地标签
git tag <tagname>      #基于最新提交创建标签
git tag -d <tagname>   #删除标签

#合并与衍合
git merge <branch>     #合并指定分支到当前分支
git rebase <branch>    #衍合指定分支到当前分支

#远程操作
git remote -v          #查看远程版本库信息
git remote show <remote>
                       #查看指定远程版本库信息
git remote add <remote> <url>
                       #添加远程版本库
git fetch <remote>     #从远程库获取代码
git pull <remote> <branch>
                       #下载代码及快速合并
git push <remote> <branch>
git push <remote> :<branch/tag-name>
                       #删除远程分支或标签
git push --tags        #上传所有标签
```

### HEAD

HEAD，它始终指向当前所处分支的最新的提交点。你所处的分支变化了，或者产生了新的提交点，HEAD就会跟着改变。

![HEAD](HEAD.jpg)

### branch

涉及到协作，自然会涉及到分支，关于分支，大概有展示分支，切换分支，创建分支，删除分支这四种操作。

**创建分支**

```bash
git branch <branch-name>                    #新建一个分支，但依然停留在当前分支
git branch --track <branch><remote-branch>  #新建一个分支，与指定的远程分支建立追踪关系
```

**展示分支**

```bash
git branch                                  #列出所有本地分支
git branch -r                               #列出所有远程分支
git branch -a                               #列出所有本地分支和远程分支
```

**切换分支**

```bash
git checkout -b <branch-name>               #新建一个分支，并切换到该分支
git checkout <branch-name>                  #切换到指定分支，并更新工作区
```

**删除分支**

```bash
git branch -d <branch-name>                 #删除分支
git push origin --delete <branch-name>      #删除远程分支
```

### add

![123456](123456.jpg)

add相关命令是实现将工作区修改的内容提交到暂存区，交由git管理。

```bash
git add .          #添加当前目录的所有文件到暂存区
git add <dir>      #添加指定目录到暂存区
git add <file>     #添加指定文件到暂存区
```

### commit

![123456](123456.jpg)

commit实现将暂存区的内容提交到本地仓库，并使当前分支的HEAD向后移动一个提交点

```bash
git commit -m <message> #提交暂存区到本地仓库，message代表说明信息
git commit <file> -m <message> #提交暂存区的指定文件到本地仓库
git commit --amend <message> #使用一次新的commit，替代上一次提交
```

### push

![push.](push..jpg)

上传本地仓库分支到远程仓库分支，实现同步。

```bash
git push <remote><branch> #上传本地指定分支到远程仓库
git push <remote> --force #强行推送当前分支到远程仓库
git push <remote> --all   #推送所有分支到远程仓库
```

### 实践操作：提交一次代码

首先下载代码到本地

```bash
git clone <url>  #url为远程仓库的代码链接
```

在本地**工作区**对代码进行修改

执行

```bash
git status#查看状态
```

可以发现我们当前没有在任何一个开发分支上，因此需要创建一个开发分支

```bash
git branch local #创建了一个名为local的本地分支
```

再次执行`git status`会显示我们当前位于local分支，并且修改了哪些文件

执行命令

```bash
git branch
```

会列出所有的本地分支，包括我们刚才创建的local也在其中

将修改的全部代码提交到暂存区，执行

```bash
git add . 
```

将暂存区内容提交到本地仓库，执行

```bash
git commit -m "第一次提交"
```

字符串内容可自行更改，此时再执行`git status`会发现工作区没有更改内容了，干净的工作区。

在提交后想查看修改的详细内容可以使用命令

```bash
git diff
```

最后将我们的本地仓库提交到远程仓库同步我们修改的代码，执行

```bash
git push origin local
```

到此完成了一次完整的提交过程。

当我们发现上一次的提交有问题需要覆盖其内容，只需在修改代码后依次执行：

```bash
git add .
git commit --amend #覆盖上一次提交
```

这样会避免我们同一修改产生过多提交节点。

### merge

merge命令把不同的分支合并起来

![23456](23456.jpg)

如上图，在实际开发过程中，我们可能从master分支中切出一个分支，然后进行开发完成需求，中间经过R3，R4，R5的commit记录，最后开发完成需要合入到master中，这便用到了merge。

```bash
git fetch <remote> #merge之前先拉一下远程仓库最新代码
git merge <branch> #合并指定分支到当前分支
```

一般在merge之后，会出现conflict，需要针对冲突情况，手动解除冲突。主要是因为两个用户修改了同一文件的同一块区域。

### rebase

rebase又称为衍合，是合并的另外一种选择。

如下图：

![rebaseShow](rebaseShow.jpg)

在开始阶段我们处于new分支上，执行命令：

```bash
git rebase local
```

在new分支上的新commit都在master分支上重新上演一遍，最后checkout切换回到new分支。合并前后所处的分支并没有改变这一点和merge是一样的。`通俗解释就是new分支想在dev的肩膀上继续下去`rebase也需要手动解决冲突。

### rebase和merge的区别

现在我们有这样的两个分支,test和master，提交如下：      

![origin](origin.jpg)

在master执行`git merge test`,然后会得到如下结果：   

![merge](merge.jpg)

在master执行`git rebase test`，然后得到如下结果：

![rebase](rebase.jpg)

可以看到，merge操作会生成一个新的节点，之前的提交分开显示。而rebase操作不会生成新的节点，是将两个分支融合成一个线性的提交。如果你想要一个干净的，没有merge commit的线性历史树，那么你应该选择git rebase如果你想保留完整的历史记录，并且想要避免重写commit history的风险，你应该选择使用git merge

### reset

reset命令把当前分支指向另一个位置，并且相应的变动工作区和暂存区。

```bash
git reset --soft <commit>  #只改变提交点，暂存区和工作目录的内容都不变
git reset --mixed <commit> #改变提交点，同时改变暂存区的内容
git reset --hard <commit>  #暂存区、工作区的内容都会被修改到与提交点完全一致的状态
git reset --hard HEAD      #让工作区回到上次提交时的状态
```

### revert

git revert用一个新提交来消除一个历史提交所做的任何修改。

```bash
git commit -am "update readme"
git revert 15df9b6
```

![revert](revert.jpg)

### reset和revert的区别

- git revert是用一次新的commit来回滚之前的commit，git reset是直接删除指定的commit。
- 在回滚这一操作上看，效果差不多。但是在日后继续merge以前的老版本时有区别。因为git revert是用一次逆向的commit“中和”之前的提交，因此日后合并老的branch时，导致这部分改变不会再次出现，减少冲突。但是git reset是之前把某些commit在某个branch上删除，因而和老的branch再次merge时，这些被回滚的commit应该还会被引入，产生很多冲突。
- git reset 是把HEAD向后移动了一下，而git revert是HEAD继续前进，只是新的commit的内容和要revert的内容正好相反，能够抵消要被revert的内容。

### 其他命令

```bash
git status               #显示有变更的文件
git log                  #显示当前分支的版本历史
git diff                 #显示暂存区和工作区的差异
git diff HEAD            #显示工作区与当前分支最新commit之间的差异
git cherry-pick <commit> #选择一个commit，合并当前分支
```

## 4.repo

repo是Android为了方便管理多个git库而开发的Python脚本。repo的出现，并非为了取代git，而是为了让Android开发者更为有效的利用git。

### 安装repo

Android源码包含数百个git库，仅仅是下载这么多git库就是一项繁重的任务，所以在下载源码时，Android就引入了repo。 Android官方推荐下载repo的方法是通过**Linux curl**命令，下载完后，为repo脚本添加可执行权限。

安装repo(ubuntu):

```bash
#准备环境变量
mkdir ~/bin
PATH=~/bin:$PATH

#将repo下载到你的环境变量目录下（例如~\bin）
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo

#修改执行权限
chmod a+x ~/bin/repo

#建立工作目录
mkdir miui
cd miui

#设置邮箱和用户名
git config --global user.email username@xiaomi.com
git config --global user.name username
```

repo对git命令进行了封装，提供了一套repo的命令集(包括init, sync等)，所有repo管理的自动化实现也都包含在这个git库中。 在第一次初始化的时候，repo会从远程把这个git库下载到本地。

### 仓库目录和工作目录

仓库目录保存的是历史信息和修改记录，工作目录保存的是当前版本的信息。一般来说，一个项目的Git仓库目录（默认为.git目录）是位于工作目录下面的，但是Git支持将一个项目的Git仓库目录和工作目录分开来存放。 对于repo管理而言，既有分开存放，也有位于工作目录存放的:

- **manifests**： 仓库目录有两份拷贝，一份位于工作目录(.repo/manifests)的.git目录下，另一份独立存放于.repo/manifests.git
- **repo**：仓库目录位于工作目录(.repo/repo)的.git目录下
- **project**：所有被管理git库的仓库目录都是分开存放的，位于.repo/projects目录下。同时，也会保留工作目录的.git，但里面所有的文件都是到.repo的链接。这样，即做到了分开存放，也兼容了在工作目录下的所有git命令。

既然.repo目录下保存了项目的所有信息，所有要拷贝一个项目时，只是需要拷贝这个目录就可以了。repo支持从本地已有的.repo中恢复原有的项目。

### 常用命令

#### repo init

```bash
repo init -u url [options]
```

初始化要下载的代码

在当前目录中安装 Repo。这样会创建一个 `.repo/` 目录，其中包含存放 Repo 源代码和标准 Android 清单文件的 Git 代码库。

`-u`：指定从中检索清单代码库的网址。

`-m`：选择代码库中的清单文件。如果未选择清单名称，则默认为 `default.xml`。

`-b`：指定修订版本，即特定的 manifest-branch。

`-g all`：如果加上-g all 参数，则会下载小米的modem源码，默认不下载modem源码

例如：

```bash
repo init -u ssh://{yourname}@git.mioffice.cn:29418/platform/manifest.git -b dev -m bsp-grus-q.xml --repo-url=ssh://{yourname}@git.mioffice.cn:29418/tools/repo.git --no-repo-verify # 如果需要下载BP代码，在init的时候添加 -g all 参数，如下: $ repo init -g all -u ssh://{yourname}@git.mioffice.cn:29418/platform/manifest.git -b dev -m bsp-grus-q.xml --repo-url=ssh://{yourname}@git.mioffice.cn:29418/tools/repo.git --no-repo-verify 
```

#### repo sync

```bash
repo sync [project-list]
```

下载新的更改并更新本地环境中的工作文件，基本上可以在所有 Git 代码库中完成 `git fetch`。如果在未使用任何参数的情况下运行 `repo sync`，则该命令会同步所有项目的文件。

运行 `repo sync` 后，将出现以下情况：

- 如果目标项目从未同步过，则 `repo sync` 相当于 `git clone`。远程代码库中的所有分支都会复制到本地项目目录中。
- 如果目标项目以前同步过，则 `repo sync` 相当于：

```bash
$ git remote update
$ git rebase origin/branch
```

 其中 `branch` 是本地项目目录中当前已检出的分支。如果本地分支没有在跟踪远程代码库中的分支，则项目不会发生任何同步。

- 如果 Git rebase 操作导致合并冲突，请使用常规 Git 命令（例如 `git rebase --continue`）来解决冲突。

成功运行 `repo sync` 后，指定项目中的代码即处于最新状态，并已与远程代码库中的代码同步。

`-c`：仅获取服务器中的当前清单分支。

`-d`：将指定项目切换回清单修订版本。如果项目当前属于某个主题分支，但临时需要清单修订版本，则此选项会有所帮助。

`-f`：即使某个项目同步失败，也继续同步其他项目。

`-jthreadcount`：将同步操作拆分成多个线程，以更快地完成。切勿为其他任务预留 CPU，这会使计算机超负荷运行。如需查看可用 CPU 的数量，请先运行：`nproc --all`

`-q`：通过抑制状态消息来确保运行过程没有干扰。

`-s`：同步到当前清单中的 manifest-server 元素指定的一个已知良好 build。

#### repo upload

```bash
repo upload [project-list]
```

对于指定的项目，Repo 会将本地分支与最后一次 repo sync 时更新的远程分支进行比较。Repo 会提示您选择一个或多个尚未上传以供审核的分支。

当 Gerrit 通过其服务器接收对象数据时，它会将每项提交转变成一项更改，以便审核者可以针对特定提交给出意见。如需将几项“检查点”提交合并为一项提交，请运行 `git rebase -i` 然后再运行 upload。

如果在未使用任何参数的情况下运行 `repo upload`，则该命令会在所有项目中搜索要上传的更改。

如果您只想上传当前已检出的 Git 分支，请使用标记 `--current-branch`（或简称 `--cbr`）。

**向Gerrit提交**

**比git push 更优在以下方面 ：**

1. 肯定不会提交错仓库
2. manifest对的情况下，不会提交错分支
3. 避免拼写错误
4. 因gerrit现阶段配置的复杂，适合不太理解的小白用户

`repo upload .`：点不能省略，请配合`repo start .` 使用，当前仓库提交change到gerrit上

`repo upload --cbr .`：当前仓库有多个分支时，仅提交当前指向的分支的change到gerrit上，其他分支忽略

`repo upload -d .`：提交一个draft到gerrit上，draft的概念请参考 [新版Gerrit使用说明](https://wiki.n.miui.com/pages/viewpage.action?pageId=21226458) 中的 [提交一个草稿draft](https://wiki.n.miui.com/pages/viewpage.action?pageId=21226458#id-新版Gerrit使用说明-提交一个草稿draft) 部分

`repo upload -t .`：提交change的同时，会将你的本地branch name作为该change的topic

**补充一种情况，使用git命令创建分支使用repo upload**

 创建分支时使用git checkout -b 新分支名 远程分支名 例如：

```bash
work@c4-miui-miuigit-server01:~$ git branch -a
* (no branch)
remotes/m/alpha -> miui/v10-p-begonia-cmcc
remotes/m/dev -> miui/miui-p-tucana-cmcc
remotes/m/stable -> miui/v10-p-begonia-mexico
remotes/miui/f2-grus-p-operator
remotes/miui/miui-p-ginkgo-claro
remotes/miui/miui-p-olive-claro
remotes/miui/miui-p-tucana-cmcc
remotes/miui/miui-p-tucana-stable
remotes/miui/miui-q-cepheus-stable
remotes/miui/v10-o-cactus-mexico

work@c4-miui-miuigit-bak01:~/hdd1/scm-use/teststable/frameworks/base$ git checkout -b mybranch remotes/miui/miui-p-tucana-stable
#这样创建的分支就可以使用repo upload
```

通常上传代码使用命令

```bash
repo upload . --no-verify
```

#### repo status

查看所有仓库的git status

适用于修改多个仓库后，统一查看当前状况

#### repo start dev

创建一个分支名为dev

## 5.Gerrit

### 上传代码

假设你已经下好了完整的代码,我们随便找一个小仓库来做个实验, 比如`platform/frameworks/ex`, 提交一个change

1.`cd frameworks/ex`

2.随便新建一个文件, 比如`echo 1 > 1.txt`

3.此时运行`git add`将文件添加到索引区. 然后运行`git commit -s`生成一笔提交. 注意提交的格式必须是如下格式, 否则提交到Gerrit上去之后, 会被机器人自动`Code Review -2`, 无法合入代码

```sql
标题:副标题

JIRA-ID

描述

Change-Id: xxxxxxxxxxxxx
Signed-off-by: xxxxx <xxxxxxx>
```

##### Change Number

这个数字通常是在你push完了之后, gerrit自动生成的全局唯一ID.比如`https://gerrit.pt.mioffice.cn/c/2341170`这个url里的`2341170`就是这个change的`change Number`.

##### Change-Id

`Change-Id`是Gerrit用来识别review层面的ID，[官方文档](https://gerrit-review.googlesource.com/Documentation/user-changeid.html)里会有详细解释

本质上来说, 他是一串随机数, 如果你自己不指定, 那么`commit-msg hook`会自动帮你添加. 它通常位于这个仓库的`.git/hooks/commit-msg`里. 这就是为什么我们前一篇文章下载代码的时候, 复制命令需要复制`Clone with commit msg-hook`的内容.

和`change Number`作为服务器上的唯一ID不同, `Change-Id`是内嵌在`commit-message`里的, 他对于`git`来说只是单纯的一个字符串而已. 但是对于Gerrit来说, 他标识了同一组Review的change. 换句话说, 在同一个`Change Number`里, 不同`patchSet`的change, 一定是共享同一个`Change-Id`的. 这在你上传了一个change之后, 发现他是有问题的需要修改重新上传非常有用. 你会发现当你再次上传, 你不需要告诉Gerrit你想覆盖哪个change, 他会通过`Change-Id`自动识别

注意`Change-Id`并不一定是唯一的. 他只在同一个仓库的同一个分支下是唯一的.

##### Signed-Off-By

`Signed-off-by`这一行是`git commit`的`-s`命令自动添加的. 其实就是为了追踪真正的提交者. 因为很有可能一笔change的作者并不是你, 比如你从AOSP上下载了一些代码, 并且合入到我们的Gerrit中. 这个时候`Signed-off-by`这一行就可以记录下来作者和上传者并不是同一个人

##### 上传change

Gerrit本身的文档对于上传change的高级用法有特别详尽的描述, 大家可以[参考](https://gerrit.pt.mioffice.cn/Documentation/user-upload.html).

我们在这里只介绍最基本的上传办法

##### 使用git push

###### 基本格式

`git push`的基本格式为:

```bash
git push ssh://用户名``@域名:端口/仓库 本地指针:refs/for/服务器指针
```

举个例子, 要把你当前`platform/frameworks/base`的`HEAD` push到服务器的`master-t-qcom`分支上的时候, 你的命令应该是

```bash
git push ssh://用户名``@gerrit.pt.mioffice.cn:29418``/platform/frameworks/base`` HEAD:refs/for/master-t-qcom
```

如果提交成功，会有 "SUCCESS" 提示，并附带change link,如下图：

![image-20241015111258229](image-20241015111258229.png)

###### 快捷方式:

如果你是用`repo`下载的代码, 那我们为`git push`提供了快捷方式

```
git push ``origin`` HEAD:refs/for/master-t-qcom
```

这里的`origin`实际上是我们设置在`remote`里的服务器别名, 可以用`git remote -v`查看

**说明**：

- git.mioffice.cn 是用于研发下载代码的从服务器域名
- gerrit.pt.mioffice.cn 是用于研发提交代码的主服务器域名

##### 使用repo upload

​       使用如下命令也可以上传代码, 命令里的`.`代指当前目录

```bash
repo start localTmp
#在localTmp分支上提交东西
repo upload .
```

这个命令的意思是, 在本地创建一个`localTmp`分支, 然后把`localTmp`分支上的内容推送到`manifest`里的指定分支(也就是记录在`.repo/manifest.xml`里面的分支).

假设你当前`manifest`里这个仓库的默认分支是`master-t-qcom`. 那么实际上这两个命令相当于执行了

```perl
git checkout -b localTmp master-t-qcom
#上面这句是repo start localTmp命令实际执行的
git push ssh://chengyang@gerrit.pt.mioffice.cn:29418/platform/frameworks/ex refs/heads/localTmp:refs/for/master-t-qcom
#这一句是repo upload . 最后实际执行的
```

如果你想知道当前仓库的默认分支, 其实只需要`repo manifest |grep <仓库名>`

这里有一点大家可能会注意到, 你自己用`git push`基本本地指针都是`HEAD`, 也就是你当前checkout的点.

但是`repo upload .`永远push的是你当初`repo start`的分支, 在这个例子里是`refs/heads/localTmp`. 一定有小伙伴曾经遇到过明明已经`commit`了change, 结果`repo upload`却说`no branches ready for upload`.这就是因为你没有把change提交到你之前`repo start`的分支上

同样, 提交成功后有 "SUCCESS" 提示，并附带change link：

![image-20241015111531042](image-20241015111531042.png)



### 下载代码

1.需初始化环境，参考2.Git环境配置中的gerrit章节

2.复制[bbm](https://bbm.pt.miui.com/releases)上的`复制全部`按钮初始化下载

![image-20241015111832531](image-20241015111832531.png)

3.使用`repo sync -cd --no-tags`命令下载代码. 理想情况下, 下载代码应该在50分钟左右完成. 如果你下载代码十分慢且痛苦. [可以参考这篇文档](https://xiaomi.f.mioffice.cn/docs/dock4tc9d5fk4bb2dFnchlppZVg#)

## 6.Git常见问题

### 冲突问题

首先介绍一下代码冲突出现的原因：

情况一：开始把我们需要修改的代码拉下来，在本地修改代码的过程中，有人合入了代码，而且修改的代码与合入代码的位置十分相近，在git push 上去后，在gerrit上就会出现代码冲突的提示。而且，如果几个提交有依赖关系，只要底下的提交出现冲突，上面的提交全部都会发生代码冲突，即使它们其实并不存在冲突，这时将上面的提交每个都rebase一下就可以将冲突提示给消除掉了。



情况二：基于一个比较旧的代码版本进行修改，并进行了提交，但是有新的合入把旧的给修改了，比如删除了一行，这种情况也会发生代码冲突。

处理过程：git push——>git status .——>git diff，然后就可能会出现：

![image-20241015140854352](image-20241015140854352.png)

因为基准的代码有一行删除掉了，并留下了一个空行，所以这里多处一行，那为什么下面一部分不会出现被删除的东西呢？因为之前参考的代码已经修改并合入了(我的提交只是记录修改了哪个部分，没有修改的不会记录)，所以就无法查到被删除的是什么内容，于是没有显示内容。

具体到我碰到的代码冲突，我在一个节点上做了一系列的提交，这些提交有很多是修改了同一个文件，但是合入分支总有一个先后之分，一部分合入了，后面的部分就和分支里的代码冲突了。

**在gerrit界面上进行修改**

在冲突的提交界面上点击rebase按钮，就会在界面文件里显示如上形式的代码冲突提示，直接在上面修改并保存就可以了

第二种是点击右上角的cherry pick，cherry pick到自己的分支，也会出现和上面那种方法相同的效果。

#### 手动解决冲突

打开发生冲突的文件，你会看到类似以下内容：

```bash
<<<<<<< HEAD
这是当前分支的内容
=======
这是合并分支的内容
>>>>>>> branch-name
```

上面的示例展示了冲突标记 `<<<<<<< HEAD`, `=======`, `>>>>>>> branch-name`。它们分别代表了当前分支（HEAD）、合并进来的分支和分支名称。

手动解决冲突步骤

- 仔细阅读被标记的不同分支的内容，并决定应该保留哪些修改，或是进行其他修改以解决冲突。
- 删除冲突标记 `<<<<<<<`, `=======`, `>>>>>>>` 之间的内容，并确保最终文件内容正确、合理。
- 将需要的修改从两个分支的内容中合并到一个统一、正确的版本中，以解决冲突。
- 使用 `git add 文件名` 命令将已解决冲突的文件标记为已暂存状态。此操作告知 Git 已经处理了这些文件的合并冲突。如果有多个文件发生冲突，可以一次性使用 `git add .` 命令将所有解决后的文件标记为已解决状态。
- 执行 `git commit` 命令，Git 会为解决冲突创建一个新的合并提交。在提交信息中，建议添加描述性信息，说明这次提交解决了哪些冲突、修复了什么问题或者包含了什么功能性修改。
- 验证合并后的代码，确保没有新的功能问题、不引入新的错误或异常。可以进行一些测试，运行应用程序，或者请同事审查代码修改，以确保所有功能和逻辑都按预期工作。

![image-20241015142435004](image-20241015142435004.png)

#### remote unpack failed: error Missing tree xxx

![image-20241015112148709](image-20241015112148709.png)

解决方法:

```bash
step 1: git remote -v
miui    ssh://zhangjinhao3@git.mioffice.cn:29418/miui/frameworks/interface (fetch)
miui    ssh://zhangjinhao3@gerrit.pt.mioffice.cn:29418//miui/frameworks/interface (push)
step 2: git push ssh://dingyingzhi@gerrit.pt.mioffice.cn:29418//platform/vendor/qcom-proprietary/mm-camerasdk HEAD:refs/for/master-u-qcom --no-thin
# 注：HEAD:refs/for/要提交的远程分支
使用命令:
git branch -r#查看
m/master-v -> miui/master-v 
master-v即为要提交的远程分支，因此命令为
 git push ssh://zhangjinhao3@gerrit.pt.mioffice.cn:29418//miui/frameworks/interface HEAD:refs/for/master-v --no-thin
```

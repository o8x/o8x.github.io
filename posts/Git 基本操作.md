---
display-name: git 基本操作
date: 2020-06-12 13:46:06
tags: [ "git" ]
---

## 撤销最近提交的 commit 并保留文件变更

最近一次

```shell
git reset --soft HEAD^
```

最近3次

```shell
git reset --soft HEAD~3
```

reset 参数：

- —soft 撤销 commit，不删除文件变更。撤销 git add
- —hard 撤销 commit，删除文件变更并，撤销 git add
- —mixed 撤销commit，不删除文件变更，撤销 git add

## 将若干个commit合并到当前分支中

```shell
git cherry-pick commithash [commithash]
```

## 获取当前分支

```shell
git symbolic-ref --short -q HEAD
```

## 解决拒绝合并无关文件异常

> 仅发生在 git 本地仓库领先于远程仓库时

```shell
$ git pull origin master --allow-unrelated-histories
```

## 解决中文乱码

```shell
$ git config --global core.quotepath false
```

## 添加远程仓库与推送

### 添加远程仓库

```shell
$ git remote add $NAME $address
```

### 拉取代码

```shell
$ git pull $NAME $BRANCH
```

### 推送代码

```shell
$ git push $NAME $BRANCH
```

## 查看 remote url

```shell
$ git remote -v
```

## 拉取远程分支并在本地建立对应分支

**查看远程分支**

```shell
$ git branch -r
```

### 方法一

> 将会在本地新建分支，并自动切换到该分支

```shell
$ git checkout -b 本地分支名 origin/远程分支名
```

### 方法二

> 将会在本地新建分支x，但不会自动切换到该分支  
> 采用此种方法建立的本地分支将不会和远程分支建立映射关系

```shell
$ git fetch origin 远程分支名:本地分支名
```

## 分支

### 合并上游的变更到本地

```shell 
git pull origin master
```

### 切换分支

```shell 
git checkout dev
```

### 合并其他分支变更到当前分支

```shell 
git merge dev
```

## Tag

### 查看所有的Tag

```shell 
git tag
```

### 新建tag

```shell 
git tag V1.0 -m 'tag注释'
```

### 切换到tag

> 该 tag 上产生的任何变更，都不会在切换分支或 tag 时保存

```shell
git checkout tag 
```

### 从 tag 派生新分支

```shell 
git checkout tag 
git checkout -b branchname
```

### 推送单个tag

```shell
git push origin tagname
```

### 推送所有tag

```shell 
git push [origin] --tags
```

## 免密码登录与推送

### 方法一

> 默认记住15分钟

```shell
gitconfig--globalcredential.helpercache
```

**配置记住密码的时间**
> 配置一个小时之后失效

```shell
gitconfigcredential.helpercache--timeout=3600
```

### 方法二

> 将会长期记录密码

```shell
gitconfig --globalcredential.helperstore
```

### 方法三

> 增加远程地址的时候带上密码即可

```shell
http://yourname:password@github.com/name/project.git
```

### 方法三

使用ssh协议进行操作

## 修改最后一次提交

> 修改后，:wp 保存即可

```shell 
git commit -ament
```

## 修改最近几次历史提交

> 用`git log`查看需要修改的是第几条，`git rebase`操作符进行修改

- 修改最近的第2条

```shell
git rebase -i HEAD~2
```

- 从 pick 改成 edit

```shell
git commit --ament
```

- 保存到 rebase 里

```shell
git rebase --continue
```

- 强制推送覆盖服务器端历史

```shell
git push origin master -f
```

## 修改最后一次提交

> 修改后，:wp 保存即可

```shell 
git commit -ament
```

## 修改最近几次历史提交

> 用`git log`查看需要修改的是第几条，`git rebase`操作符进行修改

- 修改最近的第2条

```shell
git rebase -i HEAD~2
```

- 从 pick 改成 edit

```shell
git commit --ament
```

- 保存到 rebase 里

```shell
git rebase --continue
```

- 强制推送覆盖服务器端历史

```shell
git push origin master -f
```

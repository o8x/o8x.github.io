---
display-name: Git stash 简单用法
date: 2019-04-03 15:05:08
tags:
- git
---

*使用场景*

> 例如开发中突然需要处理其他分支的 bug，假设我不能放弃当前的开发并且修改的部分也不够一次提交。
>
> 那么我们就可以使用 `git stash` 把当前工作贮藏，再切换到其他分支处理完问题再回到当前分支，取出贮藏工作继续开发

## 使用

*贮藏当前修改*

```shell
git stash
```

查看当前的所有贮藏

```shell
git stash list
```

取出最后一次的贮藏到本地

```shell
git stash pop
```

清空所有贮藏

```shell
git stash clear

```

查看最近一次贮藏修改的文件列表

```shell
git stash show
# git stash show -p
```

## 工作流

*贮藏当前修改*

```shell
git stash 
```

*回到 master*

```shell
git checkout master
```

*从 master 得到修改 bug 的分支*

```shell
(master) git checkout -b fixbug
```

*处理bug并提交 , 推送fixbug到版本库*

```shell
(fixbug) git push origin fixbug
```

*回到dev分支继续之前的开发*

```shell
(fixbug) git checkout dev
```

*恢复最近一次贮藏到dev*

```shell
(dev) git stash pop
```

*继续之前的开发 ....*

```
//
```

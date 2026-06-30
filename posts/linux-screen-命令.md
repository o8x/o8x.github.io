---
display-name: linux screen 命令
date: 2018-08-21 17:07:08
categories:
- Linux
tags:

- Linux

---

> 一个由GUN开发的命令行工具 , 可以让窗口后台运行

### 安装

```shell 
$ yum -y install screen
```

### 使用

- 新建会话

```shell
screen -S s1 
```

- 换原来的会话

```shell
ctrl a + d
```

- 当前是默认会话 , 再新建一个会话

```shell 
screen -S s2
```

- 切换到另一个会话

```shell 
screen -r s2
```

- 销毁当前所在会话

```shell
screen -d
```

- 查看当前的所有会话

```
screen -ls
```

- 和他人共享当前会话

> 建立一个新的ssh链接，并执行 screen -x   
> 两个链接执行的命令和输出将会同步打印

```
screen -x
```

- 为session重命名

```shell
ctrl a 
:sessionname newName
```

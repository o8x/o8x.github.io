---
display-name: 神奇的lsof
date: 2018-09-20 09:30:53
tags: [ "Linux" ]
---

# 简介

参考资料: [http://man.linuxde.net/lsof](http://man.linuxde.net/lsof)

> lsof命令用于查看你进程开打的文件，打开文件的进程，进程打开的端口(TCP、UDP)。找回/恢复删除的文件。是十分方便的系统监视工具，因为lsof命令需要访问核心内存和各种文件，所以需要root用户执行。

# 安装

查看lsof是否安装

```bash
yum info lsof
```

安装

```bash
yum install -y lsof
```

# 使用

查看某个文件被哪个用户占用

```bash
lsof /path/file
```

查看使用某个目录下文件的进程

```bash
lsof -D /path
```

查看某个用户在使用的文件

```bash
lsof -u username
```

查看某个进程使用的文件

```bash
lsof -p threadnumber
```

每隔若干秒自动刷新

```bash
lsof -p 1121 -r 5
```

查看被占用的网络连接（可以带上网络协议来筛选）

```bash
lsof -i [TCP|UDP]
```

查看某个端口的进程

```bash
lsof -i:port
```

查看某个进程名字使用的端口

```bash
lsof -i -a -c nginx
```

查看端口范围的连接信息

```bash
lsof -i21-22
```

查看ip4 ip6的资源

```bash
lsof -i(4|6)
```

检查某个目录正在占用且没有释放的进程（例如磁盘满但是实际上却没有占用那么多）

```bash
lsof -a +L1
```

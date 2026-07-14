---
display-name: linux xargs 命令
date: 2018-05-06 21:04:58
tags: [ "Linux" ]
---

> 利用管道把上一个命令的出参作为下一个命令的入参使用

### 使用

#### 简单的使用

> 直接输出了 ls 的打印结果   
> 因为没有换行所以看起来没什么区别

```shell
$ ls | xargs echo
Applications Library System Users Volumes bin cores dev etc home opt private sbin tmp usr var
```

#### 自定义使用

> -I 参数可以指定占位符，xargs 运行时将会替换命令中的占位符为真实值

```shell
$ ls | xargs -I {} echo {}
Applications
Library
System
....
```

> 如果希望使用其他占位符（如：()），则需要使用 \ 进行转义，因为() 在shell中有特殊的含义

```shell
$ ls |  xargs -I \(\) echo current: \(\(\)\)
current: (Applications)
current: (Library)
current: (System)
...
```


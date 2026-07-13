---
display-name: 配置 linux jdk 环境变量
date: 2019-01-30 14:35:50
tags: [ "Linux" ]
---

### 写入环境变量

```shell
$ cat>>/etc/bashrc<<EOF
JAVA_HOME=/packages/jdk1.8.0_201/
CLASSPATH=$JAVA_HOME/lib/
PATH=$PATH:$JAVA_HOME/bin
export PATH JAVA_HOME CLASSPATH
EOF
```

### 使环境变量生效

```shell
$ source /etc/bashrc
```

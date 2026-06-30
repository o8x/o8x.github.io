---
display-name: 使用二进制包安装mysql
date: 2018-03-18 20:55:10
tags:

- Linux
- mysql

---

### 下载安装包

> 当前最新的 Mysql 5.7
>
的稳定版 [https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-el7-x86_64.tar](https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-el7-x86_64.tar)

### 解压

```shell
$ tar xvf ./mysql-5.7.21-el7-x86_64.tar
$ tar xzvf /mysql-5.7.21-el7-x86_64.tar.gz
```

### 建立用户

```shell
$ useradd -g mysql mysql
```

给文件授权 ,使其他用户不能轻易触碰mysql

cd mysql-5.7.21-el7-x86_64/
sudo chown -R root .
sudo chgrp -R mysql .

### 建立软连接

不知道为什么mysql必须要软连接到这个目录 ,但是不做会报错

### 必须是mysql ,其他名字无效

### 必须是绝对路径

ln -s /opt/mysql-5.7.21-el7-x86_64/ /usr/local/mysql

### 安装

### 如果上一步骤失败 ,这里是会报错的

cd /usr/local/mysql
sudo su

### 必须是已经存在的用户

./bin/mysqld --initialize --user=mysql

### 安装完成

最终会有类似的输出

2018-03-18T13:07:07.529522Z 1 [Note] A temporary password is generated for root@localhost: #lIA)q?Vl4uU

**其中`#lIA)q?Vl4uU`是默认密码**

### 此时启动可能会报错

./mysqld_safe --user=mysql &

### 2018-03-18T13:24:37.508484Z mysqld_safe mysqld from pid file /opt/mysql-5.7.21-el7-x86_64/data/a-language-of-clear-peace.pid ended

#### 解决方法 :

日志文件 : `/opt/mysql-5.7.21-el7-x86_64/data/data/xx.err`

方法1. 初始化mysql

/opt/mysql-5.7.21-el7-x86_64/scripts/mysql_install_db --user=mysql

方法2 . 3306端口已经被占用了

netstat -apn | grep 3306

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/03/fb9480d7b9bd2e998ca7911b7008086c.png)

#### 启动

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/03/483d86ac3e7e487d7041ddef3bb8972f.png)

---
display-name: 使用 MySQL Yum 仓库安装 MySQL
date: 2022-03-18 20:55:10
tags:

- Linux

---

# MySQL 官方教程（推荐）

Installing MySQL on Linux Using the MySQL Yum
Repository: [https://dev.mysql.com/doc/refman/5.7/en/linux-installation-yum-repo.html](https://dev.mysql.com/doc/refman/5.7/en/linux-installation-yum-repo.html)

MySQL 官方手册：[https://downloads.mysql.com/docs/refman-5.7-en.pdf](https://downloads.mysql.com/docs/refman-5.7-en.pdf)

# 简化教程

以下内容在 CentOS Linux 7.6.1810 (Core) 超级账户下经过验证

## 安装

安装 MySQL yum repo

```shell
$ yum install -y https://repo.mysql.com/mysql57-community-release-el7.rpm
```

查看可用的 MySQL 版本

```shell
$ yum repolist all | grep -P "mysql\d+-community/x86_64"
mysql55-community/x86_64            MySQL 5.5 Community Server      禁用
mysql56-community/x86_64            MySQL 5.6 Community Server      禁用
mysql57-community/x86_64            MySQL 5.7 Community Server      启用:    544
mysql80-community/x86_64            MySQL 8.0 Community Server      禁用
```

安装 MySQL Server，以 mysql 5.7 为例

```shell
$ yum install -y mysql-community-server --disablerepo=* --enablerepo=mysql57-community
```

## 启动

启动 MySQL Server

```shell
$ systemctl start mysqld
```

在服务器初始启动时，假设服务器的数据目录为空，则会发生以下情况：

- 服务器已初始化
- SSL证书和密钥文件在数据目录中生成
- 已安装并启用 validate_password

- 将创建超级用户帐户‘root’@’localhost’，设置超级用户的密码并将其存储在错误日志文件中。要显示密码，请使用以下命令：

```shell
$ grep 'temporary password' /var/log/mysqld.log
2021-12-23T02:59:32.831367Z 1 [Note] A temporary password is generated for root@localhost: 6<8irj04roI;
```

## 配置

- 修改安装时得到的临时密码

使用生成的临时密码登录，并为root用户帐户设置自定义密码：

> 默认启用密码强度验证，validate_password 实现的默认密码策略要求密码至少包含一个大写字母、一个小写字母、一个数字和一个特殊字符，并且总密码长度至少为8个字符。

```shell
$ mysql -u root -p
```

```mysql
mysql>
alter user 'root'@'localhost' identified by 'Vt!B2Tp]4w3gCA>$';
Query OK, 0 rows affected (0.00 sec)
```

- 用户

创建 MySQL 用户

```mysql
mysql>
create user 'cloudinstall'@'localhost' identified by 'MS:f1jp=2;9]Gs+g';
Query OK, 0 rows affected (0.00 sec)
```

授予 Usage 权限（只能用于登录，不能执行任何操作）

```mysql
mysql>
grant usage on cloudinstall.* to 'cloudinstall'@'%' identified by 'MS:f1jp=2;9]Gs+g' with grant option;
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

赋予任何主机使用密码远程访问数据库权限

```mysql
mysql>
grant all privileges on cloudinstall.* to cloudinstall@"%" identified by 'MS:f1jp=2;9]Gs+g';
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

[赋予某个主机使用密码远程访问数据库权限]

```mysql
mysql>
grant all privileges on cloudinstall.* to cloudinstall@"1.1.1.1" identified by 'MS:f1jp=2;9]Gs+g';
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

刷新权限

```mysql
mysql>
flush privileges;
Query OK, 0 rows affected (0.00 sec)
```

## 测试连接

参数：-h MySQL Server地址 -u 用户名 -p 使用密码进行连接

```shell
$ mysql -h remote.mysql-server.addr -u cloudinstall -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.36 MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
mysql>
```

## 附录

关闭远程访问

```mysql 
mysql> update user set host = "localhost" where user = "cloudinstall" and host = "%";
Query OK, 0 rows affected (0.00 sec)
```

查看数据库

```mysql
mysql>
show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
+--------------------+
1 row in set
(0.06 sec)
```

创建数据库

```mysql
mysql>
create database cloudinstall;
Query OK, 1 row affected (0.06 sec)
```

创建表

```mysql
mysql>
create table t
(
    id int primary key
);
Query OK, 0 rows affected (0.08 sec)
mysql>
select *
from t;
Empty set
(0.11 sec)
```

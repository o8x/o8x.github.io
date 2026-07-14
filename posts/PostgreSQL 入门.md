---
display-name: PostgreSQL 入门
date: 2020-10-28 11:35:37
tags: ["杂项"]
---

## 安装

### Macos

brew：https://formulae.brew.sh/formula/postgresql

pkg 文件：https://postgresapp.com/downloads.html

### Linux

Centos 8

```shell 
# Install the repository RPM:
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Disable the built-in PostgreSQL module:
dnf -qy module disable postgresql

# Install PostgreSQL:
dnf install -y postgresql13-server
```

Debian 8、9、10

```shell
# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt-get -y install postgresql
```

### 初始化

初始化数据库

```shell
postgresql-13-setup initdb
```

加入开机启动

```shell
systemctl enable postgresql-13
```

启动

```shell
systemctl start postgresql-13
```

## 连接数据库

> 安装好之后是无法直接使用的，需要先创建用户和数据库

进入超级管理员 CLI 环境

```shell
$ sudo -u postgres psql || psql -U postgres
psql (13.0)
Type "help" for help.

postgres=#
```

创建用户

```shell
postgres=# CREATE USER root
CREATE ROLE
```

设置超级管理员，否则无法创建数据库和表

```shell
postgres=# ALTER USER root SUPERUSER CREATEDB;
ALTER ROLE
```

查看用户列表

```shell
postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 root      | Superuser, Create DB                                       | 
```

创建数据库

```shell
$ createdb main
```

## 安全性配置

查看密码加密方式，13 默认采用了 `scram-sha-256`加密

```shell
postgres=# show password_encryption;
 password_encryption
---------------------
 scram-sha-256
(1 row)
```

查看当前用户信息，当前是空密码

```shell
postgres=# select * from pg_shadow where usename='root';
 usename | usesysid | usecreatedb | usesuper | userepl | usebypassrls | passwd  | valuntil | useconfig
---------+----------+-------------+----------+---------+--------------+-------- +----------+-----------
 root    |    16384 | t           | t        | f       | f            |         |          |
(1 row)
```

设置密码

```shell
postgres=# alter role test password 'password';
ALTER ROLE
```

设置密码有效期[非必须]

```shell
postgres=# alter role test valid until '2020-10-31 00:00:00';
ALTER ROLE
```

## 远程连接配置

默认只允许本地连接，需要修改配置文件。

```shell
$ cat /var/lib/pgsql/13/data/pg_hba.conf
....
# IPv4 local connections:
host    all             all             0.0.0.0/0               scram-sha-256 # 增加这一行
....
```

将 localhost 改成 *

```shell
$ cat /var/lib/pgsql/13/data/postgresql.conf
...
# listen_addresses = 'localhost'
listen_addresses = '*'
...
```

重启服务端

```shell
systemctl restart postgresql-13
```

## 链接测试

```shell
$ psql -h example.com -U root -p 5432 -d postgres
Password for user root:
psql (13.0)
Type "help" for help.

postgres=#
```

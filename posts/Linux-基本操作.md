---
display-name: Linux 基本操作
date: 2020-06-09 14:40:06
tags: [ "Linux" ]
---

### 增加用户普通用户并提权到管理员

添加用户

```shell
useradd alex
```

切换用户和设置密码

```shell
su alex
passwd
```

#### 提升到管理员

切换回 root

```shell
su root
```

为sudoers 文件增加写权限

```shell
chmod u+w /etc/sudoers
```

编辑 sudoers 文件，在 root ALL=(ALL) ALL 下面增加

```shell
# 允许 alex 用户输入密码执行 sudo 
alex   ALL=(ALL)     ALL
# 允许 alex 组内的用户输入密码执行 sudo 
%alex  ALL=(ALL)     ALL

# 允许 alex 用户不输入密码执行 sudo 
alex   ALL=(ALL)     NOPASSWD: ALL
# 允许 alex 组内用户不输入密码执行 sudo 
%alex  ALL=(ALL)     NOPASSWD: ALL
```

取消 sudoers 文件权限

```shell
chmod u-w /etc/sudoers
```

### 密码策略

**查看密码有效期**

可以看到过期时间是 8月 20

```shell
$ chage -l root
Last password change            : Jul 31, 2020
Password expires                    : Aug 20, 2020
Password inactive                    : never
Account expires                        : never
Minimum number of days between password change        : 0
Maximum number of days between password change        : 20
Number of days of warning before password expires    : 7
```

**修改密码有效期 **

比如修改root用户的密码有效期到 40 天后

```shell
$ chage -M 40 root

[root@localhost.localdomain:/root]
$ chage -l root
Last password change            : Jul 31, 2020
Password expires                    : Sep 09, 2020
Password inactive                    : never
Account expires                        : never
Minimum number of days between password change        : 0
Maximum number of days between password change        : 40
Number of days of warning before password expires    : 7
```

**参数**

时间也可以使用标准日期，例如 `chage -E "2020-07-31" root`

参数可连用，如`chage -M 30 -E "2020-09-01" -W 30 -m 0 -W 30 root`

| 参数 | 命令              | 作用                                                        |
| ---- | ----------------- | ----------------------------------------------------------- |
| -m   | chage -m 30 root  | 配置密码可更改的最小时间，默认值0表示任何时间都可以更改密码 |
| -M   | chage -M 30 root  | 配置密码保持有效的最大时间                                  |
| -W   | chage -W 30 root | 密码到期前多少天发对密码失效警告                            |
| -E   | chage -E 30 root  | 账号过期时间，超过日期后账号将不可用                        |
| -d   | chage -d 30 root  | 设置上一次更改密码的日期，设置0将会强制要求在登陆时修改密码 |
| -I   | chage -I 30 root  | 等待日期，如果密码过期了这么久，账号将不可用                |
| -l   | chage -l root    | 列出用户密码过期的详细信息                                  |

### SCP

> scp会将第一个参数的文件，拷贝到第二个参数的位置

```shell
$ scp file root@server.com:/path/file
```

### dd

#### 创建`1000000`个指定大小的空文件

```shell
$ seq 1000000 | xargs -i {} dd if=/dev/zero of={}.dat bs=1024 count=1
```

#### 创建一个指定大小的文件

```shell
$ dd if=/dev/zero of=filename bs=1M count=1000
```

#### 快速创建一个超大文件

```shell
$ dd if=/dev/zero of=filename bs=1M count=0 seek=100000
```

### 设置DNS

```shell
$ # 主DNS
$ echo "nameserver 223.6.6.6" > /etc/solve  
$ # 次DNS
$ echo "nameserver 114.114.114.114" >> /etc/solve   
```

### 用户提权到管理员

> 使用root组用户编辑`/etc/sudoers`，保存退出就可以用 sudo 了

```shell
$ username  ALL=(ALL)  ALL
```

### 修改主机名

> 当前shell生效，重启失效

#### centos

```shell 
hostname new-hostname
```

#### centos

```shell 
sudo hostnamectl set-hostname new-hostname
```

### 设置固定IP

> 当前shell生效，重启失效

```shell
sudo ifconfig wlan0 192.168.1.80 netmask 255.255.255.0
```

### 用户操作

#### 修改用户名和密码

> 当前shell生效，重启失效

```shell 
$ passwd 
Changing password for Alex.
Old Password: 
New Password: 
Retype New Password:  
```

#### 修改用户名

> 重启生效

```shelll
$ sudo su
$ sed -i "s/oldUser/newUser/g" /etc/passwd 
$ sed -i "s/oldUser/newUser/g" /etc/shadow 
```

#### 修改家目录

> 重新登陆生效

```shell
$ mv /home/oldUser /home/newUser 
```

### zip 压缩包

#### 带密码

```shell
$ zip -rP password package.zip ./* 
```

#### 不带密码

```shell
$ zip package.zip ./* 
```

#### 解压

```shel
$ unzip package.zip
```

### bzip 套娃，自己压缩自己

> 将自己直接压缩，不产生新文件

```shell
$ bzip2 -z file.sql
$ ls 
file.sql.bz2
$ bzip2 -z file.sql.bz2
$ ls 
file.sql.bz2.bz2
```

### 解压 gzip

```shell
$ gzip -d xxx.gz
```

### XZ 压缩

> 与 bzip 相反，xz 在解压缩时会直接修改自己

#### 压缩文件

 ```shell
$ xz image.png
 ```

#### 解压缩

```shell
$ xz -d image.png.xz 
$ unxz image.png.xz 
```

#### 保留源文件压缩，并输出到指定目录

```shell
$ xz -c image.png > image.png.xz 
```

#### 查看xz文件中的内容

```shell
$ xzcat image.png.xz | more 
```

#### 保留源文件解压缩，并输出到指定目录

```shell
$ xz -c -d image.png.xz > image.png
$ unxz -c image.png.xz > image.png
```

### 安装字体

> 将解压后的字体文件夹复制到`/usr/share/fonts`目录下

#### 更新字体缓存

```shell
$ fc-cache -fv
```

### overlay

> 开启驱动管理器的 overlay 功能之后，操作系统就不会再保存当前的工作，效果类似冰点还原

```shell
$ sudo overlayroot-disable
```

### 设置开机自启动程序

#### 脚本

```shell
$ cat ./init.sh
#!/bin/env bash
# chkconfig: 2345 10 90

echo `date` >> /tmp/test.log
```

#### 移动脚本到指定目录

```shell
mv ./init.sh /etc/init.d/init
chmod +x /etc/init.d/init
```

#### 加入开机启动

```shell
chkconfig --add init
```

#### 查看是否被加入了

```shell
$ chkconfig --list init
```

#### 开启开机自启动

```
chkconfig init on
```

### 文件属性

#### 查看文件属性

```shell
lsattr  ./file
```

#### 禁止文件的删除与修改

```shell
chattr +i ./file
```

#### 解除禁止删除与修改的属性

```shell
chattr -i ./file
```

---
display-name: Centos 升级到主线最新内核
draft: false
date: 2020-08-19 08:40:26
tags:
- Linux 内核
- CentOS

categories:
- Linux
---

## 查看当前版本

当前系统版本

```shell
root:~ # cat /etc/redhat-release
CentOS Linux release 8.2.2004 (Core)
```

当前内核版本

```shell
root:~ # uname -r
4.18.0-147.8.1.el8_1.x86_64
```

## ELRepo

> ELRepo 仓库是基于社区的用于企业级 Linux 仓库，提供对 RedHat Enterprise（RHEL）和其他基于 RHEL的 Linux
> 发行版（CentOS、Scientific、Fedora 等）的支持。ELRepo
>
聚焦于和硬件相关的软件包，包括文件系统驱动、显卡驱动、网络驱动、声卡驱动和摄像头驱动等。网址：http://elrepo.org/tiki/tiki-index.php。
>
> 值得注意的是，ELRepo 是跟随主线更新的，一般意义上意味着与 linux 当前最新的内核版本对齐

### 导入 ELRepo 公共密钥

```shell
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
```

### 安装 ELRepo yum 源

CentOS 8

```shell
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
```

CentOS 7

```shell
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
```

## 安装

### 查看可用内核

```shell
[9:20:35] root:~ # yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
Repository epel is listed more than once in the configuration
Last metadata expiration check: 16:55:48 ago on Tue 18 Aug 2020 04:24:51 PM CST.
Available Packages
bpftool.x86_64                              5.8.1-1.el8.elrepo            elrepo-kernel
elrepo-release.noarch                       8.2-1.el8.elrepo              elrepo-kernel
kernel-ml-devel.x86_64                      5.8.1-1.el8.elrepo            elrepo-kernel
kernel-ml-doc.noarch                        5.8.1-1.el8.elrepo            elrepo-kernel
kernel-ml-headers.x86_64                    5.8.1-1.el8.elrepo            elrepo-kernel
kernel-ml-modules-extra.x86_64              5.8.1-1.el8.elrepo            elrepo-kernel
kernel-ml-tools.x86_64                      5.8.1-1.el8.elrepo            elrepo-kernel
kernel-ml-tools-libs.x86_64                 5.8.1-1.el8.elrepo            elrepo-kernel
kernel-ml-tools-libs-devel.x86_64           5.8.1-1.el8.elrepo            elrepo-kernel
perf.x86_64                                 5.8.1-1.el8.elrepo            elrepo-kernel
python3-perf.x86_64                         5.8.1-1.el8.elrepo            elrepo-kernel
```

### 安装最新内核

```shell
yum --enablerepo=elrepo-kernel install kernel-ml kernel-ml-devel
```

## 配置

### 设置以最新内核启动

```shell
grub2-set-default 0
```

### 生成grub配置（可省略）

```shell
grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 重启

```shell
reboot
```

## 验证

### 查看当前内核

可以看到已经换成了新内核

```shell
[9:25:45] root:~ # uname -r
5.8.1-1.el8.elrepo.x86_64
```

### 当前安装的所有内核

不需要的内核可以使用 yum 或 rpm 进行卸载

```shell
[9:30:35] root:~ # rpm -qa | grep kernel
kernel-devel-4.18.0-193.6.3.el8_2.x86_64
kernel-core-4.18.0-193.6.3.el8_2.x86_64
kernel-modules-4.18.0-193.6.3.el8_2.x86_64
kernel-core-4.18.0-147.8.1.el8_1.x86_64
kernel-ml-5.8.1-1.el8.elrepo.x86_64
kernel-devel-4.18.0-147.8.1.el8_1.x86_64
kernel-modules-4.18.0-147.el8.x86_64
kernel-4.18.0-147.el8.x86_64
kernel-tools-4.18.0-193.6.3.el8_2.x86_64
kernel-4.18.0-193.6.3.el8_2.x86_64
kernel-tools-libs-4.18.0-193.6.3.el8_2.x86_64
kernel-4.18.0-147.8.1.el8_1.x86_64
kernel-ml-core-5.8.1-1.el8.elrepo.x86_64
kernel-core-4.18.0-147.el8.x86_64
kernel-modules-4.18.0-147.8.1.el8_1.x86_64
kernel-ml-modules-5.8.1-1.el8.elrepo.x86_64
kernel-headers-4.18.0-193.6.3.el8_2.x86_64
```


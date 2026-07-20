---
display-name: Linux 内核模块编译环境配置
date: 2022-06-18 13:48:04
tags: ["Linux"]
---

编译 linux 内核模块需要安装内核的开发包，以下流程仅供参考

## CentOS

### KDIR配置

```makefile
KDIR := /usr/src/kernels/$(shell uname -r)
```

### 安装内核开发工具包

Centos 下较为简单，安装 kernel-devel 这个包之后，就会出现 `/usr/src/kernels/$(uname -r)/` 这个目录

```shell
yum install kernel-devel-`uname -r`
```

### 手动安装

各大镜像源都有提供 kernel-devel 的rpm下载，只需要对应到次版本号即可。

```shell
yum install https://mirrors.aliyun.com/centos/8/BaseOS/x86_64/os/Packages/kernel-devel-4.18.0-348.el8.x86_64.rpm
```

如果是基于 elrepo 则需要安装 kernel-ml-devel

```shell
yum --enablerepo=elrepo-kernel install kernel-ml-devel
```

## Debian

### KDIR配置

```makefile
KDIR := /lib/modules/$(shell uname -r)/build
```

或

```makefile
KDIR := /usr/src/kernels/$(shell uname -r)
```

### 安装内核开发工具包

debian 下编译内核模块时引用的 headers 的版本一定要 `uname -r` 完全对应，否则将无法装载模块。

```shell
apt install linux-headers-`uname -r`
```

### 手动安装 deb 文件

截至目前 linux-headers-5.18.0
在 [sid](https://packages.debian.org/sid/kernel/linux-headers-5.18.0-1-amd64) 仓库，5.10.0-10
在 [stable](https://packages.debian.org/stable/kernel/linux-headers-5.10.0-10-amd64) 仓库。如果这两个仓库中都没有对应版本的
headers，则需要去各大镜像源搜索下载，或将内核更换为仓库中的版本。

例如 5.10.0-13 在 [mirrors.sdu.edu.cn](https://mirrors.sdu.edu.cn) 可以找到

```shell
wget https://mirrors.sdu.edu.cn/debian/pool/main/l/linux/linux-headers-5.10.0-13-amd64_5.10.106-1_amd64.deb
apt install ./linux-headers-5.10.0-13-amd64_5.10.106-1_amd64.deb
```

## GCC

先试试

```shell
apt -f install
```

高版本 gcc 在 sid 源中，可以启用后安装对应版本，例如 gcc-11

```shell 
apt install gcc-11
```

### 手动安装

下载 deb 手动 `dpkg -i` 安装即可

例如：https://packages.debian.org/bullseye/gcc-10

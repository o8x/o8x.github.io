---
display-name: Ubuntu/Debian 升级 Linux 内核
date: 2022-06-21 10:02:16
tags:

- Linux
- Linux 内核

---

本文章仅对 x86_64 生效，其他架构例如 arm64 仅供参考

## 设置系统为非交互模式

```shell
export DEBIAN_FRONTEND=noninteractive
```

## 备份 sources.list

```shell
cp /etc/apt/sources.list /etc/apt/sources.list.back
```

## Ubuntu

### 更新镜像源

```shell
UBUNTU_CODE=$(grep UBUNTU_CODENAME /etc/os-release | cut -d = -f 2)
cat >/etc/apt/sources.list <<EOF
deb https://mirrors.ustc.edu.cn/ubuntu/ ${UBUNTU_CODE} main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${UBUNTU_CODE}-security main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${UBUNTU_CODE}-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${UBUNTU_CODE}-backports main restricted universe multiverse
EOF
apt update -y
```

### 安装新内核

以 5.4.0-99-generic 为例，linux-headers 为开发工具包，可以不安装

```shell
apt install -y linux-image-5.4.0-99-generic linux-headers-5.4.0-99-generic
```

### 主线内核

可以在 [kernel.ubuntu.com](https://kernel.ubuntu.com/~kernel-ppa/mainline/) 获得 deb
文件并进行  [手动安装](https://wiki.ubuntu.com/Kernel/MainlineBuilds)

### Debian

- 其中 [trusted=yes] 是关闭GPG信任检查
- 其中 sid 指开发版本，在此源可获得最新的软件包，但有可能会导致系统非常不稳定

```shell
cat> /etc/apt/sources.list<<EOF
deb [trusted=yes] http://mirrors.tencent.com/debian sid main contrib non-free
deb [trusted=yes] http://mirrors.tencent.com/debian backports main contrib non-free
EOF
apt update -y  
```

### GPG NO_PUBKEY  问题

```shell
apt install dirmngr -y
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys XXXXXX
```

### 安装新内核

```shell
apt install -y linux-image-5.18.0-3-rt-amd64 linux-headers-5.18.0-3-rt-amd64
```

## 卸载旧内核

```shell
apt remove -y linux-headers-$(uname -r) linux-image-$(uname -r)
apt autoremove
```

## 恢复 sources.list

```shell
cp /etc/apt/sources.list.back /etc/apt/sources.list
```

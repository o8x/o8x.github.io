---
display-name: Linux 内核模块配置自动装载
date: 2022-06-18 11:48:01
categories:
- Linux 内核
tags:

- Linux 内核

---

使用上一节的 fried_chicken.ko 文件

### 将模块安装为系统模块

```shell
install -D -m 644 fried_chicken.ko /lib/modules/$(uname -r)/kernel/drivers/fried_chicken.ko
```

扫描系统中的所有模块

```shell
depmod -a
```

识别为系统模块并自动装载

```shell
modprobe fried_chicken
```

### 开机自动装载

CentOS

```shell
if [[ $(cat /etc/os-release | grep 'ID="centos"') ]]; then
    echo $MODULE_NAME >/etc/modules-load.d/fried_chicken.conf
fi
```

Debian

```shell
if [[ -f /etc/modules ]]; then
    [[ $(cat /etc/modules | grep fried_chicken) ]] || echo fried_chicken >>/etc/modules
fi
```

---
display-name: Ubuntu Server 下安装卸载 GUI
date: 2022-08-05 10:05:28
tags: [ "Linux" ]
---

## 安装

换源

```shell
sed -i 's/ports.ubuntu.com/mirrors.ustc.edu.cn/g' sources.list
```

安装

```shell
apt update -y
apt install ubuntu-desktop
reboot
```

安装完成

![]({{ env.cdn_accelerate }}/4EB13783-8258-4237-8DB3-CDBF1C5E22B4.png)

## 卸载

```shell
apt remove ubuntu-desktop gnome* x11*
apt autoremove
reboot
```

又回到了字符界面

![]({{ env.cdn_accelerate }}/Xnip2022-08-05_10-09-24.jpg)

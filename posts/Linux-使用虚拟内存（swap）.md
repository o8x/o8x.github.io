---
display-name: Linux 使用虚拟内存（swap）
date: 2020-08-17 11:15:00
categories:
- Linux
tags:  
- Linux
---



将体积为 1024M 的 0 填充到 /swapfile中4次。即生成体积为一个4G的空文件

```shell
sudo dd if=/dev/zero of=/swapfile bs=1024M count=4
```

将刚才生成的空文件格式化为 swap 分区格式

```shell
sudo mkswap /swapfile
```

使用刚才的文件，作为虚拟内存

```shell
sudo swapon /swapfile
```


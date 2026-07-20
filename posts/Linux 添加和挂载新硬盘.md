---
display-name: linux 添加和挂载新硬盘
date: 2018-09-15 14:46:06
tags: [ "Linux" ]
---

### 查看硬盘

```shell
fdisk -l
```

![]({{ env.cdn_accelerate }}/2018/09/77415dfcd41b4d967493b966bf711e35.png)

### 创建分区

#### mbr方案

> 使用 disk 工具创建MBR分区 **仅支持小于2T的硬盘**

```shell
fdisk /dev/sdb
n       # 创建分区
p       # 主分区
1       #分区号，第一分区
enter   # 起始扇区，按需修改
enter   # 结束扇区，无论盘多大，最大都是2T
w       # 保存分区表
```

#### gpt 方案，理论上无大小限制

> 使用 parted 工具，创建GPT分区

```shell
parted /dev/sdb
(parted) mklabel gpt # 创建分区表
(parted) print # 查看磁盘
(parted) mkpart primary 0 20000GB # 在0位置创建一个 20000G 的分区表
Ignore # 忽略
(parted) print # 再看一下，就应该有分区了
(parted) quit # 退出

$ fdisk -l
```

![]({{ env.cdn_accelerate }}/2018/09/c11d12769916c409184102da4964fd0d.png)

### 挂载

#### 格式化

> 推荐格式：btrfs ext3 ext4 xfs

```shell
mkfs.ext4 /dev/sdb1
```

#### 挂载分区

```shell
mount /dev/sdb1 /es-data
```

#### 查看分区

```shell
df -h
```

![]({{ env.cdn_accelerate }}/2018/09/03680ab8fee28662dab6b63d5c283f26.png)

#### 设置开机自动挂载

```
# 推荐
$ echo "/dev/sdb /data ext4 defaults 0 0" >> /etc/fstab

# rc.local 相对于 fstab 加载稍慢
$ echo "mount /dev/sdb /data" >>  /etc/rc.local
```


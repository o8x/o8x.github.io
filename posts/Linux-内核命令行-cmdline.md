---
display-name: Linux 内核命令行 cmdline
draft: false
date: 2019-05-06 09:00:00
tags: ["Linux"]
---



bootloader 可以以KV形式，传递一些数据给linux内核，使得内核在启动时可以按自定义的方式启动。这些参数在内核启动完成后都会写在 /proc/cmdline 中，可以随时进行读取使用

内核参数分三种：

- 通用参数

  kernel 需要的启动参数，例如 console root 等

- 驱动参数

  供驱动调用的参数，例如是否在于某驱动，在何时载入

- 自定义参数

  任意参数，在系统启动时或启动后可以进行读取使用

以下演示几种 bootloader 传递自定义内核的参数`CUSTOM_MSG=alex`到系统中的方式

qemu

```shell
qemu-system-x86_64 -m 1024 -kernel vmlinuz -initrd bin/initrd.img \
    -append "console=tty0 selinux=0 biosdevname=0 DEVELOPER=1 CUSTOM_MSG=alex"
```

grub2

```shell
set default="0"
set timeout=5

menuentry "Pioneer" {
    linux /vmlinuz console=tty0 selinux=0 biosdevname=0 DEVELOPER=1 CUSTOM_MSG=alex
    initrd /initrd.img
}
```

PXE

```ini
DEFAULT menu.c32
PROMPT 0
TIMEOUT 30

LABEL bootos
MENU LABEL ^BootOS
MENU DEFAULT
KERNEL /vmlinuz
APPEND initrd = /initrd.img console=tty0 selinux=0 biosdevname=0 DEVELOPER=1 CUSTOM_MSG=alex
IPAPPEND 2
```


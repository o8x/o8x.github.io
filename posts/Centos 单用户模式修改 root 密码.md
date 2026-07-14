---
display-name: Centos 单用户模式修改 root 密码
date: 2020-08-30 09:39:34
tags: [ "Linux", "CentOS" ]
---

## 第一阶段

1. grub引导启动cenots，到选择内核的界面
1. 按方向键选择到需要的内核，一般是第一个。
1. 键盘按下 e 会进入到一个类似编辑器的界面
1. 找到 fi 的下一行中的 ro
1. 将 ro 替换为 rw init=/sysroot/bin/sh 或其它你喜欢的 shell
1. 按 Ctrl + X，系统将会重启

## 第二阶段

1. 此时系统重启到了一个shell界面，即你在init输入的那个shell
1. 此时 /sysroot 是原来机器的系统
1. 执行 chroot /sysroot 切换 root 到原系统
1. 执行 passwd 修改 root 密码
1. 如果原系统里开启了 selinux ，则需要再执行 touch /.autorelabel
1. 执行 exit 退出 chroot 环境

## 第三阶段

1. 执行 reboot 正常重启，开机即可使用新密码了

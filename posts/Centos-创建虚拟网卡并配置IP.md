---
display-name: Centos 创建虚拟网卡并配置IP
date: 2020-07-22 09:37:31
tags: [ "Linux", "CentOS" ]
---

## 工作目录

```shell
$ cd /etc/sysconfig/network-scripts/

$ ll ifcfg*
-rw-r--r-- 1 root root 174 Jul 20 09:07 ifcfg-eno1
-rw-r--r-- 1 root root 277 Jul 20 09:07 ifcfg-eno2
-rw-r--r-- 1 root root 254 Aug 24  2018 ifcfg-lo
```

## 创建配置文件

其中的 ifcfg-eno1 是主网卡，复制它作为我们的虚拟网卡配置文件

```shell
$ cp ifcfg-eno1 ifcfg-eno1:1

$ ll ifcfg*
-rw-r--r-- 1 root root 174 Jul 20 09:07 ifcfg-eno1
-rw-r--r-- 1 root root 174 Jul 20 09:09 ifcfg-eno1:1
-rw-r--r-- 1 root root 277 Jul 20 09:07 ifcfg-eno2
-rw-r--r-- 1 root root 254 Aug 24  2018 ifcfg-lo
```

## 修改配置

en1的配置文件

```ini
$ cat /etc/sysconfig/network-scripts/ifcfg-eno1
DEVICE = eno1
BOOTPROTO = static
IPADDR = 221.xxx.xxx.xxx
NETMASK = 255.255.255.0
GATEWAY = 221.229.210.1
DNS1 = 114.114.114.114
DNS2 = 223.5.5.5
ONBOOT = yes
TYPE = Ethernet
NM_CONTROLLED = no
```

| 项            | 作用                                          |
| ------------- | --------------------------------------------- |
| DEVICE        | 设备名                                        |
| BOOTPROTO     | IP性质，static 是静态                         |
| IPADDR        | 网卡的IP地址                                  |
| NETMASK       | 子网掩码                                      |
| DNS1、DNS2    | DNS和备选DNS                                  |
| ONBOOT        | 是否在启动时自动配置，即 (up) 网卡            |
| TYPE          | 网络类型，Ethernet 以太网                     |
| NM_CONTROLLED | 是否在修改后无需重启，自动生效。建议设置为 no |

我们不需要网关，DNS，只留下这些即可。

```shell
cat >ifcfg-eno1:1<<EOF
DEVICE=eno1:1
BOOTPROTO=static
IPADDR=192.168.198.1
NETMASK=255.255.255.0
ONBOOT=yes
TYPE=Ethernet
NM_CONTROLLED=no
EOF
```

## 重启Network

```shell
$ service network restart

$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:a0:d1:ea:a3:8c brd ff:ff:ff:ff:ff:ff
    inet 221.xxx.xxx.xxx/24 brd 221.xxx.xxx.xxx scope global eno1
       valid_lft forever preferred_lft forever
    inet 192.168.198.1/24 brd 192.168.198.255 scope global eno1:1
       valid_lft forever preferred_lft forever
    inet6 fe80::2a0:d1ff:feea:a38c/64 scope link
       valid_lft forever preferred_lft forever
3: eno2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 00:a0:d1:ea:a3:8d brd ff:ff:ff:ff:ff:ff
```

其中 2：eno1 下的 eno1:1 就是我们创建完成的虚拟网卡

同理，如果配置多个IP也只需要复制几份 eno1 即可




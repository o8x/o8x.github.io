---
date: 2026-07-17 17:44:00
tags: [ "Linux" ]
---

Linux 下镜像网卡流量到统一 tap 网卡

## 网卡直接镜像方案

创建 tap0 并保持打开

```shell
ip tuntap add dev tap0 mode tap
ip link set tap0 up
```

将网卡 ens33 双向镜像到 tap0，多网卡命令相同

```shell
tc qdisc add dev ens33 clsact
tc filter add dev ens33 ingress matchall action mirred egress mirror dev tap0
tc filter add dev ens33 egress matchall action mirred egress mirror dev tap0
```

清理

```shell
ip link del tap0
tc qdisc del dev ens33 clsact
```

## 网桥方案

创建网桥

```shell
ip link del br-mirror
ip link add name br-mirror type bridge
ip link set br-mirror up
```

将网卡加入网桥并迁移 IP 地址，多网卡命令相同

1. 网卡加入桥后，它们对外通信显示的 MAC 会变成桥的 MAC
2. 如果设计管理口，网络会断开

```shell
ip addr del 172.16.3.122/22 dev ens33
ip link set ens33 master br-mirror
ip addr add 172.16.3.122/22 dev br-mirror
# 如果物理网卡之间存在冗余连接，可能形成环路，需要启用生成树
# ip link set br-mirror type bridge stp_state 1。
```

重建默认路由，设置流量从网桥经过

```shell
ip route del default 2>/dev/null
ip route add default via 172.16.3.1 dev br-mirror
```

将网桥流量双向镜像到 tap0

```shell
tc qdisc add dev br-mirror clsact
tc filter add dev br-mirror ingress matchall action mirred egress mirror dev tap0
tc filter add dev br-mirror egress matchall action mirred egress mirror dev tap0
```

清理

```shell
tc qdisc del dev br-mirror clsact

# 恢复路由和释放IP地址，如果有多个网卡则需要分别执行
ip link set ens33 nomaster
ip addr add 172.16.3.122/22 dev ens33
ip route del default via 172.16.3.1 dev br-mirror
ip route add default via 172.16.3.1 dev ens33

ip link del br-mirror
```

## 载波

TAP 设备只有被用户态程序打开后内核才会把它置为 LOWER_UP（有载波），否则所有送往它的数据包都会被 dev_queue_xmit 直接丢弃

无载波状态使用 tcpdump 抓不到流量，并且查看 tc overlimits 会一直上涨

```shell
root@ubuntu:~# ip link show tap0
33: tap0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 1000
    link/ether aa:d8:6f:ed:6c:51 brd ff:ff:ff:ff:ff:ff
root@ubuntu:~# watch -n1 tc -s filter show dev ens37 ingress
filter protocol all pref 49152 matchall chain 0
filter protocol all pref 49152 matchall chain 0 handle 0x1
  not_in_hw (rule hit 87814)
	action order 1: mirred (Egress Mirror to device tap0) pipe
	index 3 ref 1 bind 1 installed 3710 sec firstused 3710 sec
	Action statistics:
	Sent 16085043 bytes 87839 pkt (dropped 0, overlimits 86209 requeues 0)
	backlog 0b 0p requeues 0
```

使用 DPDK net_tap PMD 或 python 都可以打开载波

```shell
python3 -c "
import os, fcntl, struct, time
fd = os.open('/dev/net/tun', os.O_RDWR)
ifr = struct.pack('16sH', b'tap0', 0x0002)  # IFF_TAP = 0x0002
fcntl.ioctl(fd, 0x400454ca, ifr)           # TUNSETIFF

while True:
    time.sleep(60)
"
```

```shell
dpdk-testpmd -l 0-2 --no-huge --vdev=net_tap0,iface=tap0 -- -i
```

此时 tap0 是 LOWER_UP 状态

```shell
root@ubuntu:~# ip link show tap0
33: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether aa:d8:6f:ed:6c:51 brd ff:ff:ff:ff:ff:ff
```

抓包测试

```shell
root@ubuntu:~# timeout 1 tcpdump -vvvnei tap0
tcpdump: listening on tap0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:10:41.422695 30:52:cb:7c:ff:47 > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: Ethernet (len 6), IPv4 (len 4), Request who-has 172.16.0.251 tell 172.16.2.130, length 46
...
20 packets captured
20 packets received by filter
0 packets dropped by kernel
```

临时测试

在启动 tcpdump 的情况下，执行 tunctl 的瞬间能抓到几个包

```shell 
tunctl -t tap0 -u root
```


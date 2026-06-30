---
display-name: 简单的在 Linux 下配置网桥
date: 2022-08-04 09:31:01
categories:
- Linux
tags:

- Linux
---

## 安装依赖

安装 brctl 或 iproute

ubuntu

```shell
apt intstall -y brctl iproute2
```

alpine

```shell
apk add brctl iproute2
```

## 配置网桥

以创建虚拟网桥 br-bridge 并桥接 eth1 eth2 两张网卡为例

ip route

```shell
ip link add name br-bridge type bridge
ip link set dev br-bridge up
ip link set dev eth1 master br-bridge
ip link set dev eth2 master br-bridge
```

brctl

```shell
brctl addbr br-bridge
brctl addif br-bridge eth1 eth2
```

## 启动网卡

避免因为网桥或网卡未启动的，导致流量无法正常通过

```shell
ip link set eth1 up
ip link set eth2 up
ip link set br-bridge up
```

---
display-name: DPDK 基本概念
date: 2024-09-16 12:45:35
tags: ["C++", "DPDK"]
---

## 基本概念

intel 开发的高性能数据面开放工具和库，基本原理是绕过内核，通过 DMA 接管网卡流量实现用户态网络协议栈，提高性能。提供了包括负载均衡器，内存池，网络驱动程序等模块。

### 理论基础

> 直接存储器访问(direct memory access，DMA)意为外设对内存的读写过程可以不用 CPU 参与而直接进行。

> 如果没有 DMA，一个普通网卡为了从内存获取需要发送的数据，需要通过总线告知 CPU 自己的数据请求(具体方法是，网卡通过中断通知
> CPU，然后 CPU 主动来读取寄存器，获取网卡的请求)，然后 CPU 会把主机内存中的数据复制到设备内部的存储空间中，其间可能还需要 CPU
> 寄存器的暂存。如果数据量比较大，那么很长一段时间内 CPU 都会忙于复制数据 而无法投入其他工作。
> CPU 的最主要的工作是计算和控制，而不是进行数据复制，数据复制的工作白白浪费了 CPU 的计算能力，也减弱了它对全局的控制力。为了让
> CPU 投入更有意义的工作中，人们设计了 DMA 机制，比如总线上挂一个 DMA 控制器(现在一般网卡内部就自带这个功能)，专门用来读写内存。

## 必要条件

- linux Kernal > 4.19 `uname -r`
- glibc >= 2.7 `ldd --version`

### 换源【非必需】

```shell
cat >/etc/apt/sources.list.d/ubuntu.sources <<EOF
Types: deb
URIs: https://mirrors.ustc.edu.cn/ubuntu
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.ustc.edu.cn/ubuntu
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 预发布源
# Types: deb
# URIs: https://mirrors.ustc.edu.cn/ubuntu
# Suites: noble-proposed
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

```

### 编译工具链

```shell
apt install -y \
    build-essential \
    meson \
    ninja-build \
    python3-pyelftools
```

### 非必要

BPF

```shell
apt install -y libelf-dev
```

NUMA

```shell
apt install -y libnuma-dev
```

pkg-config

```shell
apt install -y pkgconf
```

### Hugepages

现代操作系统都不允许程序直接访问物理内存，而是工作在内存管理单元(MMU)
从物理内存映射的虚拟内存下。特例是16位程序还可以直接操作物理内存，即实模式。这个映射关系即页表，由操作系统管理。MMU相当于一种代理，将应用程序对虚拟地址的操作映射到物理内存中（和操作系统实现有关）。

> 虚拟地址和物理地址之间的映射由操作系统建立，并保存为页表放入系统内存。程序运行过程中，处理器执行和内存读写有关的指令时，指令中的地址为虚拟地址，此虚拟地址会被
> MMU 转换为物理地址再发到物理总线上。MMU 根据页表的内容执行这种地址转换。
> 既然提到了页表，就要弄明白什么是分页。分页是指把物理内存分成固定大小的块，每块就是一个页，操作系统以页为单位进行内存的管理。Linux
> 操作系统中，一般页的大小为 4KB，之后又由于一些因素(主要是访问效率、TLB miss等)，出现了更大的页，比较典型的是 2MB 和 1GB
> 大小的大页/巨页 (huge page)。


如果不使用巨页技术，将会带来更高的页表查询开销和 TLB miss 问题。

### 启用

1G 巨页，即让MMU映射1G的内存到虚拟内存中。得到尽可能连续的内存空间，避免或降低查询页表的开销。

```
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
```

### 自动设置

编辑 /etc/default/default 设置如下参数将会把默认巨页设置为 1GB，并且在系统启动时预留 8 个巨页，总共 8GB。这 8G 会按 NUMA
平均分配。

```shell
GRUB_CMDLINE_LINUX_DEFAULT="default_hugepagesz=1G hugepagesz=1G hugepages=8"
update-grub
```

### 挂载

也可以使用 `dpdk-hugepages.py` 管理

```shell
mkdir /mnt/huge
mount -t hugetlbfs pagesize=1GB /mnt/huge
```

自动挂载

```
echo "nodev /mnt/huge hugetlbfs pagesize=1GB 0 0" >> /etc/fstab
```

也可以不指定 pagesize

```shell
mount -t hugetlbfs nodev /mnt/huge
```

### 查询当前操作系统的巨页设置

```shell
cat /proc/meminfo | grep Huge
```

结果如下

```shell
AnonHugePages:         0 kB
ShmemHugePages:     8192 kB
FileHugePages:         0 kB
HugePages_Total:       8
HugePages_Free:        8
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
Hugetlb:         8388608 kB
```

## 编译

本次编译最新的 LTS 版本 23.11.2，最新版代号为 24.07

```shell
curl -LO http://fast.dpdk.org/rel/dpdk-23.11.2.tar.xz
tar xvJf dpdk-23.11.2.tar.xz
```

生成

```shell
cd dpdk-stable-23.11.2
meson setup build
```

构建

```
cd build
ninja
```

安装

*RHEL 在运行 ldconfig 之前，应将 /usr/local/lib 和 /usr/local/lib64 添加到 /etc/ld.so.conf.d/ 中的文件中，因为 /usr/local
中的路径不在加载程序的默认路径*

```
meson install
ldconfig
```

自定义选项

- [compiling-and-installing-dpdk-system-wide](http://doc.dpdk.org/guides/linux_gsg/build_dpdk.html#compiling-and-installing-dpdk-system-wide)

构建 32 位 DPDK（可选）

```
PKG_CONFIG_LIBDIR=/usr/lib/i386-linux-gnu/pkgconfig \
    meson setup -Dc_args='-m32' -Dc_link_args='-m32' build
```

## 编程

如果部署正常，dpdk 将会提供一份 pkg-config 以供使用

```shell
pkg-config --libs --cflags libdpdk
```

程序员指南

- [http://doc.dpdk.org/guides-23.11/prog_guide/index.html](http://doc.dpdk.org/guides-23.11/prog_guide/index.html)

## hello world

main.c

```cpp
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>
#include <sys/queue.h>

#include <rte_memory.h>
#include <rte_launch.h>
#include <rte_eal.h>
#include <rte_per_lcore.h>
#include <rte_lcore.h>
#include <rte_debug.h>

static int lcore_hello(__rte_unused void *arg)
{
    // CPU 核心ID
	unsigned lcore_id = rte_lcore_id();
    // CPU 的物理 socket id，单路 CPU 该值始终为0
    unsigned lcore_socket = rte_socket_id();
	printf("hello from NUMA:%u, Core:%02u\n", lcore_socket, lcore_id);

	return 0;
}

int main(int argc, char **argv)
{
	int ret;
	unsigned lcore_id;

    // 初始化环境抽象层
	ret = rte_eal_init(argc, argv);
	if (ret < 0) {
        rte_panic("Cannot init EAL\n");
    }

	// 在每个核心上启动 lcore_hello
	RTE_LCORE_FOREACH_WORKER(lcore_id) {
		rte_eal_remote_launch(lcore_hello, NULL, lcore_id);
	}

    // 在默认核心上启动 lcore_hello
	lcore_hello(NULL);
	rte_eal_mp_wait_lcore();

	rte_eal_cleanup();
	return 0;
}
```

CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.22.1)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(DPDK-HELLO VERSION 0.1.0 LANGUAGES C)

include_directories(include)
add_executable(${PROJECT_NAME}
    main.c
)

set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "dpdk-helloworld")

find_package(PkgConfig REQUIRED)
pkg_check_modules(PKG_DEPS REQUIRED libdpdk)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PKG_DEPS_LIBRARIES})
target_link_directories(${PROJECT_NAME} PRIVATE ${PKG_DEPS_LIBRARY_DIRS})
target_include_directories(${PROJECT_NAME} PRIVATE ${PKG_DEPS_INCLUDE_DIRS})
```

编译运行

```
CMAKE_BUILD_DIR="build"

cmake -G Ninja -S $(pwd) -B ${CMAKE_BUILD_DIR} \
	-DCMAKE_BUILD_TYPE=Debug \
	-DCMAKE_MAKE_PROGRAM=`which ninja`

cmake --build ${CMAKE_BUILD_DIR} --target all -j `nproc`
${CMAKE_BUILD_DIR}/dpdk-helloworld
```

执行输出

```shell
EAL: Detected CPU lcores: 64
EAL: Detected NUMA nodes: 2
EAL: Detected shared linkage of DPDK
EAL: Multi-process socket /var/run/dpdk/rte/mp_socket
EAL: Selected IOVA mode 'PA'
EAL: VFIO support initialized
TELEMETRY: No legacy callbacks, legacy socket not created
hello from NUMA:1, Core:01
hello from NUMA:0, Core:02
hello from NUMA:1, Core:03
hello from NUMA:0, Core:04
...
hello from NUMA:0, Core:62
hello from NUMA:1, Core:63
hello from NUMA:0, Core:00
```

## 接管网络

上面的示例无需网络，所以不需要接管网卡

### IOMMU

启用 iommu

```
sed -i '|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="iommu=on"|' /etc/default/grub
```

重新生成 grub

```shell
update-grub
```

当 grub 更新完却仍无法生效时，可以观察内核日志排除故障。

例如使用 `dmesg | grep -i -e DMAR -e IOMMU` 命令可以看到 IOMMU 配置被 BIOS 锁定，需要通过配置 intremap=no_x2apic_optout
内核启动参数覆盖 BIOS 设置

```shell
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-5.15.0-116-generic root=/dev/mapper/ubuntu--vg-ubuntu--lv ro iommu=on
[    0.010905] ACPI: DMAR 0x000000007BAFE000 0000F0 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.010947] ACPI: Reserving DMAR table memory at [mem 0x7bafe000-0x7bafe0ef]
[    0.497301] Kernel command line: BOOT_IMAGE=/vmlinuz-5.15.0-116-generic root=/dev/mapper/ubuntu--vg-ubuntu--lv ro iommu=on
[    0.954277] DMAR: Host address width 46
[    0.954280] DMAR: DRHD base: 0x000000fbffc000 flags: 0x0
[    0.954288] DMAR: dmar0: reg_base_addr fbffc000 ver 1:0 cap 8d2078c106f0466 ecap f020df
[    0.954293] DMAR: DRHD base: 0x000000c7ffc000 flags: 0x1
[    0.954298] DMAR: dmar1: reg_base_addr c7ffc000 ver 1:0 cap 8d2078c106f0466 ecap f020df
[    0.954302] DMAR: ATSR flags: 0x0
[    0.954305] DMAR: ATSR flags: 0x0
[    0.954308] DMAR-IR: IOAPIC id 10 under DRHD base  0xfbffc000 IOMMU 0
[    0.954311] DMAR-IR: IOAPIC id 8 under DRHD base  0xc7ffc000 IOMMU 1
[    0.954314] DMAR-IR: IOAPIC id 9 under DRHD base  0xc7ffc000 IOMMU 1
[    0.954317] DMAR-IR: HPET id 0 under DRHD base 0xc7ffc000
[    0.954319] DMAR-IR: x2apic is disabled because BIOS sets x2apic opt out bit.
[    0.954320] DMAR-IR: Use 'intremap=no_x2apic_optout' to override the BIOS setting.
[    0.955140] DMAR-IR: Enabled IRQ remapping in xapic mode
[    1.716423] iommu: Default domain type: Translated
[    1.716423] iommu: DMA domain TLB invalidation policy: lazy mode
```

如果还是不行，可以尝试更新 BIOS

### VFIO

加载 vfio 驱动

```shell
modprobe vfio-pci
```

no-IOMMU

vfio 依赖 IOMMU，如果执行 `cat /boot/config-$(uname -r) | grep NOIOMMU` 的输出类似如下，则可以启用 no-IOMMU 模式，否则只能更换成
uio/ixgbe 等

```
CONFIG_VFIO_NOIOMMU=y
```

配置 noiommu

```
modprobe vfio enable_unsafe_noiommu_mode=1
echo 1 > /sys/module/vfio/parameters/enable_unsafe_noiommu_mode
```

### ixgbe

```shell
modprobe ixgbe
```

其他

- http://doc.dpdk.org/guides/linux_gsg/linux_drivers.html

### 接口必要配置

运行 `dpdk-devbind.py --status-dev net` 查看设备绑定状态

```shell
Network devices using kernel driver
===================================
0000:01:00.0 'I350 Gigabit Network Connection 1521' if=eno1 drv=igb unused=vfio-pci *Active*
0000:01:00.1 'I350 Gigabit Network Connection 1521' if=eno2 drv=igb unused=vfio-pci *Active*
0000:01:00.2 'I350 Gigabit Network Connection 1521' if=eno3 drv=igb unused=vfio-pci *Active*
0000:01:00.3 'I350 Gigabit Network Connection 1521' if=eno4 drv=igb unused=vfio-pci
```

在此计划绑定 eno3

**如果要使用 dpdk，则必须保证网卡的状态是 down。**

```shell
ip link set eno3 down
```

再次检查发现 eno3(0000:01:00.2) 已经离开 kernel driver 控制了

```
Network devices using kernel driver
===================================
0000:01:00.0 'I350 Gigabit Network Connection 1521' if=eno1 drv=igb unused=vfio-pci *Active*
0000:01:00.1 'I350 Gigabit Network Connection 1521' if=eno2 drv=igb unused=vfio-pci *Active*
0000:01:00.3 'I350 Gigabit Network Connection 1521' if=eno4 drv=igb unused=vfio-pci

Other Network devices
=====================
0000:01:00.2 'I350 Gigabit Network Connection 1521' unused=igb,vfio-pci
```

### 接管 eno3

如果使用 ixgbe 则改为 `--bind=ixgbe`

```shell
dpdk-devbind.py --bind=vfio-pci eno3
```

或使用 bus:slot.func 号绑定

```shell
dpdk-devbind.py --bind=vfio-pci 0000:01:00.2
```

再次查看 devbind 发现 eno3(0000:01:00.2) 已经被 DPDK 接管

```shell
Network devices using DPDK-compatible driver
============================================
0000:01:00.2 'I350 Gigabit Network Connection 1521' drv=vfio-pci unused=igb

Network devices using kernel driver
===================================
0000:01:00.0 'I350 Gigabit Network Connection 1521' if=eno1 drv=igb unused=vfio-pci *Active*
0000:01:00.1 'I350 Gigabit Network Connection 1521' if=eno2 drv=igb unused=vfio-pci *Active*
0000:01:00.3 'I350 Gigabit Network Connection 1521' if=eno4 drv=igb unused=vfio-pci
```

打印设备当前的驱动程序 `ls -l "/sys/bus/pci/devices/0000:01:00.2/driver"`

内核管理时输出

```
lrwxrwxrwx 1 root root 0 Oct  8 07:54 /sys/bus/pci/devices/0000:01:00.2/driver -> ../../../../bus/pci/drivers/igc
```

DPDK 管理时输出

```
lrwxrwxrwx 1 root root 0 Oct  8 08:22 /sys/bus/pci/devices/0000:01:00.2/driver -> ../../../../bus/pci/drivers/vfio-pci
```

查看设备管理的物理内存资源 `cat "/sys/bus/pci/devices/0000:01:00.2/resource"`

```shell
0x0000000080b00000 0x0000000080bfffff 0x0000000000040200
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000080c00000 0x0000000080c03fff 0x0000000000040200
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000080a00000 0x0000000080afffff 0x0000000000046200
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
```

## `examples/ethtool`

ethtool 是一个较为复杂的涉及网卡的 dpdk 的官方示例，一定程度上可以了解 dpdk 的使用和验证 dpdk 安装是否正确

编译

```shell
cd examples/ethtool
make all
```

```shell
LD_LIBRARY_PATH="$(pwd)/lib/build:$LD_LIBRARY_PATH" ethtool-app/build/ethtool
```

运行结果

```
# ethtool-app/build/ethtool
EAL: Detected CPU lcores: 64
EAL: Detected NUMA nodes: 2
EAL: Detected shared linkage of DPDK
EAL: Multi-process socket /var/run/dpdk/rte/mp_socket
EAL: Selected IOVA mode 'PA'
EAL: No free 1048576 kB hugepages reported on node 0
EAL: No free 1048576 kB hugepages reported on node 1
EAL: VFIO support initialized
EAL: Using IOMMU type 8 (No-IOMMU)
EAL: Probe PCI driver: net_e1000_igb (8086:1521) device: 0000:01:00.2 (socket 0)
TELEMETRY: No legacy callbacks, legacy socket not created
Number of NICs: 1
Init port 0..
EthApp> drvinfo
Port 0 driver: net_e1000_igb (ver: DPDK 23.11.2)
firmware-version: 1.67, 0x80000b97, 15.0.28
bus-info: 0000:01:00.2
EthApp>
```

如果出现如下错误，则检查 IOMMU 配置

```
...
EAL: Error - exiting with code: 1
  Cause: No available NIC ports!
```

## 总结

最小化的 DPDK 网络程序的配置要求如下

1. ldconfig
2. hugepage
3. vfio / vfio-nonIOMMU
4. devbind

简单的配置脚本

```shell
#!/bin/bash

set -ex

# hugepages
echo 1024 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
mkdir /mnt/huge || true
mount -t hugetlbfs pagesize=1GB /mnt/huge
dmesg | grep 'hugetlbfs: Unsupported'
[[ $? == 1 ]] && exit 1

# vfio on no-IOMMU
modprobe vfio-pci
modprobe vfio enable_unsafe_noiommu_mode=1
echo 1 >/sys/module/vfio/parameters/enable_unsafe_noiommu_mode

# bind-dev
for interface in `echo ens16 ens20 ens21`; do
    portid=$(dpdk-devbind.py --status-dev net | grep "$interface" | cut -d ' ' -f 1)

    ip link set "$interface" down || true
    dpdk-devbind.py -u "$portid"
    dpdk-devbind.py --bind=vfio-pci "$portid"
    cat "/sys/bus/pci/devices/$portid/driver"
done

dpdk-devbind.py --status-dev net
```

## EAL

硬件抽象层

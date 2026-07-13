---
display-name: 易用的网络性能测试工具 iperf3
date: 2019-09-30 11:38:19
tags: [ "Linux" ]
---

> iperf3是一款优秀的网络性能测试工具，支持 udp 和 tcp 等方式进行测试，可工作在内网与公网中。

## 实验环境

| 类型 | 网卡  | 带宽  |
| ------------ | ------------  | ------------ |
| 无线网络 |  wifi1 |  百兆以上  |
| 无线网络 |  wifi2 | 1Gb  |
| 本机 | 127.0.0.1 | 至少 1Gb  |
| 内网工作站 | 192.168.20.4 | 至少为 1Gb  |

### 服务器

在内网工作站中启动 iperf3 的 server 端

- 参数 -i 为每隔若干秒打印一次报告，这里设置为 5 秒
- 参数 -p 为端口

```shell 
$ iperf3 -s -i 5
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```

### 测试方法

- 参数：-c 服务器地址 -b 网卡带宽 -n 数据包大小 -i 报告打印时间 -u 使用tcp协议测试 -p 端口

#### 传输指定大小的包

> 实验参数：设置网卡为千兆，传输 1Gb 数据

注：网络测试中一般采用 udp ，因为可以测出网络极限

- ifi1 百兆以上 tcp

```shell
$ iperf3 -c 192.168.20.4 -b 1000M -n 1G 
  ... 
  [  5] 950.00-950.21 sec   382 KBytes  14.8 Mbits/sec
  - - - - - - - - - - - - - - - - - - - - - - - - -
  [ ID] Interval           Transfer     Bitrate
  [  5]   0.00-950.21 sec  1.00 GBytes  9.04 Mbits/sec                  sender
  [  5]   0.00-950.21 sec  1024 MBytes  9.04 Mbits/sec                  receiver
  
  iperf Done.
```

下载网速基本是 10M ，算下来顶多 130M 带宽，符合百兆以上的带宽速度。因为 tcp 为了包的完整性牺牲了大量的性能，以他的结果为网卡的物理极限不太准确，我们来看看 udp 的

- wifi1 百兆以上 udp

```shell
$ iperf3 -c 192.168.20.4 -b 1000M -n 1G -u
  ... 
  [  5]  46.00-47.00  sec  0.00 Bytes  0.00 bits/sec  0
  [  5]  47.00-47.18  sec  17.6 MBytes   811 Mbits/sec  13197
  - - - - - - - - - - - - - - - - - - - - - - - - -
  [ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
  [  5]   0.00-47.18  sec  1.00 GBytes   182 Mbits/sec  0.000 ms  0/766981 (0%)  sender
  [  5]   0.00-47.18  sec  64.0 MBytes  11.4 Mbits/sec  0.414 ms  717059/764958 (94%)  receiver
  
  iperf Done.
```

下载网速基本 12M ，算下来顶多 150M 带宽，符合百兆以上的带宽速度。

### 千兆网络

- wifi2 1Gb udp

```shell
$ iperf3 -c 192.168.20.4 -b 1000M -n 1G -u
  ... 
  [  5]   8.00-8.64   sec  78.8 MBytes  1.03 Gbits/sec  57050
  - - - - - - - - - - - - - - - - - - - - - - - - -
  [ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
  [  5]   0.00-8.64   sec  1.00 GBytes   994 Mbits/sec  0.000 ms  0/741555 (0%)  sender
  [  5]   0.00-8.64   sec  92.1 MBytes  89.4 Mbits/sec  0.114 ms  674860/741555 (91%)  receiver
  
  iperf Done.
```

下载速度 90M , 算下来 700M 左右，基本符合千兆的带宽速度。

- wifi2 1Gb tcp

```shell
$ iperf3 -c 192.168.20.4 -b 1000M -n 1G -u
  ... 
  [  5]  92.00-92.49  sec  5.52 MBytes  94.4 Mbits/sec
  - - - - - - - - - - - - - - - - - - - - - - - - -
  [ ID] Interval           Transfer     Bitrate
  [  5]   0.00-92.49  sec  1.00 GBytes  92.9 Mbits/sec                  sender
  [  5]   0.00-92.49  sec  1023 MBytes  92.8 Mbits/sec                  receiver
  
  iperf Done.
```

下载速度 90M+ , 算下来 730M 左右，性能居然优于 udp ，看来网络稳定性也是影响性能的一个大因素，也符合千兆的带宽速度。

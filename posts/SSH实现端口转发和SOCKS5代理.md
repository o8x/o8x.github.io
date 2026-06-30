---
display-name: SSH实现端口转发和SOCKS5代理
date: 2022-06-24 13:54:50
categories:
- Linux
tags:

- Linux

---

## 公用参数

- -v verbose
- -f 后台运行
- -N 连接后不打开 shell
- -C 压缩转发的数据
- -q 静默模式

## 本地转发到远程

将请求从本地端口转发到ssh服务器，然后再发到远程服务器

示例：将本地 35689 端口的请求经过 root@example.com 转发到 test.com:22

```
ssh -fqNC -L localhost:35689:test.com:22 root@example.com
```

*注：localhost: 可省略*

### 使用方法

```shell
ssh root@localhost -p 35689
```

## 远程转发到本地

在远程监听端口，所有数据都会通过ssh转发到本地端口，可以通过公网IP直接访问到本地的应用

示例：将远程 example.com 上的 35689 端口的所有请求转发到本地的 5690 端口

```
ssh -fqNC -R localhost:35689:localhost:5690 root@example.com
```

*注：localhost: 可省略*

### 使用方法

本地监听 5690 端口并 Read 数据，以 nc 为例

```shell
nc -tl localhost 5690
```

请求远程的 35689 端口

```shell
ssh root@example.com "curl localhost:35689"
```

```shell
curl example.com:35689
```

## SOCKS5透明代理

将本地 35689 端口的所有请求都转发到 example.com 处理，实现透明代理

```shell
ssh -fqNC -D 35689 root@example.com
```

### 使用方法

curl

```shell
curl -x socks5://127.0.0.1:35689 https://myip.ipip.net
```

git

```shell
git config http.proxy socks5://127.0.0.1:35689
git config https.proxy socks5://127.0.0.1:35689
```

设置为系统代理，让所有本地流量都通过代理转发

```shell
export all_proxy=socks5://127.0.0.1:35689
```

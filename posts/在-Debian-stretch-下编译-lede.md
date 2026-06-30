---
display-name: 在 Debian 9.x(stretch) 下编译 Lede
date: 2022-06-22 10:16:16
tags:

- OpenWRT
- Linux

---

### 下载源码

```shell
git clone https://github.com/coolsnowwolf/lede
```

或

```shell
git clone -b openwrt-18.06 https://github.com/openwrt/openwrt.git
```

### Shortcut FE

```
make kernel_menuconfig
[*] Enables kernel network stack path for Shortcut Forwarding Engine
```

或修改配置文件 .config

```ini
CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE = y
```

### 编译依赖

加入 sid 源

```shell
echo 'deb http://mirrors.tencent.com/debian sid main contrib non-free' >> /etc/apt/sources.list 
apt update
```

安装依赖

```shell
apt -y install \
    build-essential asciidoc binutils bzip2 gawk gettext git \
    libncurses5-dev libz-dev patch python3.5 unzip zlib1g-dev \
    lib32gcc1 libc6-dev-i386 subversion flex uglifyjs p7zip \
    p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto \
    qemu-utils upx libelf-dev autoconf automake libtool \
    autopoint device-tree-compiler linux-libc-dev gcc-11 rsync bc mkisofs
```

### Feeds

```shell
./scripts/feeds update -a ./scripts/feeds install -a make menuconfig
```

### 开始编译

非 root 用户

```shell
make -j $(nproc) V=s
```

root 用户

```shell
export FORCE_UNSAFE_CONFIGURE=1 && make -j $(nproc) V=s
```

打印详细的错误信息

```shell
make V=99
```

忽略HASH检查

```shell
make PKG_HASH=skip
```

### [可选] 设置内核版本为 5.4

修改 target/linux/x86/Makefile 设置内核版本为 5.4

```makefile
KERNEL_PATCHVER := 5.4
KERNEL_TESTING_PATCHVER := 5.4
```

回退到 87e2f2 以避免部分编译错误

```
git reset --hard 87e2f2912806ab7d8cc5dd90fd3069f1ff9c5fcb
```

### [可选] 提前下载依赖

```shell
make download 
```

### 增加 Feed 的方法

[https://openwrt.org/docs/guide-developer/helloworld/chapter4](https://openwrt.org/docs/guide-developer/helloworld/chapter4)

```shell
cp feeds.conf.default feeds.conf
echo "src-git feedname https://github.com/feedname/feedname" >> feeds.conf
```

## 其他

### 禁用文件系统检查

编辑 `include/prereq-build.mk`

```shell 
# $(eval $(call TestHostCommand,case-sensitive-fs, \
#	OpenWrt can only be built on a case-sensitive filesystem, \
#	rm -f $(TMP_DIR)/test.*; touch $(TMP_DIR)/test.fs; \
#		test ! -f $(TMP_DIR)/test.FS))
```

### 忽略git的SSL验证

```shell
export GIT_SSL_NO_VERIFY=1
```

或

```shell
git config --global http.sslVerify false
```

export http_proxy=socks5://127.0.0.1:30801 \
https_proxy=socks5://127.0.0.1:30801 \
all_proxy=socks5://127.0.0.1:30801

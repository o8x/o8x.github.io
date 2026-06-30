---
display-name: 使用SCL升级 gcc 版本
date: 2022-06-16 14:24:55
tags:

- Linux

---

## 安装SCL源

```shell
yum install centos-release-scl scl-utils-build
```

列出 SCL 可用源：

```shell
yum list all --enablerepo=centos-sclo-rh | grep devtoolset
```

安装对应版本的 GCC

```shell
yum install devtoolset-9-toolchain
```

切换到刚安装的 GCC 9 环境

```shell
scl enable devtoolset-9 bash
```

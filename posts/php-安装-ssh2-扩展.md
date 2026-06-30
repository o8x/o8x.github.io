---
display-name: php 安装 ssh2 扩展
date: 2018-12-07 09:52:44
tags:

- Linux
- php

---

# 安装

### 下载组件包

```bash
# libssh
wget http://www.libssh2.org/download/libssh2-1.4.2.tar.gz

# ssh2 扩展
wget http://pecl.php.net/get/ssh2-1.1.2.tgz
```

### 安装 libssh

```bash
tar -zxvf libssh2-1.4.2.tar.gz
cd libssh2-1.4.2
./configure --prefix=/opt/libssh2
make && make install
```

### 编译安装 ssh2

```bash
tar -zxvf ssh2-0.12.tgz
cd ssh2-0.12
/www/server/php/70/bin/phpize
./configure \
    --prefix=/opt/ssh2 \
    --with-ssh2=/usr/local/libssh2 \
    --with-php-config=/www/server/php/70/bin/php-config
make && make install
```

### 让配置生效

```bash
echo "extension=/www/server/php/70/lib/php/extensions/no-debug-non-zts-20151012/ssh2.so" >> /www/server/php/70/etc/php.ini
```

#### 重启php-fpm

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/12/950d844e6ef816629e2356dc60bd4fcf.png)

## windows

### 下载扩展

到 [pecl](http://pecl.php.net/package/ssh2/1.1.2/windows) 下载你对应版本的 扩展dll

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/12/ad46656aaac7de5a0c49d5c3abdbe1f1.png)

注意 TS 和 NTS 对应 phpinfo() 中的 PHP Extension Build 项

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/12/7f578a4d7db4c2a8c5085bffa89097b9.png)

### 安装

> 解压下载的文件 , 把 php_ssh2.dll 和 php_ssh2.pdb 放到 /php/ext/中 ,然后向/php/php.ini 最后加入

```ini
[ssh2]
extension = "C:\$PATH\php\ext\php_ssh2.dll"
```

#### 重启php

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/12/7d4b9e5c4a80b9136514c8dec78797cd.png)

# 大功告成

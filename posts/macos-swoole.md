---
display-name: macos 本地安装 swoole  
date: 2023-08-18 14:38:47
categories:

- php

tags:

- php

---

## 安装 php7.4

```shell
brew install shivammathur/php/php@7.4
```

### 注入环境变量

```shell
cat > ~/.zshrc <<EOF
export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/php@7.4/lib"
export CPPFLAGS="-I/opt/homebrew/opt/php@7.4/include"
EOF 
```

## 安装 composer

```shell
wget https://mirrors.ustc.edu.cn/homebrew-bottles/composer-2.5.8.arm64_ventura.bottle.tar.gz
tar xzvf composer-2.5.8.arm64_ventura.bottle.tar.gz cp composer/2.5.8/bin/composer /opt/homebrew/bin
```

## 安装 swoole

下载源码并解压

```shell
curl -L -O https://pecl.php.net/get/swoole-4.8.13.tgz
tar xzvf swoole-4.8.13.tgz
cd swoole-4.8.13
```

编译安装 swoole

```安装
phpize && \ 
./configure \
	--enable-openssl \
	--enable-sockets \
	--enable-mysqlnd \
	--enable-swoole-curl \
	--enable-http2 \
	--with-openssl-dir=/opt/homebrew/Cellar/openssl@3/3.0.8
make && make install
```

解决 swoole 无法找到 pcre2.h

```shell
ln -s /opt/homebrew/Cellar/pcre2/10.42/include/pcre2.h /opt/homebrew/opt/php@7.4/include/php/ext/pcre/pcre2.h
```

启用 swoole

```shell
cat >/opt/homebrew/etc/php/7.4/php.ini <<EOF
extension=swoole.so
swoole.use_shortname='Off'
EOF
```

验证验证是否成功

```shell
php -m | grep swoole
```

## 安装 redis 扩展

```shell
pecl install redis
```

## YASD

### 安装依赖

最高 1.76

```shell
brew install boost@1.76 
```

如果找不到 boost 依赖

```shell
sudo ln -s /opt/homebrew/Cellar/boost@1.76/1.76.0_4/include/boost /usr/local/include/boost
sudo ln -sf /opt/homebrew/Cellar/boost@1.76/1.76.0_4/lib/libboost_filesystem.dylib /usr/local/lib
```

### 编译安装

```shell
git clone https://github.com/swoole/yasd.git
```

```shell
phpize --clean && \
	phpize && \
	./configure && \
	make clean && \
	make && \
	make install
```

### 配置

```shell
cat >> /opt/homebrew/etc/php/7.4/php.ini <<EOF
zend_extension=yasd
yasd.debug_mode=remote
yasd.remote_host=127.0.0.1
yasd.remote_port=9000
EOF  
```

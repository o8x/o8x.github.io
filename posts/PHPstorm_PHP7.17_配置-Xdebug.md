---
display-name: PHPstorm + PHP7.17 配置调试器Xdebug
date: 2017-08-26 11:54:26
tags:

- php
- xdebug

---

### 下载

选择适合自己的版本进行下载

[https://xdebug.org/download.php](https://xdebug.org/download.php)

### 编译

```shell
$ tar xzvf xdebug.tag.gz
$ cd xdebug
$ phpize
$ ./configure --with-php-config=/path 
$ make && make install
```

### 配置

#### php.ini

**是 `zend_extension`，不是 `extension`**

```ini
[XDebug]
xdebug.profiler_append = 0
xdebug.profiler_enable = 1
xdebug.profiler_enable_trigger = 0
xdebug.profiler_output_dir = /tmp
xdebug.trace_output_dir = /tmp
xdebug.profiler_output_name = "cache.out.%t-%s"
xdebug.remote_enable = 1
xdebug.remote_handler = "dbgp"
xdebug.remote_host = "127.0.0.1"
; xdebug.remote_port = "80"
xdebug.idekey = "PHPSTORM"
zend_extension = "/path/xdebug.so" 
```

#### 重启 php-fpm

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2017/08/2017-08-26-11-35-06-的屏幕截图.png)

#### 配置 phpstorm

参考:[http://www.cnblogs.com/xujian2016/p/5548921.html](http://www.cnblogs.com/xujian2016/p/5548921.html)

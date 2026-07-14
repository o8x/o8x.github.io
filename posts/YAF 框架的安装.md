---
display-name: YAF 框架的安装
date: 2017-08-06 19:07:39
tags: ["php"]
---

> Yaf 源码下载 ：http://pecl.php.net/package/yaf

*安装依赖*

```shell
$ sudo apt-get install gcc gcc-c++ make automake autoconf
```

*编译*

```shell
$ phpize 
$ ./configure --with-php-config=/opt/lnmp/php/</span>bin/php-config 
$ make && make install
```

*在php.ini加入*

```ini
extension_dir = "扩展所在目录[绝对路径 | 相对路径]"
extension = yaf.so

[yaf]
yaf.environ = product
yaf.library = NULL
yaf.cache_config = 0
yaf.name_suffix = 1
yaf.name_separator = ""
yaf.forward_limit = 5
yaf.use_namespace = 0
yaf.use_spl_autoload = 0
```

*参考资料*

- https://segmentfault.com/a/1190000000655886

---
display-name: 简单的通过yum安装和配置LNMP环境
date: 2018-08-20 10:50:28
tags:

- Linux

---

### Nginx

```shell
$ yum install nginx
```

修改 /etc/nginx/nginx.conf 文件为如下内容：

```nginx 
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        server_name  127.0.0.1;
        root         /var/www/html/public;
        index index.php index.html
        error_page  404              /404.html;
        location = /40x.html {
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
        }
        location ~ .php$ {
            root           /var/www/html/public;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }
        location ~ /.ht {
            deny all;
        }
    }
}
```

#### 启动 Nginx 并设置为开机启动：

```shell 
service nginx start
chkconfig nginx on
```

### PHP

#### php-cli

```shell 
yum install php php-gd php-fpm php-mcrypt php-mbstring php-mysql php-pdo
```

##### 安装源

```shell 
yum install -y epel-release
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum update -y
```

#### 新版 php-fpm

```shell 
yum install -y --enablerepo=remi --enablerepo=remi-php72 php php-devel php-mbstring php-mcrypt php-mysqlnd php-pdo php-gd php-fpm
```

#### 启动 php-fpm 并设置为开机启动：

```shell 
service php-fpm start
chkconfig php-fpm on
```

### mysql 5.7

```shell 
yum -y install http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
yum -y install mysql mysql-server
```

#### 启动

```shell 
systemctl start mysqld
```

#### 设置开机启动

```shell 
systemctl enable mysqld
systemctl daemon-reload
```

#### 修改 mysql root 登录密码

```shell 
grep 'temporary password' /var/log/mysqld.log

mysql -uroot -p 
> 输入你看到的密码
> set password for 'root'@'localhost'=password('123456!'); 
> # 添加远程用户
> GRANT ALL PRIVILEGES ON *.* TO 'remote-user'@'%' IDENTIFIED BY 'password!' WITH GRANT OPTION;
```

### composer

> Composer 是 PHP 的一个依赖管理工具，推荐使用 Composer 创建 ShowDoc 项目。

```shell 
curl -sS https://getcomposer.org/installer | php
mv composer.phar /sbin/composer
```

#### 配置中国镜像

```shell 
composer config -g repo.packagist composer https://packagist.phpcomposer.com
```

#### 创建一个项目 , 以laravel为例

```shell 
cd /var/www/html/ &amp;&amp; composer create-project  laravel/laravel
```

#### 为目录授权

```shell 
chmod -R a+w ./ || chmod -R 755 ./
```

### 清理yum缓存：

```shell 
yum clean all
rm -rf /var/cache/yum

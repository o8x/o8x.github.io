---
display-name: nginx 配置 letsencrypt 并自动续期
date: 2020-05-26 20:57:42
tags: ["Linux"]
---



**Let's Encrypt**是为了推动 https 普及而成立的组织，由Mozilla、Cisco、Akamai、IdenTrust、EFF等组织发起，用户可以简单的使用其签发DV级的CA证书用以将自己的网站转换为 https。

> 值得注意的是*Let's Encrypt*每次签发的证书，有效期均为90天，但可以无限次免费续期。

**安装**

```shell
$ git clone https://github.com/letsencrypt/letsencrypt
```

**签发**

> 签发过程中先暂时关闭 nginx 等 web server，否则`letsencrypt`无法使用80端口
>
>   -d 域名参数，理论上可以无限追加

```shell
$ cd letsencrypt
$ ./letsencrypt-auto certonly --standalone --email im@stdout.com.com \
  -d stdout.com.com \
  -d cdn.stdout.com.com \ 
  -d url.stdout.com.com
```

### 部署

*自动部署*

```shell
$ cd letsencrypt
$ ./letsencrypt-auto
```

**手动部署**

> 证书存放位置：/etc/letsencrypt/live/

*nginx*

> 简单的将这4行添加到你的网站的 server 段内即可

```nginx
ssl_certificate /etc/letsencrypt/live/stdout.com.com/fullchain.pem; #
ssl_certificate_key /etc/letsencrypt/live/stdout.com.com/privkey.pem; #
include /etc/letsencrypt/options-ssl-nginx.conf;
ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
```

以 stdout.com.com 为例

```nginx
# /etc/nginx/nginx.conf

server {
      # http2 参数可以为网站提供 http2
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    server_name stdout.com.com;
    index index.html;
    root /var/html/;

    ssl_certificate /etc/letsencrypt/live/stdout.com.com/fullchain.pem; #
    ssl_certificate_key /etc/letsencrypt/live/stdout.com.com/privkey.pem; #
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
```

*httpd*

> 未经验证

```xml

<VirtualHost *:443>
        SSLEngine on
        SSLProxyEngine On
        SSLProxyVerify none
        ServerName stdout.com.com
        SSLCertificateFile /etc/letsencrypt/live/stdout.com.com/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/stdout.com.com/privkey.pem
        </VirtualHost>
```

### 强制 https

> 监听80端口，直接301跳转到https站点即可

```nginx
server {
    listen 80;
    server_name stdout.com.com;
    return 301 https://stdout.com.com$request_uri;
}
```

**验证**

> 参考 [使用CURL跟踪链接，并打印头信息](https://stdout.com.com/url/MjY=)

```shell
➜ curl -I -L http://stdout.com.com
HTTP/1.1 301 Moved Permanently
Server: nginx/1.14.1
Date: Tue, 09 Jun 2020 03:21:15 GMT
Content-Type: text/html
Content-Length: 185
Connection: keep-alive
Location: https://stdout.com.com/

HTTP/2 200
server: nginx/1.14.1
date: Tue, 09 Jun 2020 03:21:16 GMT
content-type: text/html
content-length: 11445
last-modified: Mon, 08 Jun 2020 10:02:20 GMT
vary: Accept-Encoding
etag: "5ede0cac-2cb5"
accept-ranges: bytes
```

第一次请求出现 301，可见 https 和 http2 都配置成功了


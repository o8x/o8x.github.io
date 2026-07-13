---
display-name: nginx 开启强制 https
date: 2018-06-14 22:27:30
tags: [ "Linux" ]
---

### HSTS

> HTTP严格传输安全协议（英语：HTTP Strict Transport
> Security，简称：HSTS），是一套由互联网工程任务组发布的互联网安全策略机制。网站可以选择使用HSTS策略，来让浏览器强制使用HTTPS与网站进行通信，以减少会话劫持风险。其征求修正意见书文件编号是RFC
> 6797，发布于2012年11月。

### 内容

>
HSTS的作用是强制客户端（如浏览器）使用HTTPS与服务器创建连接。服务器开启HSTS的方法是，当客户端通过HTTPS发出请求时，在服务器返回的超文本传输协议（HTTP）响应头中包含Strict-Transport-Security字段。非加密传输时设置的HSTS字段无效。
比如，https://example.com/ 的响应头含有Strict-Transport-Security: max-age=31536000; includeSubDomains。这意味着两点：
在接下来的31536000秒（即一年）中，浏览器向example.com或其子域名发送HTTP请求时，必须采用HTTPS来发起连接。比如，用户点击超链接或在地址栏输入 http://www.example.com/ ，浏览器应当自动将
http 转写成 https，然后直接向 https://www.example.com/ 发送请求。
在接下来的一年中，如果 example.com 服务器发送的TLS证书无效，用户不能忽略浏览器警告继续访问网站。

### nginx 实现

> `add_header`

```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name stdout.com.com www.stdout.com.com;
    index index.html;
   
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    ssl_certificate /etc/letsencrypt/live/stdout.com.com-0004/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/stdout.com.com-0004/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
```

强制跳转 HTTPS

```nginx
server {
    listen 80;

    return 301 https://$server_name$request_uri;
}
```

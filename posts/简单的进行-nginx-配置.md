---
display-name: 简单的进行 nginx 配置
draft: false
date: 2020-05-27 20:25:21
tags:

- nginx

---

### Nginx

> Nginx 是一个高性能的HTTP和反向代理web服务器，同时也提供了IMAP/POP3/SMTP服务。第一个公开版本发布于2004年10月4日。其源代码以类BSD许可证的形式发布，因稳定性、丰富的功能，低系统资源的消耗而闻名

### 一份简单的 Nginx 配置文件

```nginx
# nginx 以哪个用户启动
user nginx;

# worker 进程数量，默认为自动。建议设置为实际机器的CPU核心数量
worker_processes auto;

# 错误日志存储位置
error_log /var/log/nginx/error.log;

# 主 nginx 进程ID存储位置
pid /run/nginx.pid;

# 将目录中的文件，加载到此处
include /usr/share/nginx/modules/*.conf;

events {
  # 每个 worker 同时的最大连接数
  worker_connections 1024;
}

# http 协议，也可以是 tcp udp 等
http {
  # 日志格式
  log_format main '$remote_addr - $remote_user [$time_local] "$request" ''$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';

  # 访问日志存储位置
  access_log /var/log/nginx/access.log main;

  # 减少网络传输的步骤切换和拷贝，提高性能
  sendfile on;

  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 2048;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  # 监听
  server {
    listen 80;
    server_name code.stdout.com.com;
    # 路由正则被匹配后，则会进入该段
    location ^~ / {
      # 反向代理到其他地址
      proxy_pass https://127.0.0.1:8080$request_uri;
    }
  }

  server {
    # 监听80端口
    listen 80;
    # 直接响应到443去，即强制https
    return 301 https://stdout.com.com$request_uri;
  }

  server {
    # 监听443端口，并启用http3
    listen 443 ssl http2 default_server;
    # 启用http并设置为默认虚拟，即直接访问ip时，加载本虚拟主机
    listen [::]:443 ssl http2 default_server;
    # 本虚拟主机的域名
    server_name stdout.com.com alex.stdout.com.com www.stdout.com.com;
    # 本虚拟主机的默认文件，即直接访问目录时，默认加载的文件
    index index.html;
    # 本监听的网站根目录
    root /opt/alex-tech/public;

    # 使用gzip压缩网络传输内容提及，借此提高性能
    gzip on;
    gzip_buffers 32 4K;
    gzip_comp_level 6;
    gzip_min_length 100;
    # 对哪些类型的文件使用 gzip
    gzip_types application/javascript text/css text/xml;
    gzip_vary on;

    # 符合正则的将会被反向代理
    location ^~ /url/ {
      proxy_pass http://127.0.0.1:7001$request_uri;
    }

    # 对某些扩展名的文件配置缓存，不再从新请求
    location ~ .*\.(ico|js|css|png|jpg|jpeg|pdf)$ {
      expires 168h;
    }

    # ssl 配置
    ssl_certificate /etc/letsencrypt/live/stdout.com.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/stdout.com.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    # 设置各种状态码时的错误页面，可以是文件也可以是链接
    error_page 400 401 403 404 https://stdout.com.com/404.html;
    error_page 500 502 503 504 https://stdout.com.com/500.html;
  }
}
```


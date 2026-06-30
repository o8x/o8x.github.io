---
display-name: nginx 开启强制 https
date: 2018-06-14 22:27:30
tags:

- nginx

---

> 为80端口的http站点添加如下的语句即可强制HTTPS
> return 301 https://$server_name$request_uri

### 全文如下

```nginx
server {
    listen 80;

    return 301 https://$server_name$request_uri;
}
```

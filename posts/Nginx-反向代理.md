---
display-name: Nginx 反向代理
date: 2018-06-12 23:24:52
tags:  
- nginx
---

### 例如把 `https://site.com/api/*` 代理到 `https://api.site.com/api/*` 中

> 也就是让api全部走api子站

```nginx
server {
    listen 80;
    server_name site.com www.site.com;
    index index.html;
    root /www/wwwroot/site.com;
   
    location /api/ {   
        proxy_pass https://api.site.com;
    }
}
```

-----------------------------

### proxy_pass xxx/ 和 proxy_pass xxx 的差别

> 看起来就是 一个末尾加 / ，一个不加 , 但是实际效果天差地别

**举个栗子**

> 如果访问 https://site.com/api/users/getUserInfo
> 加 / 会代理到 https://api.site.com/users/getUserInfo
> 不加 会代理到 https://site.com/api/users/getUserInfo

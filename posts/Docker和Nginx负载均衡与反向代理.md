---
display-name: Nginx 负载均衡 与 反向代理
date: 2017-08-14 16:46:02
tags: ["Linux"]
---

## 负载均衡

*几种负载均衡算法*

| 算法     | 解释                                           |
| -------- | ---------------------------------------------- |
| 加权轮训 | 根据用户自定义权重，来挑选 worker 进程处理请求 |
| fair     | 只能判断各个worker的繁忙程度，选择压力最小的   |
| 轮训     | 随机挑选一个worker进程处理请求                 |

*server配置*

```nginx
server{
    server{        
    listen8001;    #该虚拟主机监听的端口
    server_name 127.0.0.1:8001;            #监听的域名和上一行设置的端口

    upstream 127.0.0.1 {
      ip_hash;#轮训算法
      
      #所有供给负载均衡的机器的ip与端口
      #weight 为权重值，数字越大权重越大
      server127.0.0.1:32775 weight=1;  
      server127.0.0.1:32776 weight=5;
      server127.0.0.1:32777 weight=4;  
    }
}
```

## 反向代理

```nginx
server{
    listen80;
    server_name 127.0.0.1;
    location / {
    
    # 携带Header
    #设置主机头和客户端真实地址，以便服务器获取客户端真实IP,
    proxy_set_headerHost $host;
    proxy_set_headerX-Real-IP $remote_addr;
    proxy_set_headerX-Forwarded-For $proxy_add_x_forwarded_for;
    
    #禁用缓存
    proxy_bufferingoff;
    
    # 代理对象可以是 http、https域名或IP和端口
        proxy_pass http://domain.xxx;
    }
}
```

&nbsp;

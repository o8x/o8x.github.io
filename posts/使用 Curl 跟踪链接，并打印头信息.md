---
display-name: 使用curl跟踪链接，并打印头信息
draft: false
date: 2020-05-26 20:51:10
tags: [ "Linux" ]
---

> 今天为了测试本站配置的 HTTP2 有没有成功，特地查询了一下

## 参数解释

- -k 在使用SSL时允许不安全的服务器连接
- -L 跟随 301 302 跳转
- -I 只显示头信息

*还可以加入 -s，只输出简略信息。*

```shell
➜ curl  -k  -I  -L https://stdout.com.com

HTTP/2 200
server: nginx/1.14.1
date: Tue, 26 May 2020 12:49:55 GMT
content-type: text/html
content-length: 10024
last-modified: Tue, 26 May 2020 11:45:15 GMT
vary: Accept-Encoding
etag: "5ecd014b-2728"
expires: Tue, 02 Jun 2020 12:49:55 GMT
cache-control: max-age=604800
accept-ranges: bytes
```

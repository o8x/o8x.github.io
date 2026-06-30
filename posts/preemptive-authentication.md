---
display-name: 抢先验证 (preemptive authentication)
date: 2023-01-09 09:39:00
---

## 符合规范的HTTP流程

请求示例使用 java 语言的 okhttp 框架，版本必须不高于 3.12.0，因为 3.12.0 更新了抢先验证的特性，无法复现本文描述的现象。

更新日志：https://square.github.io/okhttp/changelogs/changelog_3x/#version-3120

代理请求示例

```java
Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress("host", 8080));
OkHttpClient client = new OkHttpClient.Builder().
        proxy(proxy).
        proxyAuthenticator((route, response) -> {
            String credential = Credentials.basic("user", "12345");
            return response.request().newBuilder().header("Proxy-Authorization", credential).build();
        }).
        connectTimeout(60, TimeUnit.SECONDS).
        build();

try {
    Request request = new Request.Builder().url("https://ip.cn/api/index?type=0").get().build();
    client.newCall(request).execute();
} catch (IOException e) {
    System.out.printf("error: %s\n", e.getMessage());
}
```

原始 HTTP

```http
> CONNECT ip.cn:443 HTTP/1.1
> Host: ip.cn:443
> Proxy-Connection: Keep-Alive
> User-Agent: okhttp/3.10.0
> 
< HTTP/1.1 407 Proxy Authentication Required
< Connection: Keep-Alive
< Proxy-Authenticate: Basic realm=""
< 
> CONNECT ip.cn:443 HTTP/1.1
> Host: ip.cn:443
> Proxy-Connection: Keep-Alive
> User-Agent: okhttp/3.10.0
> Proxy-Authorization: Basic dXNlcjoxMjM0NQ==
>
< HTTP/1.1 200 Connection established
<
```

可以看到第二次 CONNECT 才会进行密码的填充，第一次只进行正常请求。这样做的目的是
**确保只有需要身份验证的服务器才能获取到密码**，但同时也意味着服务器必须进行正确的HTTP 响应（407 or 401）且不能无视 Proxy-Connection 悄悄关闭连接，否则将会请求失败。

## 什么是 抢先验证

目前 cURL 或大部分的 http 请求 lib 均实现了 抢先验证，即无论服务端是否需要权限验证都在第一次CONNECT请求时携带 `Authorization` 头。这样做的原因是大部分服务器对于上述情况都未进行正确的 HTTP 响应或在不传递密码时直接关闭连接，导致无法进行正常的HTTP交互流程。

代理请求示例

```shell 
curl -v -U user:12345 -x host:8080 https://ip.cn
```

原始 HTTP

```http
> CONNECT ip.cn:443 HTTP/1.1
> Host: ip.cn:443
> Proxy-Connection: Keep-Alive
> User-Agent: curl/7.29.0
> Proxy-Authorization: Basic dXNlcjoxMjM0NQ==
>
< HTTP/1.1 200 Connection established
<
```


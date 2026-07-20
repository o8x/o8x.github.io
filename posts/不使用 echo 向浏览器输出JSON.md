---
display-name: 不使用 echo 向浏览器输出JSON
date: 2018-09-06 12:03:41
tags: ["杂项"]
---

在 php 中使用 return 返回 json 时，浏览器不会接收到任何数据，而使用 echo 则会导致程序不完整。所以我们可以使用 `php://output`

> php://output 是一个只写的数据流， 允许你以 print 和 echo 一样的方式 写入到输出缓冲区。

### 测试

参考 php://input 的使用方法测试 php://output

![]({{ env.cdn_accelerate }}/2018/09/e7057f3e89d3245f591dfe180eead1c8.png)

![]({{ env.cdn_accelerate }}/2018/09/ba3921bb465c41630d400ea5e8f06d40.png)

### 结果

![]({{ env.cdn_accelerate }}/2018/09/7b6d0dd660d6aa1cd3cacf7a636d0bd6.png)

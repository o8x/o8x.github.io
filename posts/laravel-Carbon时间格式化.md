---
display-name: laravel Carbon时间格式化
date: 2017-08-19 15:40:25
tags:  
- php
- laravel
---

laravel的时间戳格式不是按照一般框架法返回的字符串 ,也不是常规的integer时间戳 ,而是一个利用carbon对象 ,carbon本身提供了非常多的方法来格式化这个时间 ,例如

```php
$post->created_at->toFormattedDateString();
```

可以2017-8-16 格式化为 Aug 16, 2017 .非常的方便

参考资料 :[http://carbon.nesbot.com/docs/](http://carbon.nesbot.com/docs/)

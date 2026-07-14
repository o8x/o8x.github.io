---
display-name: 解决laravel5.4+ artisan数据迁移 ,字符长度超出抛出异常的问题
date: 2017-08-16 15:04:23
tags: [ "php" ]
---

laravel 5.4 之后，数据迁移时常伴随着如下异常:

![](http://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2017/08/2017-08-16-14-43-32-的屏幕截图-1.png)

其原因是，laravel5.4 之后默认为数据库设置了1070的长度，而数据库只允许768的长度。解决方案是启动时声明长度为191， 其中的算法参见 mb4string 与数据库编码的字节换算 .

内容如下 :

```php
<?php
// /laravel_root/app/Providers/AppServiceProvider.php
class AppServiceProvider extends ServiceProvider
{
  /**
   * Bootstrap any application services.
   *
   * @return void
   */
  public function boot()
  {
      Schema::defaultStringLength(191);
  }
}
```

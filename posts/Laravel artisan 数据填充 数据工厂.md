---
display-name: Laravel artisan 数据填充 数据工厂
date: 2017-08-19 17:54:52
tags: [ "php", "laravel" ]
---

```php
// 填充到 User 模型
$factory->define(\App\Post::class ,function(\Faker\Generator $faker) {
     return [
          /**生成单词 ,方法为数据的单词数*/
          'title' => $faker->sentence(6),
          /**生成文本 ,参数为句子数 */
          'content' => $faker->paragraph(10)
      ];
});
```

Tinker 中调用

```shell
/**
* 使用factory方法 ,
* 参数1 : 数据填充文件中写好的对应的模型名 ,
* 参数2 : 填充多少条 
* 
* ->make() 打印在屏幕上
* ->create() 插入数据库并打印在屏幕上
*/
factory(App\Post::class ,200)->make();
```

![]({{ env.cdn_accelerate }}/2017/08/2017-08-19-17-52-46-的屏幕截图.png)

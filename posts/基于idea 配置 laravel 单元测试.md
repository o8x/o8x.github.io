---
display-name: 基于idea 配置 laravel 单元测试
date: 2018-04-10 21:15:02
tags: ["php"]
---

#### php-cli

*设置 > 语言与框架 > PHP > CLI interpreter > ...*
> 添加phpcli      
> 刷新版本后下方出现 php version ... 即视为配置成功

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/04/9579c1f1aa3e31fe08dd625aa0a3d404.png)

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/04/8d130edcbbf3e7e6441f06199b2ab09b.png)

##### 配置phpunit ,用于进行测试

*Settings > Language&Framework > PHP > Test Frameworks > +号 > phpunit By locale*

> 选择自己喜欢的安装方法，也可以使用自动安装，推荐手动安装phar，输入phpunit安装路径后点右边的小圆圈刷新版本，下方出现PhpUnit version ... 即视为配置成功。

**补全 test runner ....，否则会出现Tests/TestCase不存在的致命异常**

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/04/73764197cf8afa5dd4c8212722397610.png)

#### 一次伟大的尝试

- 进入`/tests/Unit/`，打开 ExampleTest.php , 并执行类或方法的测试
  ![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/04/b0e8f8d47b07acb075fca78e81c5a4e5.png)

无论类还是方法，点击按钮后出现如下画面，视为测试成功

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/04/7403bccb52d92b35bddbe8188a61c260.png)

#### 配置测试上线文快捷键

*Settings > keymap > 在右侧搜索 Run Context Configure*

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/04/24b53f1819f6ee300445f2d92cfdc721.png)

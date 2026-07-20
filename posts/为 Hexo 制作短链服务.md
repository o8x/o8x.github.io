---
display-name: 使用 egg.js 为 hexo 搭建后端，实现短链接服务
date: 2020-05-27 20:27:49
---

## 缘起

> hexo 生成的链接实在太长了

## `egg.js` 的基本使用

*安装*

```bash
$ mkdir short-url && cd short-url
$ npm init egg --type=simple
$ yarn
```

*调试启动*

> 文件产生更新时自动重启egg服务器，免去频繁重启的问题

```shell
$ yarn dev
```

*部署*

> 生产部署，启动后运行在后台，默认端口7001

```shell
$ yarn start
$ yarn stop
```

*目录结构*

> 只介绍简单的目录

```bash
├── app                   # 主程序目录
│   ├── controller        # 控制器目录
│   ├── model             # 模型目录
│   └── router.js         # 路由文件
├── config
│   ├── config.default.js # 默认配置文件
│   ├── database.sqlite   # 数据库文件
│   └── plugin.js         # 插件配置文件 
├── logs                  # 日志文件
│   └── init
└── yarn.lock
```

*控制器*

> 实现一个 Hello World

```javascript
// app/controller/home.js
const Controller = require('egg').Controller;

class HomeController extends Controller {
    index() {
        // 响应数据
        this.ctx.body = 'Hello World'
    }
}
```

*路由*
> 实现上与 `php` 框架 `laravel` 非常的相似.

laravel

```php
<?php

Route::get('/' , 'HomeController@index')
```

egg.js

```javascript
// app/router.js
module.exports = app => {
    const {router, controller} = app;

    // 使用 router 中的方法进行访问方法限定，例如 get post 
    // 第一个参数是路由地址，第二个参数是访问时执行的方法指针 
    // 控制器名以实际的文件名为准
    router.get('/', controller.home.index);
}
```

*模型*
> 在 `sequelize` 部分会提到

# `sequelize` 的基本使用

## 安装

> 因为博客的特殊性，访问量并不大。故而选用了文件数据库 sqlite

```shell
$ yarn add egg-sequelize sqlite3

# 在你认为合适的地方，创建一个扩展名为 .sqlite 的文件作为数据库
$ touch config/database.sqlite
```

## 配置

*启用 sequelize*

```javascript
// config/plugin.js
module.exports = {
    sequelize: {
        enable: true,
        package: 'egg-sequelize',
    }
}
```

*数据库连接信息*

```javascript
// config/config.default.js
module.exports = appInfo => {
    const config = exports = {
        sequelize: {
            // host 理论上可以不写
            host: 'localhost',
            // 数据库类型
            dialect: 'sqlite',
            // 即刚才创建的文件
            storage: './config/database.sqlite',
            // 配置不自动处理时间戳
            // 否则每个查询都会多出一个 createat 的列
            define: {
                timestamps: false,
            },
        },
        // 关闭csrf，否则我们的接口将无法直接调用
        security: {
            csrf: false,
        },
    }
}
```

## 数据库结构

```sql
CREATE TABLE "urls"
(
    "id"         integer NOT NULL PRIMARY KEY AUTOINCREMENT,
    "url"        varchar(512),
    "short_url"  varchar(64),
    "created_at" timestamp,
    "deleted_at" timestamp
);
```

## 模型

```javascript
// app/model/url.js
module.exports = app => {
    // 获得数据类型
    const {STRING, INTEGER, DATE} = app.Sequelize;

    // 表名必须是复数形式
    // 例如 url => urls , supply => supplies  
    return app.model.define('url', {
        id: {
            type: INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        url: STRING(256),
        short_url: STRING(64),
        created_at: DATE,
        deleted_at: DATE,
    });
};

```

## 操作

> CRUD 返回值均为 `Sequelize` 模型，可以进行链式调用

*增加(Create)*

```javascript
// Urls 即表名
const newData = await ctx.model.Urls.create({
    url: '',
    shorturl: '',
    created_at: new Date().toLocaleString(),
    deleted_at: '',
});
```

*读取(Retrieve)*

```javascript
let data = await ctx.model.Urls.findOne({
    where: {
        // where 条件，一行一个
        id: newData.id,
    },
    // 其他条件
});
```

*更新(Update)*

```javascript
data.url = 'xxxxx'
// 异步操作,返回值为 Promise 对象
// 也可以使用 .then() 处理
await data.save()
```

*删除(Delete)*
> 需要确认数据存在，否则将会引发空指针异常

```javascript
if (data !== null) {
    data.destroy();
}
```

## 基本思路

> 通过 `post` 发送需要压缩的 `url` 到服务端，服务端接收后判断数据库中是否存在同样的链接，存在就直接返回数据库中的短链接，不存在则新建。

*算法*

> `Base64(aid)` 即对数据库自增ID做base64运算。

## 代码实现

*新建控制器*

```javascript
// app/controller/url.js
async
make()
{
    // 解析请求中的带来的源 url
    // 因为判断是否经过 encode 是很麻烦的一件事，所以直接 decode 再 encode
    const url = encodeURI(decodeURI(this.ctx.request.body.url))
    // 查询数据库中是否有相同的
    let result = await this.ctx.model.Urls.findOne({
        where: {url},
    })

    // 如果是 null，则认为不存在
    if (result === null) {
        // 新建一条
        let newUrl = await this.ctx.model.Urls.create({
            url, created_at: new Date().toLocaleString(),
        });

        // 将自增ID进行base64编码，保存到数据库中
        newUrl.short_url = this.makeShortUrl(newUrl.id);

        // 新建、更新、查询的结果集均为对象
        result = await newUrl.save();
    }

    // 返回数据，egg 默认会处理成 json
    // 使用 prefix 是为了方便后期修改这个前缀
    this.ctx.body = {
        prefix: '/url',
        shortUrl: result.short_url,
    }
}

// 生成短链接
makeShortUrl(id)
{
    return Buffer.from(String(id)).toString('base64')
}
```

*新建一条post路由*

```javascript
router.post('/url/make', controller.url.make)
```

*调用示例*

```bash
curl 'https://stdout.com.com/url/make' --data-raw 'url=https://xxxxx.xxx'
```

*响应示例*

> Https://stdout.com.com/url/Mzg=

```json
{
    "prefix":   "/url",
    "shortUrl": "Mzg="
}
```

## 实现访问短链接302到原链接

> 直接使用egg的 redireact 响应

```javascript
// 跳转链接实现
async
index()
{
    // 从数据库中查询短链接
    let url = await this.ctx.model.Urls.findOne({
        where: {
            // 获取到url中的参数
            short_url: this.ctx.params.id,
        },
    });

    // 如果存在，则使用egg的跳转响应，直接302到原链接
    if (url !== null) {
        return this.ctx.redirect(url.url);
    }

    // 不存在则跳转到404页
    return this.ctx.redirect(`https://stdout.com.com/404.html`);
}
```

*加一条路由*

> :id 为url参数，可以使用 this.ctx.params.id 获取

```javascript
router.post('/url/:id', controller.url.index)
```

## 修改 nginx 配置进行url跳转

> 因为访问量的关系我们并不打算多机部署，也不打算使用多域名，而是希望`https://stdout.com.com/url/xxx` 就直接跳转到原链接。这里使用nginx反向代理实现

```nginx
# 加入你的 nginx 配置文件中hexo server的部分
server {
      location ^~ /url/ {
            # egg工程运行 yarn start 启动后默认端口为 7001 
            proxy_pass http://127.0.0.1:7001$request_uri;
        }
}
```

*验证*

> location 即为跳转到的原链接地址

```
$ curl -I -L https://stdout.com.com/url/MjU=
HTTP/2 302
server: nginx/1.14.1
date: Sun, 07 Jun 2020 12:34:08 GMT
content-type: text/html; charset=utf-8
content-length: 229
location: https://stdout.com.com/2020/05/27/%E4%B8%BAhexo%E5%88%B6%E4%BD%9C%E7%9F%AD%E9%93%BE%E6%9C%8D%E5%8A%A1/
x-frame-options: SAMEORIGIN
x-xss-protection: 1; mode=block
x-download-options: noopen
x-readtime: 3
```

## 为 hexo post模板加入链接配置项

> 可选操作，让hexo进入文章页时自动获取当前文章短链接，并替换掉地址栏的长链接，使得复制等操作都可以直接得到短链接

> 如何加载自定义js代码，请参考主题引擎

*原理*

进入文章后获取当前 `location.href` 并请求`/url/make`获取短链接后使用 `history.pushState` 替换到当前地址栏中。

```javascript
// 我的主题引擎，加载jquery可能不及时，所以暂时使用了定时器来处理
let timer = setInterval(() => {
    try {
        if ($.post) {
            clearInterval(timer)
            // 生成短链接
            $.post('/url/make', {url: location.href}, data => {
                // 如果返回数据正确
                if (data.shortUrl) {
                    // 拼接后替换地址栏中的链接
                    history.pushState(null, {}, `${location.origin}${data.prefix}/${data.shortUrl}`)
                }
            })
        }
    } catch (e) {
    }
}, 30)

```

# 大功告成

> 效果演示

<video src="{{ env.cdn_accelerate }}/Jietu20200607-205130-HD.mp4"
style="max-width: 800px;min-width: 500px;"
controls="controls" preload="preload"></video>

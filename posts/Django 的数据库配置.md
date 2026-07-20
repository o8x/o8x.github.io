---
display-name: Django的数据库配置
date: 2017-12-21 10:44:13
tags: [ "Python", "Django" ]
---


Django默认是使用sqlite3文件数据库 ,而我们通常是使用mysql postgresql等关系型数据库 ,这时候就需要修改setting.py 中的DATABASE项 .

```python
DATABASES = {
    'default': {
        # 'ENGINE': 'django.db.backends.sqlite3', 
        # 'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
        'ENGINE': 'django.db.backends.mysql',  # mysql的连接方法
        'NAME': 'dbname',  # 数据库名
        'USER': 'dbuser',  # 数据库用户
        'PASSWORD': 'passowrd',  # 数据库密码
        'HOST': 'dbhost',  # 数据库连接地址
        'PORT': '3306',  # 端口
    }
}
```

*数据迁移和逆向*

> django有强大的migration 组件 ,可以用来在models.py 中新建数据表 ,后续的表操作也时基于models ,但是已经存在的表道要删除重建么 ,就算没有数据重建也是件麻烦事 .
> django的数据库逆向工具就可以解决这个问题

*使用前提*

* 数据库连接正常

  python3.6 manager.py inspectdb [table_name] [>|>> filename]`

无参数执行会检查所有的表并将结果输出到控制台中

带上 table_name 参数后只会检查参数的表名，否则将会扫描整个数据库

*模型文件*

![]({{ env.cdn_accelerate }}/2017/12/13608cadb9e6347834103cefbd33deb3.png)

**使用模型文件**

导入模型`from models.models import Table`

    from models.models import Table
    from utils.utils import utils
    import requests
    import json

*查询全部*

    def selectAll():
         return Table.objects.all().values()

*更新数据 *

    def update():
        return Table.objects \
            .filter(anchor_id=583) \
            .update(**{
            'nikename': '测试修改',
            'platform': '测试修改2222',
        })

*删除数据*

    def drop():
         return Table.objects \
            .filter(anchor_id=583) \
            .delete()

*插入数据*

    def inert(request):
        data = {
            'nikename': '昵称',
            'room_id': '21321321',
        }
        return  Table.objects.update_or_create(**data)

*查询3条*

    def selectAny(request):
        res = list(Table.objects.all().values()[:3])
        return utils._response(200, '', [
            res
        ])

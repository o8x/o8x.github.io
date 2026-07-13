---
display-name: 关于Python3.6 json.dumps() 无法解析datetime格式的问题
date: 2017-12-21 10:33:05
---

最近一直会遇到无法格式化datetime的问题 ,百度之 , 解决方案如下 :

* 1 不使用json库 ,改用其他的第三方json库
* 2 继承json类 ,重写解析方法
* 3 利用cls参数扩展json类 ,赋予解析datetime的能力 ,这里使用第三种

#### 首先是完成可以处理datetime的json类 :

```python
import json
from datetime import datetime


class DateEncoder(json.JSONEncoder):
    '''
        扩充JSON类 ,解决不能处理日期的BUG
    '''

    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.__str__()
        return json.JSONEncoder.default(self, obj)


# 使用json类时 ,把类实例传入json.dumps() 的cls参数

def json_encode(data, sort_keys=False):
    '''处理JSON 默认输出缩进为4的漂亮格式
        :param data: 数据
        :param sort_keys: 是否是格式化
        :return:
    '''
    return json.dumps(
        data, cls=DateEncoder, ensure_ascii=False,
        indent=4, sort_keys=sort_keys
    )
```

---
display-name: php 判断是关联数组还是索引数组算法
date: 2019-04-24 10:22:39
tags:  
- php
---

# 速度优先

```php
function isAssoc($array)
{
    return $array !== array_values($array);
}
```

# 内存优先

```php
function isAssoc($array)
{
    $array = array_keys($array); 
    return $array !== array_keys($array);
}
```

# 基准测试

[https://gist.github.com/Thinkscape/1965669](https://gist.github.com/Thinkscape/1965669)

---
display-name: php 迭代能力性能
date: 2019-03-14 10:39:58
tags:

- php

---

> 使用各种循环结构把一千万长度的数组的每个值自增１

## 测试用例

```php
<?php
class Test
{
    private $data;

    public function __construct($data)
    {
        $this->data = $data;
    }

    public function second()
    {
        list($t1 , $t2) = explode(' ' , microtime());
        return (float)sprintf('%.0f' , (floatval($t1) + floatval($t2)) * 1000);
    }

    public function foreach()
    {
        foreach ($this->data as $index => &$item) {
            $item++;
        }
    }

    public function array_reduce()
    {
        array_reduce($this->data , function (&$it) {
            $it++;
        });
    }

    public function array_map()
    {
        array_map(function (&$it) {
            $it++;
        } , $this->data);
    }

    public function array_walk()
    {
        array_walk($this->data , function (&$it , $key) {
            $it++;
        });
    }

    public function array_filter_use_both()
    {
        array_filter($this->data , function (&$it , $key) {
            $it++;
        } , ARRAY_FILTER_USE_BOTH);
    }

    public function array_filter_use_key()
    {
        array_filter($this->data , function ($key) {
            $this->data[$key]++;
        } , ARRAY_FILTER_USE_KEY);
    }
}

$data = [
    'array_map' ,
    'array_walk' ,
    'array_filter_use_key' ,
    'array_filter_use_both' ,
    'array_reduce' ,
    'foreach' ,
];

$test = new Test(range(0 , 10000000));
array_reduce($data , function ($res , $it) use ($test) {
    $start = $test->second();
    $test->{$it}();
    echo $it . ' ' . ((float)$test->second() - (float)$start) / 1000 . 's' . PHP_EOL;
});
```

## 三次执行获得了如下测试结果

```bash
> php index.php
array_map 8.152s
array_walk 2.257s
array_filter_use_key 3.76s
array_filter_use_both 0.449s
array_reduce 0.428s
foreach 0.216s

> php index.php
array_map 8.127s
array_walk 2.447s
array_filter_use_key 1.71s
array_filter_use_both 0.46s
array_reduce 0.447s
foreach 0.217s

> php index.php
array_map 10.001s
array_walk 5.566s
array_filter_use_key 1.958s
array_filter_use_both 0.464s
array_reduce 0.44s
foreach 0.222s
```

## 综合排名

1. foreach
1. array_reduce
1. array_filter_use_both
1. array_filter_use_key
1. array_walk
1. array_map

## 所以还是老老实实相信 foreach

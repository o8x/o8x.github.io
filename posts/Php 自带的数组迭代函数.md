---
display-name: php自带的数组迭代函数
date: 2019-03-13 16:20:27
tags: ["php"]
---

## php 自带了很多有用的数组函数，有些甚至可以避免使用 foreach

## array_map

> 这个函数提供了迭代数组的能力，并且会把迭代的值传递进第一个参数指向的函数中

```php
<?php

    $arr = [0 , 1 , 2 , 3];
    array_map(function ($val) {
        // 函数每次执行都会接收到$arr中的一个值，并且索引 +1
    } , $arr);

    $arr = ['a' => 0 , 'b' => 1];
    array_map(function ($val) {
        // 函数每次执行都会接收到$arr中的一个值，并且索引 +1 , 无法获取键名
    } , $arr);
    
    # 使用实例
    // 把所有值都强制转换为int类型
    $arr = [0 , 1 , 2 , 3];
    $result = array_map(function ($val) {
        return intval($val);
    } , $arr);

    //　简化用法
    $result = array_map('intval' , $arr);
```

## array_filter

```php
<?php
    $arr = [
        'a' => 0 ,
        'b' => 1 ,
        'c' => 2 ,
    ];

    array_filter($arr , function ($val , $key) {
        // 参数会被传入数组的 key 和 value
    } , ARRAY_FILTER_USE_KEY);

    array_filter($arr , function ($key) {
        // 参数会被被传入数组的 key
    } , ARRAY_FILTER_USE_KEY);

    # 使用实例
    // 过滤出val大于0的值
    $filter = array_filter($arr , function ($val , $key) {
        if ($val > 0) {
            return $val;
        }
    } , ARRAY_FILTER_USE_BOTH);

    // 简化写法
    $filter = array_filter($arr , function ($val) {
        return $val > 0;
    });

    // 过滤出key等于a的值
    $filter = array_filter($arr , function ($key) {
        return $key === 'a';
    } , ARRAY_FILTER_USE_KEY);
```

## array_reduce

> 这个函数很有意思，总共接受三个参数．参数一是输入的数组，参数二是闭包，参数三是参数二接受的参数的第一个参数的初始值．
> 参数二闭包接受两个参数，第一个是上一次迭代时这个闭包的返回值，第一次迭代时该参数为函数的第三个参数．如果不指定第三个参数默认为null．闭包的第二个参数是和array_map闭包的参数一样，都是每次迭代时的值，依然无法获取key

```php
<?php
    $arr = [
        'a' => 0 ,
        'b' => 1 ,
        'c' => 4 ,
    ];

    array_reduce($arr , function ($res , $val) {
        // 如果是第一次迭代，那么首先的可选值为第三个参数．
        // 如果没有传递第三个参数，那么为null

        // 如果不是第一次迭代，那么值为上一次迭代时本闭包的返回值，如果没有返回值则为null
    });

    ＃　实例
    // 计算0+1+...100的结果
    $res = array_reduce(range(0 , 100) , function ($res , $val) {
        return $res + $val;
    } , 0);
```

## array_walk

> 这个函数可以看做升级版的 array_map ,接受三个参数，数组 , 闭包和一个可选的自定义值    
> 但是值得注意的是，这个函数不是通过返回值接受处理好的值的，返回值是一个bool值，代表这迭代是否处理完成．   
> 并且这个函数的接受的数组是引用传递的，也就是说在函数内对$val和$key的操作，会直接反应到数组本身    
> 这个函数可以完全当做 foreach 使用

```php
<?php
    $arr = [
        'a' => 0 ,
        'b' => 1 ,
        'c' => 4 ,
    ];

    // 用法
    array_walk($arr , function ($val , $key ,$userdata) {
        echo "$key $userdata  $val" . PHP_EOL;
    } , 'hello');

    // 如果 key 是 a 就注销这个key
    array_walk($arr , function ($val , $key) use (&$arr) {
        if ($key == 'a') {
            unset($arr[$key]);
        }
    });

    // 为每个值+1
    array_walk($arr , function (&$val , $key) {
        return $val++;
    });
```

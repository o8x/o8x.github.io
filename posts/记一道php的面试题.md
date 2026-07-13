---
display-name: 记一道 php 的面试题
date: 2020-06-30 15:36:38
tags: ["php"]
---

### 题目

```php
class User
{
    public $name;
    public $age;
}

$user       = new User();
$user->name = 'Alex';
$user->age  = 20;

foreach ($user as $key => $val) {
    echo "$key => $val" . PHP_EOL;
}
```

以上例程会输出：

```php
name => Alex
age  => 20
```

**要求：只能改User类的代码，不能修改执行部分，将以上例程的输出变为如下的结果，如何实现？**

```php
姓名 => Alex
年龄 => 20
```

### 答案

原理：利用php的魔术方法

```php
class User
{
    public $name;
    public $age;

    // 提前注销两个变量，__set 只有在设置的属性不存在时，才会调用。        
    // 另外如果不注销，即使实现也将会同时输出 name age 姓名 年龄 四个属性，这并不符合题目要求         
    // 当然也可以不使用构造方法，直接将两个变量删除即可，题目中并未规定不能删除原代码    
    public function __construct()
    {
        unset($this->name);
        unset($this->age);
    }

    // php 提供的魔术方法之一，在设置的属性不存在时，被调用。
    public function __set($name , $value)
    {            
        // 将原生属性名 name 和 age 替换为姓名和年龄   
        if ($name === 'name') {
            return $this->{'姓名'} = $value;
        } 
        
        if ($name === 'age') {
            return $this->{'年龄'} = $value;
        } 

        // 再设置其它值，则使用原生属性名   
        // 如果没有这一行，无法设置 姓名 年龄 属性
        // 当然也可以直接初始化 姓名和年龄 属性 
        return $this->{$name} = $value;
    }
}

$user       = new User();
$user->name = 'Alex';
$user->age  = 20;

// 此时原属性已经被注销，并且替换为姓名年龄
// 所以输出属性也会跟随修改
foreach ($user as $key => $val) {
    echo "$key => $val" . PHP_EOL;
}
```

#### 执行结果

```php
姓名 => Alex
年龄 => 20
```

#### 优化

增加 __get 魔术方法，让调用 `$user->age` 时的输出是正确的

```php
// php 提供的魔术方法之一，在获取的属性不存在时，被调用。
public function __set($name)
{            
    // 获取name和age属性时，替换输出姓名和年龄的值   
    if ($name === 'name') {
        return $this->{'姓名'};
    } 
    
    if ($name === 'age') {
        return $this->{'年龄'};
    } 

    // 其它值则使用原生属性名获取
    return $this->{$name};
}
```

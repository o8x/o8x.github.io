---
display-name: Python 基础语法
date: 2017-09-02 16:18:03
tags: ["杂项"]
---

**最近开始了新课题 ,linux自动化.**

其是主要也就是日志分析之类的简单需求 ,用linux的亲儿子bash shell完全可以实现 ,但shell各种奇怪的语法写起来心都碎了 .于是就决定学习大名鼎鼎的Python ,这里记录一下Python的基础语法.

### 变量

```python
# 整形
var = 1
# 浮点型
var = 1.123
# 字符串型
var = 'String'
# 布尔型
var = True
# 列表型
var = [1, 2, 4, 5, [2, 'value', []]]
# 元组型
var = (2, 2, '', True)
# 字典型
var = {a: "a", b: "cd", ab: ['ab']}

'''
与php和javascript的弱类型不同 ,Php等是各种数据类型在语言层面被隐式转换再使用 ,而Python是自猜想数据类型 ,变量声明和赋值时Python会尝试猜想数据类型再操作 ,但是如果赋值时数据类型不一致 ,仍然会导致赋值失败并抛出异常 ,这与PHP等有着本质的差别 ,这里也不难看出 Python是一门典型的强类型语言
'''
```

#### 查看变量数据类型

```python
print
type(var)
```

#### 数据类型显式强制转换

```python
var = int(var)
var = str(var)
```

#### 分支结构 ,只有If 没有Switch

```python
if var == 10:
    return var
elif var != 23
    return var + str(var)
else
return var + int(var)
```

#### 循环 ,类似JS的for in

```python
for item in var:
    if item == 'age':
    print
var[item]
elif item <= 10:
print
len(var[item])

flag = 0
while flag < 15:
    flag += 1
if flag == 23:
    break
```

#### 方法定义

```python
def funcName(ParamsList='abc'):


    if str(ParamsList) == 20:
    return False

```

#### 方法调用

```python
print
funcName('123')
```

#### 类定义 `__init__ 是构造方法`

```python
class className(object):


    def functionName(self, params):


    return False


def __init__(self):


    return self
```

#### 类继承

```python
class class2(className):


    def __init__(self, name='xaingli'):


    self.functionName(name)
```

#### 类实例化与方法调用

```python
Var = Class2('name')
print
Var.functionName('myName')
```

#### 模块导入 可以是自定义模块 ,且模块名不加.py

```python
    import math

form
math
import *
```

#### 模块调用

```python
math.sin(32)
sin(32)
```


---
display-name: IDEA 重构代码
date: 2018-06-28 21:14:41
tags:  
- idea
---

# IDEA 强大的代码块重构能力

# 把代码块重构成方法

> 选中代码块按组合键 `ctrl + alt + m`

例如 这里的 `new Date()` 需要重构为方法

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/f7f5f6c7c3f6d293c32f6f49c36d2421.png)

### 按组合键 之后

> 从左到右的可调节参数依次是 方法作用域，返回值类型，方法名
> 下方是代码预览

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/82d3da970861e8bde92759813e581ee0.png)

### 设置好之后按OK

> 如图
> ![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/287607a3016f3cc5bd67be5068550b39.png)

# 把代码块重构成类常量

> 选中代码块按组合键 `ctrl + alt + c`

例如 这里的 `new Date()` 需要重构为类常量

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/f7f5f6c7c3f6d293c32f6f49c36d2421.png)

### 按组合键 之后

> 从上往下 ，X 是候选常量名 ，DATE是自动猜测的候选常量名

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/535829aa0cc4f08aea92dcd9fad399c6.png)

### 按方向键选择候选名 ，回车之后

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/540ab6dcf80df5dcf644190ca39568e1.png)

### move to another class

> 钩上再回车 ，会进入一个类似方法配置的设置页面 ，参数和重构为方法类似
> 在这里甚至可以把代码块重构到另一个包中

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/99598619bf8beabc3b81e539c47ec340.png)

> 值的注意的是，这里设置之后设置项会被记忆，换言之只需要配置一次，下一次进行重构不需要使用move to...，也可以直接得到曾经设置好的配置

# 重构为变量

> `ctrl + alt +_v`
> 可选参数不多 ，只有候选名字 ，
> 可以通过打钩设置重构成常量

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/8e83dc1d9070bf47c2e1c6c92a2316e9.png)

### 不打钩的效果

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/f599c2bdf29a9e5824ba950ab48eb61b.png)

### 打钩的效果

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/d8822f894506249d83ea5e32ce20520c.png)

# 重构为方法参数

> `ctrl + alt +_p`
> 可以通过打钩，重载当前方法，再由本方法调用和传递重载参数

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/3fd1c9f9d992f8bd29a97f94ae363175.png)

### 不打钩的效果

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/fe093fd7cc613dec989a2ac0513a1b61.png)

### 打钩的效果

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/98b9040036fc41474c327b80d6562e31.png)

# 以上的组合键可以对变量直接使用

例如 ： ctrl + alt + v
![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/5a91dd959b67724cf18ac5e3688678b5.png)

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/1d85ec0d9e8955fc8152a84291e08e03.png)

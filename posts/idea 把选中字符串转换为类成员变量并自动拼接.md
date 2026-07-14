---
display-name: idea 把选中字符串转换为类成员变量并自动拼接
date: 2018-08-21 09:03:16
---

idea 中选中字符串之后可以用 crtl + alt + v ,把字符串转换为变量 , 支持自定义命名和可见性 , 很不错 .

不仅如此, 还可以用 crtl + alt + f ,把字符串转换为类成员变量并自动拼接

# 效果展示

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/08/8e7fe5eb3f3c2dece2d5b91cd3834ae0.png)

按ctrl + alt + f 之后

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/08/0352732dbc0dbd173cbbf9b2e37becb5.png)

也自动生成了成员变量

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/08/8601ae109c2b420e5f912bb68c7ee3b6.png)

显然str不是我们想要的名字 , 于是按 shift + f6 , 直接修改变量名 , 改完回车自动对所有引用生效

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/08/230902f682b5f2b54da7b1d3398b4696.png)

---
display-name: Linux 内核模块载入参数
date: 2022-06-18 11:51:03
tags: ["Linux"]
---

linux 内核模块可以使用 `module_param` API声明一些参数，在载入时由用户填写

### module_param

```c
module_param(name, type, prem)
```

name 变量名，需要事先定义 `type` 类型的同名变量

type 类型 int、char 等

prem 类似 linux 的文件权限

- S_IRUSR 00400 所有者可读
- S_IWUSR 00200 所有者可写
- S_IXUSR 00100 所有者可执行
- S_IRGRP 00100 所有者所在组可读
- S_IROTH 00100 其他可读
- S_IRUGO S_IRUSR|S_IRGRP|S_IROTH

### 示例

```
+ // 定义变量
+ static int debug = 0;

+ static int __init module_init(void) {
+     if (debug == 1) {
+         printk("fried_chicken module init with debug");
+     } 
+     return 0;
+ }

+ // 注册 int 类型参数 debug 
+ module_param(debug, int, S_IRUGO);
```

### 使用

```
insmod fried_chicken.ko debug=1
```

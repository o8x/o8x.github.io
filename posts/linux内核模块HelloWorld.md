---
display-name: Linux 内核模块 HelloWorld
date: 2022-06-18 11:36:03
tags: ["Linux"]
---

### 示例

```
#include <linux/init.h>
#include <linux/module.h>

static int __init fried_chicken_init(void) {
    printk("Hello World");
    printk("fried_chicken module init");
    return 0;
}

static void fried_chicken_exit(void) {
    printk("fried_chicken module exit");
    return;
}

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Alex");
MODULE_DESCRIPTION("A linux kernel module example");

module_init(fried_chicken_init);
module_exit(fried_chicken_exit);
```

### 编译

运行 make all 之后将会得到 fried_chicken.ko 文件

Makefile

```makefile
CONFIG_MODULE_SIG=n

ifneq ($(KERNELRELEASE),)
obj-m := fried_chicken.o
else

KDIR := /usr/src/kernels/$(shell uname -r)

all:
	@$(MAKE) -C $(KDIR) M=$(PWD) modules

endif
```

### 模块的装载与卸载

```shell
insmod fried_chicken.ko
```

```shell
rmmod fried_chicken
```

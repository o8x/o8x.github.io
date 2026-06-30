---
display-name: Linux 内核 Sleep
date: 2022-06-18 13:47:54
categories:
- Linux 内核
tags:

- Linux 内核

---

linux 内核并未实现 sleep，但头文件 <linux/delay.h> 提供了类似的实现

### 用法

纳米休眠

```c
ndelay(ns)
```

微秒休眠

```c
udelay(us)
```

毫秒休眠

```c
mdelay(ms)
```

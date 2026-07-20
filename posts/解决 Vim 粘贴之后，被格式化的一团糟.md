---
title: 解决vim粘贴之后，被格式化的一团糟
create-time: 2018-07-12 16:03:08
tags: [ "Linux" ]
---

#### 粘贴之前设为粘贴模式

> 这时候就不会按vim格式化 ，原文什么样粘贴就是什么样了

```shell
:set paste
```

#### 粘贴之后取消

```shell
:set nopaste
```

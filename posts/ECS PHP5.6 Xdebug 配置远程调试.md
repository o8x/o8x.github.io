---
display-name: ECS PHP5.6 Xdebug 配置远程调试
date: 2017-10-01 10:53:30
tags: ["php"]
---

### 核心代码

```ini
[Xdebug]
zend_extension = "xdebug.so"
xdebug.remote_enable = 1
xdebug.remote_handler = dbgp
xdebug.remote_host = 你本地的公⽹IP
xdebug.remote_port = 9000
xdebug.remote_autostart = 1
xdebug.idekey = "PHPSTORM"
```

### 断点总是停在 index.php 第一行

点击菜单Run，在弹出菜单中取消勾选“Break at first line in PHP scripts”

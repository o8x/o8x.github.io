---
display-name: deepin重启输入法
date: 2019-02-21 16:16:47
categories:
- Linux
tags:  
- Linux
- Deepin
---

```shell
pidof sogou-qimpanel | xargs kill
nohup fcitx 1 > /dev/null 2 > /dev/null 
nohup sogou-qimpanel 1 > /dev/null 2 > /dev/null
```

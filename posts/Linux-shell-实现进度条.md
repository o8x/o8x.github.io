---
display-name: 使用 Linux Shell 实现进度条
draft: false
date: 2020-07-18 08:22:02
categories:
- Linux
tags:

- Linux

---

# 代码

```shell
function process(){
    spa=''
    i=0
    while [ $i -le 100 ]
    do
        printf "[%-50s] %d%% \r" "$spa" "$i";
        sleep 0.5
        ((i=i+2))
        spa+='#'
    done
    echo
}

process
```


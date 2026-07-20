---
display-name: 使用 ffmpeg 进行B站直播
date: 2018-07-11 14:22:06
tags: [ "Linux" ]
---

## 打开直播

> [https://link.bilibili.com/p/center/index#/my-room/start-live](https://link.bilibili.com/p/center/index#/my-room/start-live)

![]({{ env.cdn_accelerate }}/2018/07/d9615bb2f9e0e729e27952f862a0a274.png)

    ffmpeg -re -i "1.mp4" -vcodec copy -acodec aac -b:a 192k -f flv "rtmp地址/直播码"

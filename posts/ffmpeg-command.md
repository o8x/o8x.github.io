---
display-name: ffmpeg 常用命令  
date: 2023-04-17 09:44:09  
categories:

- 杂项

tags:

- ffmpeg

---

- 合并视频

-i 也可以改成文件名，文件内容为一行一个待合并的文件名称

```shell
ffmpeg -f concat \
    -i item1.mp4 \
    -i item2.mp4 \
    -c copy merge.mp4
```

- 从视频文件中分离音频并合并

```shell
ffmpeg -i join.txt -f concat -vn -c copy merge.mp3
```

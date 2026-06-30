---
display-name: 隐藏audio标记下载按钮和调整音量
date: 2018-02-20 21:19:23
tags:

- javascript

---

平常的audio标记会出现明显的下载按钮 , 资源很容易被盗走，audio标记的属性`controlsList="nodownload"`可以实现隐藏按钮

```html

<audio id="audio" src="xxx.mp3"
       autoplay="autoplay" loop="loop"
       controls="controls"
       controlsList="nodownload"></audio> 
```

如果只是作背景音乐 ,那么插入网易的音乐外链是一个不错的选择

```html

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=86
        src="//music.163.com/outchain/player?type=2&id=483671599&auto=1&height=66"></iframe>
```

#### 页面初始化时将音量调整到30%

```Javascript
window.onload = () => {
    let player = document.getElementById("audio");
    player.volume = 0.3;
}
```

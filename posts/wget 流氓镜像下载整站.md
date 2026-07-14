---
display-name: wget 流氓镜像下载整站
date: 2017-11-09 13:45:01
tags: [ "Linux" ]
---

```shell
$ wget -c -r -np -k -l 3 -p www.xxx.org/pub/path/
```

#### 参数详解 :

- -c断点续传

- -r递归下载，下载指定网页某一目录下（包括子目录）的所有文件

- -np 递归下载时不搜索上层目录，如wget -c -r www.xxx.org/pub/path/，没有加参数-np，就会同时下载path的上一级目录pub下的其它文件

- -k将绝对链接转为相对链接，下载整个站点后脱机浏览网页，最好加上这个参数

- -L递归时不进入其它主机，如 wget -c -r www.xxx.org/ 如果网站内有一个这样的链接：www.yyy.org
  ，不加参数-L，就会像大火烧山一样，会递归下载www.yyy.org网站；但是现在很多的css、js、img都不在项目的目录下保存，而是在html页面中src一个http引用，所以如果想要一并download当前页面引用的http资源，比如js，css，img，那么这个参数就需要省略

- -l下载层级，默认最大为5级，一般情况下3级就够了

- -p下载网页所需的所有文件，如图片等

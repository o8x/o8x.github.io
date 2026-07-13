---
display-name: 安装neofetch显示出linux系统信息
date: 2018-03-06 18:36:42
tags: [ "Linux" ]
---

# 安装

```shell
$ sudo yum install dnf-plugins-core
$ sudo dnf copr enable konimex/neofetch
$ sudo dnf -y install neofetch
```

# 运行neofetch

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/03/5f52273b94c4fb1d855d098977c254b6.png)

# 显示图形化的LOGO

如果你想用图片显示你的发行版 logo，需要用下面的命令安装 w3m-img 或者 imagemagick 。

```shell
$ sudo yum install w3m-img
```

# 效果

![](https://dn-linuxcn.qbox.me/data/attachment/album/201612/04/145757thnj4nc7888p8den.png)

# 配置文件

第一次运行 neofetch 后，它会在这里创建一个配置文件： $HOME/.config/neofetch/config。

这个配置文件可以让你通过 printinfo ()  函数来调整你想显示在终端的系统信息。你可以增加，修改，删除，也可以使用 bash 代码去调整你要显示的信息。

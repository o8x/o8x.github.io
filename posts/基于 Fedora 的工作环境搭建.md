---
display-name: 基于 Fedora 的工作环境搭建
date: 2018-07-09 14:28:24
tags: [ "Linux" ]
---

# 前言

> 作者已经使用了2年fedora作为日常工作生活的操作系统    
> 本文是作者换电脑 ，重装系统的记录
> 本文基于fedora28

![clipboard.png]({{ env.cdn_accelerate }}/2022/3842505885-5b4597f0aad76_fix732.webp)

# 安装fedora

> 教程太多，不赘述

# 卸载无用软件

> fedora自带了很多用处不太大或者鸡肋的软件，我们来卸载他们

- rhythmbox 这是一个音乐播放器，可以听FM和本地音乐，但是需要手动安装各种解码器，需要可以保留

```shell
rpm -qa | grep rhy | xargs -I {} sudo yum -y remove {}
```

![1531216030383]({{ env.cdn_accelerate }}/resource/1531216030383.png)

- libreofficce 这是一个强大的Office软件，但是对windws的兼容度不是很好 ，稍后我们用WPS替代它

```shell
rpm -qa | grep libreoffice | xargs -I {} sudo yum -y remove {}
```

![1531216427069]({{ env.cdn_accelerate }}/resource/1531216427069.png)



-------------------------------------------

# 对系统进行配置

### 快捷键

![1531216495033]({{ env.cdn_accelerate }}/resource/1531216495033.png)

### 更换软件源

> fedora 自带的软件源很快 ，需要的话可以换成aliyun源

- 备份

```shell
mv /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.backup
mv /etc/yum.repos.d/fedora-updates.repo /etc/yum.repos.d/fedora-updates.repo.backup
```

- 下载新的repo和updates.repo 到 /etc/yum.repos.d/

```shell
wget -O /etc/yum.repos.d/fedora.repo http://mirrors.aliyun.com/repo/fedora.repo
wget -O /etc/yum.repos.d/fedora-updates.repo http://mirrors.aliyun.com/repo/fedora-updates.repo
```

- 生成缓存

```shell
sudo yum makecache
```

------------------------------------------------------------------------------

# 安装必要的软件和插件

> 刚才我们卸载了liboffice ，但是我们不能没有office，于是就安装WPS(大概是linux中最好的office了)来用

- 安装libmng依赖

```shell
sudo yum -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/libmng-1.0.10-14.el7.i686.rpm http://dl.fedoraproject.org/pub/fedora/linux/releases/28/Everything/x86_64/os/Packages/l/libpng-devel-1.6.34-3.fc28.i686.rpm
```

- 下载

```shell
# 这个很慢，需要科学上网才会快 ,挂着等自动安装就好了 ，对应office2016
wget http://kdl.cc.ksosoft.com/wps-community/download/6634/wps-office-10.1.0.6634-1.x86_64.rpm

# 或者bate的8版本 ，不支持高分屏 ，更像office2010
wget http://wdl1.cache.wps.cn/wps/download/Linux/unstable/wps-office-8.1.0.3724-0.1.b1p2.i686.rpm
```

- 安装

> 我们发现rpm安装会依赖检测失败 ，但是我们不可能手动来搞，于是我们就使用yum

![1531217246227]({{ env.cdn_accelerate }}/resource/1531217246227.png)

- 用yum安装wps

```shell
sudo yum -y install ./wps-office-8.1.0.3724-0.1.b1p2.i686.rpm
```

![1531220136418]({{ env.cdn_accelerate }}/resource/1531220136418.png)


- 安装在此处打开终端

- > 可以在文件夹里使用此处打开终端
，重启后生效![1531284416455]({{ env.cdn_accelerate }}/resource/1531284416455.png)

```shell
sudo yum install nautilus-open-terminal
```

- 安装Typora

1. 下载

```shell
wget https://typora.io/linux/Typora-linux-x64.tar.gz
```

2. 解压

```shell
tar xzvf tarTypora-linux-x64.tar.gz
```

3. 添加桌面图标

在~/.local/share/applications/中建立一个叫做Typora.desktop.desktop的文件，写入以下内容

/PATH 替换成你的Typora的路径

```shell
[Desktop Entry]
Version=1.0
Type=Application
Name=Typora
Icon=/PATH/Typora-linux-x64/resources/app/asserts/icon/icon_256x256@2x.png
Exec="/PATH/Typora-linux-x64/Typora"
Comment=Markdown editor
Categories=Development;IDE;
Terminal=false
Name[zh_CN]=Typora
```

4. 然后就可以在应用列表中发现：

![1531220806137]({{ env.cdn_accelerate }}/resource/1531220806137.png)

- 安装UML建模工具

- umlet

```shell
sudo yum -y install umlet
```

- StarUML

```shell
wget https://s3.amazonaws.com/staruml-bucket/releases/StarUML-3.0.1-x86_64.AppImage

./StarUML-3.0.1-x86_64.AppImage
```

- 最漂亮的一个国产制图软件 ： edrawmax

```shell
wget http://www.edrawsoft.cn/2download/edrawmax-9-64-cn.tar.gz
tar xzvf edrawmax-9-64-cn.tar.gz
chmod +x EdrawMax-9-64.run 
sudo su 
./EdrawMax-9-64.run 
```

![1531284666651](/tmp/1531284666651.png)

# 改善终端的使用体验

- 点击终端的编辑 首选项 ，可以配置一些基础的配置

![1531221062615]({{ env.cdn_accelerate }}/resource/1531221062615.png)

# 更新系统

```bash
sudo yum -y update
```

# 安装chrome

```bash
cd /etc/yum.repos.d/
sudo wget  http://repo.fdzh.org/chrome/google-chrome-mirrors.repo
sudo dnf install -y google-chrome-[stable|unstable]
```

# 安装steam

- 按需显卡平台前置依赖

```shell
# Intel
sudo dnf -y install xorg-x11-drv-intel mesa-libGL.i686 mesa-dri-drivers.i686
# AMD 
sudo dnf -y install xorg-x11-drv-amdgpu mesa-libGL.i686 mesa-dri-drivers.i686
# NVIDIA
sudo dnf -y install xorg-x11-drv-nouveau mesa-libGL.i686 mesa-dri-drivers.i686 xorg-x11-drv-nvidia-libs.i686
```

- 添加软件源

```shell
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

- 更新系统

```shell
sudo dnf -y update
```

- 安装steam

```shell
sudo dnf -y install steam
```

![1531222727615]({{ env.cdn_accelerate }}/resource/1531222727615.png)

- 然后输入steam，我们就可以看到这个

![1531222761068]({{ env.cdn_accelerate }}/resource/1531222761068.png)

# 安装其他软件

- vscode

- > 参考
： [https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions](https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions)

# 安装主题

- 先安装gnome优化工具 ，用于切换主题

```shell
sudo yum -y install gnome-tweak-tool
```

- 下载和安装主题

- > 这里使用十分三个优秀的主题

- 光标

- ```shell
git clone https://github.com/keeferrourke/capitaine-cursors.git
cd capitaine-cursors
# 编译
./build.sh
```

  安装

  ```shell
  全局安装
  sudo cp -pr dist/ /usr/share/icons/capitaine-cursors
  当前用户安装
  cp -pr dist/ ~/.icons/capitaine-cursors
  ```


- shell主题

- 安装必须依赖

```shell
sudo yum -y install autoconf automake gdk-pixbuf2-devel glib2-devel libsass libxml2 pkgconfig sassc parallel
```

- 安装

```shell
git clone https://github.com/adapta-project/adapta-gtk-theme.git
cd adapta-gtk-theme/
./autogen.sh
make && make install
```


- 图标

- 安装

- yum

  ```shell
  sudo dnf copr enable tcg/themes
  sudo dnf install la-capitaine-icon-theme
  ```

- git

  ```shell
  git clone https://github.com/keeferrourke/la-capitaine-icon-theme.git
  cd la-capitaine-icon-theme/
  ./configure
  ```

- 配置GTK

- 找到刚才安装的 gnome-tweak-tool ，它长这样 ，打开

![1531280064808]({{ env.cdn_accelerate }}/resource/1531280064808.png)

- 打开允许用户设置主题

![1531280170920]({{ env.cdn_accelerate }}/resource/1531280170920.png)

- **配置主题**

> 设置成这样。

![1531280270839]({{ env.cdn_accelerate }}/resource/1531280270839.png)

- **然后你会发现你的fedora , 变成了这样**

![1531280360776]({{ env.cdn_accelerate }}/resource/1531280360776.png)

# 安装Java

> 前往这里下载需要的jdk
>
> [http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

## 手动安装

```shell
wget http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz?AuthParam=1531285487_916e562108e7d8f45b5e75517459b1f5
tar xzvf jdk-8u171-linux-x64.tar.gz
```

> /etc/bashrc 中添加如下几句话
>
> 按你自己的参数修改

```shell
JAVA_HOME=/xxxx/jdk-8u171-linux-x64/jdk1.8.0_171
CLASSPATH=$JAVA_HOME/lib/
PATH=$PATH:$JAVA_HOME/bin
export PATH JAVA_HOME CLASSPATH
```

> 让配置生效

```shell
source /etc/bashrc
```

## YUM 安装

### 安装前检查

> 检查系统有没有自带jdk
>
> 如果没有输入信息表示没有安装。

```shell
rpm -qa |grep java ; rpm -qa | grep jdk ; rpm -qa |grep gcj
```

> 如果安装过进行批量卸载

```shell
rpm -qa | grep java | xargs rpm -e --nodeps 
```

### 安装

> 首先检索包含java的列表

```shell
yum list java*
```

> 检索1.8的列表

```shell
yum list java*
yum list java-1.8*   
```

> 安装jdk 1.8.0

```shell
yum install java-1.8.0-openjdk* -y
```

# 安装PHP

### 使用yum安装

> 这样带composer也都装好了

```shell
sudo yum -y install composer
```

### 编译安装

> 参考： [https://github.com/DevTTL/lnmp](https://github.com/DevTTL/lnmp)

# 安装IDE

> 我使用Toolbox进行安装

- 安装
Toolbox [https://www.jetbrains.com/toolbox/download/download-thanks.html](https://www.jetbrains.com/toolbox/download/download-thanks.html)

- 打开之后这样

- > 选择需要的点install就可以自动安装了

![clipboard.png](https://segmentfault.com/img/bVbdCcT?w=906&h=1508)

# 安装Nodejs

> 安装最为简单

```shell
wget http://cdn.npm.taobao.org/dist/node/v10.5.0/node-v10.5.0-linux-x64.tar.xz
xz -d node-v10.5.0-linux-x64.tar.xz
tar xvf node-v10.5.0-linux-x64.tar
cd node-v10.5.0-linux-x64

# 重启会失效
export PATH="$PATH:$(pwd)/bin/"

# 对用户永久生效
echo "export PATH=\"$PATH:/NODE_PATH/bin/\"" >> ~/.bashrc
source ~/.bashrc

# 对所有用户永久生效
echo "export PATH=\"$PATH:/NODE_PATH/bin/\"" >> /etc/bashrc
source /etc/bashrc
```

## 测试

```shell
[user@bogon ~]$ node --version
v10.5.0
[user@bogon ~]$ npm --version
6.1.0
```

# 安装包管理器和软件脚手架

## 包管理器

- composer

> 首先有PHP

```shell
[root@bogon etc]$ php -v
PHP 7.2.7 (cli) (built: Jun 19 2018 14:40:10) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"

# 使用中国镜像
composer config -g repo.packagist composer https://packagist.phpcomposer.com
```

- yarn & cnpm

```shell
npm install cnpm
cnpm install yarn 
```

## 脚手架

- vue

```shell
cnpm install vue

# 这样使用
vue init 
```

- angular

```shell
# 用cnpm安装ng会奇怪的问题 ，建议使用npm
npm -g install @angular/cli

# 这样使用
ng new package
```

- laravel

```shell
composer global require "laravel/installer"

# 这样使用
laravel new package
```

# 一些可能用的到的包

## ffmpeg  优秀的视频处理工具

```shell
sudo yum -y install ffmpeg
```

# 一些有用的alias

> 以下这些都可以按照安装nodejs中的方法 echo 到bashrc中，使永久生效



> docker 绑定上root

```shell
alias docker="sudo docker"
```

> git 快速推送

```shell
alias pushgit="git add . && git commit -m $1 && git push origin $2"
# 使用示例
pushgit "一个提交的案例" master
```

# 开始尽情的使用吧

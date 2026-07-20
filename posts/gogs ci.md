---
display-name: 基于 Docker ，Gogs，Jenkins，Kubernetes 实践工程源代码的自动构建和持续集成与部署交付
date: 2019-04-25
tags: ["git"]
---

> 本期目标 : 基于 Centos 7.6 , 封装出一个可用于运行 php 项目的开箱即用镜像
> 本文不讨论 dockerfile 语法 , 并且假设你懂得基本的类unix 操作系统常识并拥有类unix 运行环境 (包括但不限于安装了mac 或 linux 的实体机 , 类unix虚拟机 , 安装了 MinGW 或 CygWin 的
> windows 机器) , 并且认为你懂得基本的 docker 操作和有一定的 dockerfile 阅读能力

## 准备工作

建立工作目录

```bash
mkdir ~/docker-learn
cd ~/docker-learn
```

创建Dockerfile

```bash
touch Dockerfile
```

然后拷贝你常用的 nginx.conf 到工作目录

```bash
cp xxx/nginx.conf nginx.conf
```

## 封装基础镜像

编辑我们创建好的 Dockerfile

### 基础内容

声明本镜像继承自 centos 最新版

```dockerfile
FROM centos
```

### 安装 nginx

- 创建nginx源文件

> 由于 centos 仓库里是没有 nginx 的 , 所以我们要自力更新添加nginx的源到 docker 里 复制 [nginx.org](http://nginx.org/en/linux_packages.html#RHEL-CentOS) 里关于 RHEL 源的内容到 nginx.repo 文件

也可以本地执行以下命令创建 nginx.repo

```bash
sudo tee ./nginx.repo <<-'EOF'
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
EOF
```

- 写入复制 nginx.repo 指令到docker镜像中

```dockerfile
COPY nginx.repo /etc/yum.repos.d/nginx.repo
```

- 使用yum安装nginx并设置为开机启动

```bash
RUN yum makecache && 
    yum install nginx && 
    chkconfig nginx on
```

### 安装 php

> centos 默认源中拥有低版本的 php 以及相关包 , 我们需要换一个版本新一些的源 .
> 本文 [remi开源镜像](https://mirrors.tuna.tsinghua.edu.cn/help/centos/)

- 安装 remi 源

```dockerfile
RUN rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum update -y 
```

- 使用 yum 安装php和相关包并设置为开机启动

```dockerfile
RUN yum install -y --enablerepo=remi --enablerepo=remi-php72 \ 
    php \
    php-openssl \
    php-curl \
    php-bcmath \
    php-devel \
    php-mbstring \
    php-mcrypt \
    php-mysqlnd \
    php-pdo \
    php-gd \
    php-xml \
    php-opcache \
    php-fpm && \
    chkconfig php-fpm on
```

### 清理工作

> 众所周知，如果要推送到线上的话镜像越小越好，docker yum 的运行会生成大量缓存，那么我们就很有必要做一些清理工作了

```dockerfile 
RUN yum clean headers && \
  yum clean packages && \
  yum clean metadata && \
  rm -rf /usr/share/man
```

### 声明镜像运行时入口点

> 即容器运行时执行的第一个命令，如果不是 init 的话很有可能部分特权命令无法运行，例如 chkconfig

```dockerfile
ENTRYPOINT ["/sbin/init"]
```

### 合并 dockerfile

> dockerfile 中的每个指令都会单独生成一层镜像，这样势必会增加我们的镜像体积
> 通常做法是尽可能把多条指令整理顺序合并为一条，就可以有效减小镜像体积

```dockerfile 
FROM centos

# 复制两个repo
COPY conf/tsinghua-base.repo /etc/yum.repos.d/CentOS-Base.repo
COPY conf/nginx.repo /etc/yum.repos.d/nginx.repo

# 安装组件和相关包
RUN yum makecache && \
  yum -y install nginx && \
  chkconfig nginx on && \
  yum install -y epel-release && \
  rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum update -y && \
  yum install -y --enablerepo=remi --enablerepo=remi-php72 \
  php \
  php-openssl \
  php-curl \
  php-bcmath \
  php-devel \
  php-mbstring \
  php-mcrypt \
  php-mysqlnd \
  php-pdo \
  php-gd \
  php-xml \
  php-opcache \
  php-fpm && \
  chkconfig php-fpm on && \
  yum clean headers && \
  yum clean packages && \
  yum clean metadata && \
  rm -rf /usr/share/man

# 声明入口点
ENTRYPOINT ["/sbin/init"]
```

## 测试镜像可用性

- 构建镜像

> 值得注意的是 nginx 官方 repo 并不是很稳定 , 运行时可能会出错 , 重试几次一般都可以成功
> 如果是其他类型的错误，那么就要检查环境以及 dockerfile 有没有问题

```bash
docker build . -t first-build
```

- 带有特权启动一个后台运行的容器，将会返回一个ID

> 使用了 --privileged 选项之后，容器会拥有真的 root 权限，否则就只有本地普通用户权限．容器中执行了某些特殊操作（例如 systemctl）时才需要该选项

```bash
docker run -d --privileged first-build
```

- 测试镜像的运行状况

```bash
docker exec -it ( docker run 命令返回的ID ) ps aux | grep '[nginx|php]'
```

如果返回结果类似这样，那么说明我们的操作是正确的

```bash
> docker exec -it cca6 ps aux | grep '[nginx|php]'
root         1  0.0  0.0  43112  4888 ?        Ss   09:15   0:00 /sbin/init
root        17  0.0  0.0  39096  6476 ?        Ss   09:15   0:00 /usr/lib/system
root        29  0.1  0.0  35100  3308 ?        Ss   09:15   0:00 /usr/lib/system
root       370  0.0  0.1 371588 21424 ?        Ss   09:15   0:00 php-fpm: master
root       381  0.0  0.0  24264  2784 ?        Ss   09:15   0:00 /usr/lib/system
dbus       386  0.0  0.0  58000  4164 ?        Ss   09:15   0:00 /usr/bin/dbus-d
root       418  0.0  0.0  46432   980 ?        Ss   09:15   0:00 nginx: master p
nginx      421  0.0  0.0  46832  3512 ?        S    09:15   0:00 nginx: worker p
root       564  0.0  0.0   8096  1820 tty1     Ss+  09:15   0:00 /sbin/agetty --
apache     822  0.0  0.0 371588 12468 ?        S    09:15   0:00 php-fpm: pool w
apache     825  0.0  0.0 371588 12468 ?        S    09:15   0:00 php-fpm: pool w
root      2859  0.0  0.0  51752  3448 pts/0    Rs+  09:21   0:00 ps aux
```

- 此时如果使用了端口映射来启动镜像，那么你甚至可以在本地浏览器里看到 nginx 的默认欢迎页

```bash
docker run -d --privileged -p 8080:80 first-build
```

![]({{ env.cdn_accelerate }}/2019/04/149cdfb69defd39fb460f96c4e7f476a.png)

---------------------------

## 推送镜像到阿里云容器服务

- 注册阿里云命名空间

> 进入阿里云镜像控制台，
> [https://cr.console.aliyun.com/cn-zhangjiakou/instances/repositories](https://cr.console.aliyun.com/cn-zhangjiakou/instances/repositories)

界面大概长像这样
![]({{ env.cdn_accelerate }}/2019/04/7a1050655a4449c7531d2ac62f7aaa85.png)

- 使用镜像加速器

点开左下角的镜像加速器[https://cr.console.aliyun.com/cn-zhangjiakou/instances/mirrors](https://cr.console.aliyun.com/cn-zhangjiakou/instances/mirrors)
，你会看到你专属的加速链接
![]({{ env.cdn_accelerate }}/2019/04/59f2b7646e26c97a4715700967a21a6f.png)

> 找到你的操作系统，逐条执行即可，本文使用 Ubuntu 版本．
> 可见执行很顺利，没有任何异常

![]({{ env.cdn_accelerate }}/2019/04/66869bfc8b3daca4cb8ae0c1dba214bd.png)

- 登录到阿里云docker仓库

```bash
sudo docker login --username=你的阿里云用户名 registry.cn-zhangjiakou.aliyuncs.com
Password: 你的阿里云密码
Login Succeeded
```

- 建立命名空间

点击左侧的命名空间，点击创建命名空间，输入你的命名空间名称

> 命名空间可以理解为镜像所属的组织     
> 例如: centos 镜像的全名是 docker.io/centos，docker.io 就是centos镜像的命名空间，但是docker.io这个命名空间下却存在不止centos一种镜像．

> 公开和私有是指镜像是否可以在阿里云镜像市场中被大众查看和是否能够不需要任何权限拉取

![]({{ env.cdn_accelerate }}/2019/04/81d4bbbd66369f320252243e1ae4659e.png)

- 建立仓库

刚才我们已经创建好了命名空间，那么接下来就是创建仓库了．
> 仓库可以理解为组织创建的软件包包名     
> 例如: centos 镜像的全名是 docker.io/centos，centos 就是docker.io的一个仓库（软件），同时centos这个软件可以有很多个版本．

进入 [https://cr.console.aliyun.com/cn-zhangjiakou/instances/repositories](https://cr.console.aliyun.com/cn-zhangjiakou/instances/repositories)
仓库页面 , 点击新建仓库.

命名空间选择刚才创建好的，摘要即为镜像简介．

![]({{ env.cdn_accelerate }}/2019/04/b478f094bf761b80290157680ee53cce.png)

点击下一步，代码源选择本地仓库

![]({{ env.cdn_accelerate }}/2019/04/82b3930920ec638bb070436dd51fde19.png)

点击创建镜像仓库之后，就会发现页面上多了一行数据，说明创建成功

![]({{ env.cdn_accelerate }}/2019/04/6bae615bf44f1ff5f1707bde58c94b69.png)

鼠标放到那个下载一样的图标上，会看到仓库的专属地址

- 修改镜像名

我们要把我们刚才构建的一个叫做 first-build 的镜像推送到阿里云仓库中．首先我们使用 `docker images | grep first-build`
查找到它镜像ID．接下来我们修改镜像的名字为符合docker第三方仓库的镜像名格式．

> 第三方镜像仓库镜像名格式：仓库地址/组织/镜像名:镜像版本号

> 以阿里云为例：阿里云仓库地址/命名空间/仓库名:版本 registry.cn-zhangjiakou.aliyuncs.com/leasn-docker/learn-docker:1

然后执行以下命令来修改：

```bash
docker tag 3482e8529a90 registry.cn-zhangjiakou.aliyuncs.com/leasn-docker/learn-docker:1
```

再次使用 `docker images | grep first-build` 发现已经找不到了，因为它的名字已经变掉了

- 推送镜像

```bash
sudo docker push registry.cn-zhangjiakou.aliyuncs.com/leasn-docker/learn-docker
```

![]({{ env.cdn_accelerate }}/2019/04/2199353665a55c00b2952480e23714e4.png)
等所有的 Pushing 运行结束之后我们会发现[阿里云仓库](https://cr.console.aliyun.com/repository/cn-zhangjiakou/leasn-docker/learn-docker/images)中多了一个版本．

![]({{ env.cdn_accelerate }}/2019/04/6fd18dbbfaa43a5abf7d39a86b009f01.png)

至此，镜像已经推送成功．我们已经可以基于阿里云的支持，在全世界范围内使用我们的镜像．

**对于向开源事业无私奉献的阿里云致敬**

---------------------------

## 封装项目运行镜像

> 现在我们就要研究怎么让镜像跑我们自己的项目了

- 这次就可以基于我们推送阿里云的镜像了

```Dockerfile
FROM registry.cn-zhangjiakou.aliyuncs.com/leasn-docker/learn-docker:1
```

- 复制我们准备好的 nginx.conf 到镜像里

```bash
COPY nginx.conf /etc/nginx/conf/nginx.conf
```

nginx.conf 全文

```nginx
user nginx;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    server {
        listen       80;
        server_name  127.0.0.1;
        root         /var/www/html;
        index        index.php;

        location ~ \.php($|/) {
            fastcgi_pass    127.0.0.1:9000;
            fastcgi_index   index.php;
            fastcgi_split_path_info ^(.+\.php)(.*)$;
            fastcgi_param   PATH_INFO $fastcgi_path_info;
            fastcgi_param   SCRIPT_FILENAME   $document_root$fastcgi_script_name;
            include         fastcgi_params;
        }
    }
}
```

- 复制工程源码到镜像里

在当前目录建立我们的工程，并且假装我们的工程只有一个文件，它位于./proj

![]({{ env.cdn_accelerate }}/2019/04/10ddb87f6917a95f41f4e6781d56271b.png)

复制我们的工程到镜像里并为运行目录加权

```bash
COPY proj /var/www/html
RUN chmod -R 755 /var/www/html/
```

Dockerfile 全文

```Dockerfile
FROM registry.cn-zhangjiakou.aliyuncs.com/leasn-docker/learn-docker:1
COPY nginx.conf /etc/nginx/nginx.conf

COPY proj /var/www/html
RUN chmod -R 755 /var/www/html/
```

构建镜像并使用端口映射运行我们的容器

```bash
docker build .
docker run --privileged -d -p 8080:80 773ed8872493
```

如果不出意外，我们已经可以在本地的 127.0.0.1:8080 中看到 phpinfo() 了

![]({{ env.cdn_accelerate }}/2019/04/2a54fe102d4b0b7ea52293c7709efac6.png)

既然phpinfo已经看到了，那么如何让整个工程跑起来我就不赘述了．

值得一提的是，推送新版本到

## 使用 docker-compose 编排镜像

> [Compose](https://docs.docker.com/compose/)
> 是一个用于定义和运行多容器Docker应用程序的工具。使用Compose，您可以使用YAML文件来配置应用程序的服务。然后，使用单个命令，您可以从配置中创建并启动所有服务

> 该应用使用 `sudo apt install docker-compose` 安装

- 调整目录结构

> 在我们现在工作目录外面再加一层目录，大致是: 工作目录 > docker-learn (以前的工作目录) && docker-compose.yaml

- 编辑 docker-compose.yaml

> docker-compose 包含多个指令，并采用[yaml](https://yaml.org/)语言编写．可以理解为把我们在命令行运行的 run 命令参数写到了文件里，经过统一的工具协调启动．

主要指令:

> services 需要编排的服务列表，本次我们主要编写一个叫做 docker-learn 的服务

```yaml
version: 3
services: 
```

- docker-compose.yaml 全文

```yaml
version: '3'
services:
    # 服务名
    docker-learn:
        # 该服务是否以特权启动 , 即 --privileged
        privileged: true
        # 构建
        build:
            # 构建上下文 即: docker build ./docker-learn
            context: ./docker-learn
        # 端口映射，即 -p 80:80
        ports:
            - 80:80
        # 对外暴露的端口 ，相当于Dockerfile 的 EXPOSE 指令 
        # EXPOSE指令只是声明了容器应该打开的端口，但是并没有实际上将它打开!
        # 该选项在 docker run -it -P(大写) 时会真的起作用
        expose:
            - 80
        # 目录映射 , 相当于 docker run -v 
        # volumes:
        #	- ./logs/php-fpm:/var/log/php-fpm
        # 	- ./logs/nginx:/var/log/nginx
```

- 使用docker-compose 启动镜像

关闭其他运行中的容器，以免与我们即将运行的容器冲突

```bash
 docker ps | awk '{print $1}' | grep -v CON | xargs docker kill
```

启动镜像

> 单独 up 不使用服务名会运行 services 中定义的所有容器．
> 如果services中有多个服务，那么可以使用 up 服务名来单独 up 一个服务容器
> up 默认会使用 build:context 中的 Dockerfile 文件编译好的镜像进行容器启动，--build 是强制再次使用 Dockerfile 进行重新编译镜像再启动 . 但是 --build 仍然会使用已经存在的镜像层的缓存
> --force-recreate 重新编译时不使用镜像层缓存 , 完全重新编译

> 如果出现 bind: address already in use 类似的提示 , 就换一个 ports 里的绑定端口重试

```bash
docker-compose up [docker-learn] [--build] [--force-recreate]
```

![]({{ env.cdn_accelerate }}/2019/04/f513bcc6b1467f0516550c126f9e1495.png)

我们发现现在访问 127.0.0.1:8080 仍然可以看到 phpinfo

## 接入 jenkins 进行持续集成

1. gitlab pipeline 更加简单好用，所以不再使用 jenkins
2. 也可以参考本站的 drone 教程

## 接入 kubernetes

> 更新中

# 大功告成

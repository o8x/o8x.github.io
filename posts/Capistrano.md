---
display-name: Capistrano
date: 2018-04-17 17:32:14
tags: [ "Linux" ]
---

# 安装Capistrano

<!--more-->
> Capistrano 是由ruby驱动的开源程序 , 所以可以方便的使用包管理器 `gem` 来安装 ,并且它依赖 ruby

1. 安装ruby和gem

```shell
sudo yum -y insatll ruby gem
```

2. 替换gem源到国内 ,这里选用 raby-china 源

```shell
gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
gem sources -l
https://gems.ruby-china.org
```

3. 安装Capistrano

```shell
gem install capistrano
```

# 建立测试的GIT项目

> 既然需要把GIT仓库部署到服务器上 ,那么我们首先应该有个GIT仓库
> 以coding为例 ( gayhub私有项目需要付费 ,可以我并没有钱 ).

1. 创建一个私有项目
   ![]({{ env.cdn_accelerate }}/2018/04/1cfc0d7119ff3f7a23b6ce04583f20d6.png)

2. 添加部署公钥
    - 得到部署公钥 , 以linux为例 : cat ~/.ssh/id_rsa.pub
    - ![]({{ env.cdn_accelerate }}/2018/04/fa961428cba3aa37caa3e9897da23716.png)
      然后点击右上角的 ,添加部署公钥
    - ![]({{ env.cdn_accelerate }}/2018/04/26d5f436e0d764f9ba03ededb6aacf7a.png)
      粘贴刚才得到公钥到这里 ,不需要授予推送权限 ,点击新建即可

# 建立Capistrano工程

> 上述和以下操作都是在本地进行 , 而非远程服务器上

进入到一个你喜欢的目录里 , 然后使用`gem insatll` 来初始化一个项目
如下这样就是创建成功了
![]({{ env.cdn_accelerate }}/2018/04/0211bdc4c3f8a9d7f24c5112f13ee4ef.png)

# 修改Capistrano配置

> 需要修改3个配置 , 项目名 , 可访问的GIT项目地址 ,需要自动部署的机器用户名与IP地址
> 值的一提的是 ,服务器与GIT地址都需要可以免密码访问

1. 配置项目名与GIT仓库地址
   使用你喜欢的编辑器打开 deploy 目录下的deploy.rb 文件 ,并更新如下这些配置
   ![]({{ env.cdn_accelerate }}/2018/04/1e1c2d8c0f675e713c9b282066b3cb62.png)

1. 配置各个环境的机器配置

> Cap可以配置多种身份 ,例如dba使用的db ,前置web服务器web ......

    这里只配置一台前置服务器 ,以web身份为例 .
    
    使用你喜欢的编辑器打开 deploy 目录下的deploy.rb 文件 ,并更新如下这些配置 ,多台机器以空格分割 ,这里我添加了两台 .
    
    **确保你添加的这些机器可以不使用密码进行ssh远程登陆 ,否则一定会部署失败**
    
    ![]({{ env.cdn_accelerate }}/2018/04/19040d38caa376baa2229d5efb357d58.png)

# 配置远程服务器

> 使Cap部署时可以不需要密码 ,本来不打算写 ,想了想还是补上了

1. 用你喜欢的方法使用root账户登陆需要部署的远程服务器

2. 把本地的公钥使用你喜欢的方法追加到 `~/.ssh/authorized_keys 文件中
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

3. 最终的authorized_keys文件就像这样子
   ![]({{ env.cdn_accelerate }}/2018/04/5787997bd0d283cc27da173d72b5958e.png)

# 开始部署

1. 把最新的代码推送到刚刚创建的GIT仓库中 ,当然也可以不用推送 ,空项目默认会有README.md

2. 然后初始化Capistrano的目录执行cap production deploy
   ![]({{ env.cdn_accelerate }}/2018/04/07e5551d8a1a451c445728c019f6d8df.png)

3. 等待好消息

> 此时自动部署就已经完成了 ,接下来我们来看看远程服务器中是什么样子的

![]({{ env.cdn_accelerate }}/2018/04/f0709921e7f4d96be0e60bfbdbe63481.png)

# 查看远程服务器

> 看到这里 ,所有的疑惑大概都解开了
> Cap的核心原理就是 ,当客户端进行推送时 ,自动登陆到各个身份的各个服务器 ,然后自动配置文件中的部署目录 , 然后拉取最新的代码到release目录中 ,并把current软链接到最新的代码目录.
> 例如laravel项目 . nginx的root就可以配置到 `path/current/public` , 然后每次推送之后 ,Cap都会帮我们把current的代码变成最新拉取的那一份 ,我们提供的服务也就随之更新了 .

1. 目录结构 , 如下
   .
   ├── current -> /www/wwwroot/gly.inc.api.binger.site/releases/20180417091707
   ├── releases
   │ └── 20180417091707
   ├── repo
   ├── revisions.log
   └── shared

2. 展示
   ![]({{ env.cdn_accelerate }}/2018/04/8dc801255398c4831a7a7bae3c6726dc.png)

# 使用后置钩子

在 config/deploy.rb 文件中添加以下代码：

```ruby
namespace :deploy do
    desc "Build"
    after :updated, :build do
        on roles(:web) do
            within release_path do
                # 自动执行安装Composer依赖
                execute :composer, "install"
                # 修改当前目录中文件中的所有者 ,使nginx可以访问他们
                execute :chown, "-R -f www:www ./"
                # 修改当前目录中文件的权限 ,使文件不会被其他用户随意修改
                execute :chmod, "-R 755 ./"
            end
        end
    end
end
```

> 这样Cap就会在拉取之后进行Composer依赖安装和权限修改了

---
display-name: 编译安装日志分析平台 elk + filebeat
date: 2018-08-22 14:02:38
tags: [ "Linux" ]
---

# 开始之前

> 假设您已经拥有一台内存至少1G的`linux`计算机或虚拟机并且安装了screen命令

# 下载安装包

>
java [http://www.oracle.com/technetwork/java/javase/downloads/index.html](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
> elk [https://www.elastic.co/cn/products](https://www.elastic.co/cn/products)

- 下载安装包

  ![]({{ env.cdn_accelerate }}/2018/08/2ea20d9628f1eda14d55d9317ff836e3.png)

- 传输到服务器中 , 如果是linux里直接下载则可以忽略这一步

    ```bash
     scp .\jdk-8u181-linux-x64.tar.gz \
         .\kibana-6.3.2-linux-x86_64.tar.gz \ 
         .\logstash-6.3.2.tar.gz \
         .\elasticsearch-6.3.2.tar.gz \
         root@192.168.1.147:/opt
    ```

------------------------------------------

# 准备安装

> 接下来登陆到linux环境     
> ssh root@192.168.1.147

解压刚才传输的文件，并把删除原文件

```bash
cd /opt/ && ls | xargs -I {} tar xzvf {} && rm -f ./*.tar.gz
```

![]({{ env.cdn_accelerate }}/2018/08/00defb7f3681677d16dfba17b2b11a27.png)

因为es是不能运行在root用户的 , 即使可以也不建议使用 root     
因此, 我们可以单独创建一个用户来运行elk

```bash
useradd elk
```

给elk的文件目录变更用户

```bash
chown -R elk:elk ./*
```

--------------------------------------------

# 开始安装

> 请自行更换 /opt 为你的实际目录

## java 8

把以下几行添加到 /etc/bashrc 的末尾

```bash
export JAVA_HOME=/opt/jdk1.8.0_181
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
```

使环境变量生效

```bash
source /etc/bashrc
```

验证安装是否成功

```bash
java -version
```

![]({{ env.cdn_accelerate }}/2018/08/0b61d2f96ecfadad6e241beb65d239ae.png)

此时java安装成功

## elasticsearch

切换到elk用户

```bash
su elk
```

使用 screen 开始一个新会话

```bash
screen -S es
```

修改默认的配置文件

```bash
sed -i "s/#\ network.host:\ 192.168.0.1/network.host:\ 0.0.0.0/" /opt/elasticsearch-6.3.2/config/elasticsearch.yml
sed -i "s/#\ http.port/http.port/" /opt/elasticsearch-6.3.2/config/elasticsearch.yml
```

启动es

```bash
/opt/elasticsearch-6.3.2/bin/elasticsearch
```

如果遇到这个错误

![]({{ env.cdn_accelerate }}/2018/08/1e74810b8342aa4085e8e3c375e5e306.png)

执行命令：

```bash
su root
sysctl -w vm.max_map_count=262144
sysctl -a | grep vm.max_map_count
exit
```

![]({{ env.cdn_accelerate }}/2018/08/994c57401fdff6497a2f72955354ad38.png)

再尝试启动 , 如果遇到这个错误

![]({{ env.cdn_accelerate }}/2018/08/1572e2c4bd8a59a663bbd8f941cebb34.png)

回到root账户 , 修改/etc/security/limits.conf 添加如下行并重启计算机 :

```bash
elk        hard    nofile           262144
elk        soft    nofile           262144
```

再尝试启动 , 一般会看到这个东西
![]({{ env.cdn_accelerate }}/2018/08/97dc7bb84c2996e1a8ae58ef380280a0.png)

此时es启动成功 , 然后我们利用curl测试一下

```bash
curl 127.0.0.1:9200
```

如果返回这个东西说明真的成功了 , 返回别的这里不讨论 , 一律视为失败 , 请参考日志进行排错

![]({{ env.cdn_accelerate }}/2018/08/b49926630d4712336fc76c3894e739dd.png)

如果需要在浏览器访问, 还需要关闭防火墙和selinux

```bash
su root
systemctl stop firewalld.service
setenforce 0
exit 
```

浏览器访问

![]({{ env.cdn_accelerate }}/2018/08/636dfbdefdf917f129ae10cd3f4724e2.png)

至此es安装和启动完毕

我们用组合键回到默认会话

```bash 
Ctrl A + d
```

## logstash

logstash 安装和配置比较简单 , 但是需要创建一个文件

创建输入输出配置文件

```bash
tee /opt/logstash-6.3.2/config/logstash-io.conf <<-'EOF'
input {
    file {
        path => "/var/log/dev.log"
        start_position => "beginning"
    }
}

output {    
    elasticsearch {        
        hosts => ["192.168.1.147:9200"]
    }
}
EOF
```

*默认配置文件在 /*opt/logstash-6.3.2/config/logstash.yml 可以按需修改*

尝试启动logstash

```bash
screen -S logstash
/opt/logstash-6.3.2/bin/logstash -f /opt/logstash-6.3.2/config/logstash-io.conf
```

如果没有error , 就启动完成了

![]({{ env.cdn_accelerate }}/2018/08/77d011a3d1d81358b0965c0ba985e5d2.png)

如果需要测试是否真的启动完成 , natstat 和 telnet 这两个命令都可以

```bash
telnet 127.0.0.1 9600 || netstat -anp | gerp 9600
```

至此logstash安装和启动完毕

我们用组合键回到默认会话

```bash 
Ctrl A + d
```

## kibana

kibana 只需要修改基础配置文件即可启动 , 并进行浏览器测试

修改配置文件

```bash
sed -i "s/#elasticsearch.url:\ \"http:\/\/localhost:9200\"/elasticsearch.url:\ \"http:\/\/192.168.1.147:9200\"/" /opt/kibana-6.3.2-linux-x86_64/config/kibana.yml
sed -i "s/#server.host:\ \"localhost\"/server.host:\ \"192.168.1.147\"/" /opt/kibana-6.3.2-linux-x86_64/config/kibana.yml
```

启动

```
/opt/kibana-6.3.2-linux-x86_64/bin/kibana
```

返回如下信息则说明启动成功

![]({{ env.cdn_accelerate }}/2018/08/6200a76fe5891ae61f03c0c94f5926e7.png)

打开浏览器 输入http://192.168.1.147:5601 可以看到如下画面

![]({{ env.cdn_accelerate }}/2018/08/117178fb813a89b92d60287c07233b52.png)

至此kibana安装和启动完毕

我们用组合键回到默认会话

```bash 
Ctrl A + d
```

## 测试

如果顺利的到了这里 , 那么elk其实已经可以使用了 , filebeat不是必须的.
我们找来一些日志验证一下前面工作的正确性

- 上传日志到服务器 :
    ```bash
    scp ./dev.log root@192.168.1.147:/var/log/
    ```


- 这是一份普通的nginx日志

  ![]({{ env.cdn_accelerate }}/2018/08/c9de47cf3622c095d7a3a44a2f356cb7.png)


- 用screen -r回到logstash会话

  ![]({{ env.cdn_accelerate }}/2018/08/f866c7bb6113fbd6bfb6645c41fde156.png)


- 界面一闪而过 , 回到了这里

  ![]({{ env.cdn_accelerate }}/2018/08/6349e1aee52f0463251d289aa041c92a.png)


- ctrl +c 停止它按上方向键 , 再启动它


- 稍候片刻启动完成, 回到kibana

- 在首页创建通配符索引 logstash*

  ![]({{ env.cdn_accelerate }}/2018/08/ada511c00496a9f6ce40060deaa189d5.png)
  ![]({{ env.cdn_accelerate }}/2018/08/77b7d19031e5b8790d2ef7cd55119bb0.png)

- 如果next是可点击的 , 那就到了这里
  ![]({{ env.cdn_accelerate }}/2018/08/a64c1feb48c40c7eb1379a311c68d657.png)


- 选择@timestamp 继续下一步
  ![]({{ env.cdn_accelerate }}/2018/08/b68bd737eb06357a4fb4ce918fbc0031.png)


- 然后就开启ELK的世界了

![]({{ env.cdn_accelerate }}/2018/08/14ee8a3abba4b5ef7137fe3e9ffa36b8.png)

- 首页如下
  ![]({{ env.cdn_accelerate }}/2018/08/c3b099c6125629173b602064bf315a86.png)

## filebeat

### 取得安装包

和准备工作一样 , 从官网获得filebeat的安装包并解压

![]({{ env.cdn_accelerate }}/2018/08/f0675c820c42e4be85c9e9fec9fc5e06.png)

### 修改配置

修改filebeat的配置文件 , 和上面一样我们使用sed修改配置文件

```bash
# 开启log输入
sed -i "s/enabled: false/enabled: true/" /opt/filebeat-6.3.2-linux-x86_64/filebeat.yml

# log存放的位置 , 位置分隔符 / 需要用 \ 转义
sed -i "s/-\ \/var\/log\/*.log/\/var\/log\/dev.log/" /opt/filebeat-6.3.2-linux-x86_64/filebeat.yml

# 关闭默认的输出到es
sed -i "s/output.elasticsearch:/# output.elasticsearch:/" /opt/filebeat-6.3.2-linux-x86_64/filebeat.yml
sed -i "s/hosts:/# hosts:/" /opt/filebeat-6.3.2-linux-x86_64/filebeat.yml

# 打开输入到logstash
sed -i "s/#output.logstash:/output.logstash:/" /opt/filebeat-6.3.2-linux-x86_64/filebeat.yml
sed -i "s/##\ hosts:/hosts:/" /opt/filebeat-6.3.2-linux-x86_64/filebeat.yml
```

我们还需要修改 logstash 的配置文件才能使用 filebeat 来自动捕获数据

### 修改logstash的输入输出配置

> 为了避免你已经手动修改了配置文件 , 我们不再使用sed为改为手动修改配置文件

使用你喜爱的编辑器打开 /opt/logstash-6.3.2/config/logstash-io.conf , 删除掉input代码块并在原file代码块的位置 ,增加如下内容并保存

```nginx
beats{
    port => 5044
}
```

最终配置文件大概会是这个样子

```nginx
input {
    beats{
        port => 5044
    }
}

output {    
    elasticsearch {        
        hosts => ["192.168.1.147:9200"]
    }
}
```

### 重启logstash

```bash
screen -r logstash
^C^C^C^C....
/opt/logstash-6.3.2/bin/logstash -f /opt/logstash-6.3.2/config/logstash-io.conf
```

如果正常启动并进入监听状态 , 我们回到刚才的会话

```bash 
screen -r beats
```

### 启动filebeat

```bash
/opt/filebeat-6.3.2-linux-x86_64/filebeat -e -c /opt/filebeat-6.3.2-linux-x86_64/filebeat.yml
```

如果配置正确 , 那么一般不会遇到什么问题

### 测试filebeat

因为我们已经在 /var/log/dev.log 这份配置文件 , 那么我们就增加它的内容 , 来测试filebeat是否正常扫描和输出到logstash

> 里使用死循环来增加日志内容 , 数据是重复的 , 仅可用于验证filebeat的工作    
> 第三行的 while 是每隔1秒就复制 tmp.log 的内容到 dev.log 的末尾     
> 您随时可以用 ^C [Ctrl +c] 来终止复制过程

```bash
su root
cp /var/log/dev.log /tmp/tmp.log
while true ; do cat /tmp/tmp.log >> /var/log/dev.log ; sleep 1 ; done
```

然后我们查看浏览器的kibana , 右上角倒数第二个按钮, 开启自动刷新并选择五秒

![]({{ env.cdn_accelerate }}/2018/08/679f8dd05cf1daecdb1279d9cba57d7f.png)

如果一切无误, 坐等5秒 , 就会发现有新的数据展示在页面上
> 此时可以明显的观察到 , 红框的时间部分每隔5秒就会变化一次

![]({{ env.cdn_accelerate }}/2018/08/96439dd760260f29448babbbe25d1392.png)


> 因为我们已经保证了没有 filebeat 时elk平台工作是正常的     
> 那么如果现在elk不再正常工作了 , 就从 filebeat 大节检查和排错 ,问题最大可能是sed在你的计算机中没有生效    
> 那么就检查配置文件开始 debug 吧     
> 同时也欢迎您在本文章下留言说明你遇到的问题

# 大功告成

---------------------------------------------

# 扩展部分

-- 未完待续

## x-pack

-- 未完待续

## ik分词

-- 未完待续

## elasticsearch query language

-- 未完待续

## 使用语言级软件, 向logstash推送数据的方法

### TCP

-- 未完待续

### UDP

-- 未完待续

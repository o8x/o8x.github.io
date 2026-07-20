---
display-name: 为elk加入redis, 替换下beats.
date: 2018-08-25 10:25:30
tags: [ "Linux", "elk" ]
---

# 为elk加入redis, 替换下beats

这是elk的第二篇文章

> elk支持多种输入输出方法 ,本文章主要描述通过redis做队列中间件 ,缓解elk平台的压力

# 使用场景

> 数据不可控时 ,例如日志不是文件 , 而是由TCP直接推送到elk的 ,filebeats就无法使用了

> 当然redis是可以和beats一起使用的, 例如beats读取文件解析后输出到redis ,再由elk正常流程处理, 具体的这里不做讨论

# 优势

> 在通过logstash之前走redis , 分散压力不至于logstash负载太高 ,处理缓慢甚至宕机

# 流程图

![]({{ env.cdn_accelerate }}/2018/08/Drawing2-1.png)

# redis

## 什么是redis

> Redis是一个支持多种数据结构的开源（BSD许可）内存型数据库 , 除此之外它甚至可以被用作持久化数据库，缓存器和消息队列 [查看更多](https://redis.io/topics/introduction)

## 如何安装redis

极其简单 ,使用yum或下载源码make即可 , 不再赘述

- yum安装

```bash
yum -y install redis
```

- 源码安装

```bash
cd /opt
wget http://download.redis.io/releases/redis-4.0.11.tar.gz || curl -O http://download.redis.io/releases/redis-4.0.11.tar.gz

tar xzvf redis-4.0.11.tar.gz && \
    cd redis-4.0.11 && \ 
    yum -y install gcc && \
    make
```

## 配置redis

可以不配置 ,但是笔者需要从外部链接redis ,所以把监听地址修改为局域网IP    
大家按需执行即可

**配置文件位置:**   
yum :  `/etc/redis.conf`    
源码 : `/opt/redis-4.0.11/redis.conf`

```bash
# 修改监听地址
sed -i 's/^bind 127.0.0.1/bind 192.168.1.147/' /opt/redis-4.0.11/redis.conf
# 修改监听端口
sed -i 's/^port 6379/port 6379/' /opt/redis-4.0.11/redis.conf
```

## 启动redis

这里也分两种      
yum安装启动方法

```bash
systemctl redis start
```

源码安装启动方法

```bash
/opt/redis-4.0.11/src/redis-server /opt/redis-4.0.11/redis.conf &
```

### 启动完成就像这样 , 然后回车即可

![]({{ env.cdn_accelerate }}/2018/08/d68502f692c25ce1eeab81d16b9244fb.png)

# 配置elk

和第一篇中为elk加入beats一样 , 只需要编辑logstash的配置文件就可以了

### 修改logstash的输入输出配置

> 为了避免你已经手动修改了配置文件 , 我们不再使用sed为改为手动修改配置文件

使用你喜爱的编辑器打开 /opt/logstash-6.3.2/config/logstash-io.conf

在input代码块中增加如下内容并保存

```nginx
redis {
    key => "redis_log"
    data_type => "list"
    type => "redis"
    host => "192.168.1.147"
    port => "6379"
    threads => 12
    #　如果存进redis的数据是json才需要这一行
    codec => "json"
}
```

在input代码块的同级增加如下内容并保存
> 这里是处理nginx日志的过滤器 , 稍候会讲里面的grok语法

```nginx
filter {
 if [type] == "redis" {
    grok {
      match => { "message" => "%{IPORHOST:remote_ip} - - \[%{HTTPDATE:datetime}\] \"(:?%{WORD:request_method} %{NOTSPACE:uri}) (:?HTTP/%{NUMBER:http_version})\" (:?%{NUMBER:http_code}) (:?%{NUMBER:contents_length}) \"(:?%{NOTSPACE:domail})\" \"(:?%{DATA:ua}) \((:?%{DATA:os})%{NUMBER:os_version}\) %{DATA}\) %{DATA:browser}/%{DATA:browser_version} (:?%{DATA:safari_version})\"" }
    }

    geoip {
      source => "client_ip"
    }

    date {
      match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
    }
  }
}
```

修改output代码为如下这样
> 这为了按类型划分索引

```nginx
output {
    if [type] == "redis" {
        elasticsearch {
            hosts => ["192.168.1.147:9200"]
            manage_template => false
            index => "redis-%{+YYYY.MM.dd}"
        }
    } else if [type] == "beats" {
        elasticsearch {
            hosts => ["192.168.1.147:9200"]
            manage_template => false
            index => "beats-%{+YYYY.MM.dd}"
        }
    } else {
        elasticsearch {
            hosts => ["192.168.1.147:9200"]
            manage_template => false
            index => "unkown-%{+YYYY.MM.dd}"
        }
    }
}
```

最终配置文件大概会是这个样子

```nginx
input {
    beats {
        port => 5044
        type => "beats"
    }

    redis {
        key => "redis_log"
        data_type => "list"
        type => "redis"
        host => "192.168.1.147"
        port => "6379"
        threads => 12
        codec => "json"
    }
}

filter {
 if [type] == "redis" {
    grok {
      match => { "message" => "%{IPORHOST:remote_ip} - - \[%{HTTPDATE:datetime}\] \"(:?%{WORD:request_method} %{NOTSPACE:uri}) (:?HTTP/%{NUMBER:http_version})\" (:?%{NUMBER:http_code}) (:?%{NUMBER:contents_length}) \"(:?%{NOTSPACE:domail})\" \"(:?%{DATA:ua}) \((:?%{DATA:os})%{NUMBER:os_version}\) %{DATA}\) %{DATA:browser}/%{DATA:browser_version} (:?%{DATA:safari_version})\"" }
    }

    geoip {
      source => "client_ip"
    }

    date {
      match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
    }
  }
}

output {
    if [type] == "redis" {
        elasticsearch {
            hosts => ["192.168.1.147:9200"]
            manage_template => false
            index => "redis-%{+YYYY.MM.dd}"
        }
    } else if [type] == "beats" {
        elasticsearch {
            hosts => ["192.168.1.147:9200"]
            manage_template => false
            index => "beats-%{+YYYY.MM.dd}"
        }
    } else {
        elasticsearch {
            hosts => ["192.168.1.147:9200"]
            manage_template => false
            index => "unkown-%{+YYYY.MM.dd}"
        }
    }
}
```

然后和第一篇一样 , 使用screen启动elk

```bash
screen -S elk
/opt/elasticsearch-6.3.2/bin/elasticsearch & \
/opt/logstash-6.3.2/bin/logstash -f /opt/logstash-6.3.2/config/logstash-io.conf & \
/opt/kibana-6.3.2-linux-x86_64/bin/kibana &

# 本次不切换回去了
# Ctrl A + c
```

如果配置没有问题的话, 最后会输出12行 `[logstash.inputs.redis    ] Registering Redis...` 这样的句子
> 会输出12行因为我们在input部分指定了threads为12

然后我们再看一看熟悉的kibana , 并且做一些事情
> 如果启动完成但是看不到kibana ,就回到root关闭防火墙 `systemctl stop firewalld`

![]({{ env.cdn_accelerate }}/2018/08/10a8bd7143b381f4f30fd9eea325b573.png)

# 测试elk + redis

任何语言的redis客户端都可以向redis推送数据

测试逻辑
> 链接到redis后, 向redis_log这个list结构循环推送下面的日志内容

```nginx
127.0.0.1 - - [21/Aug/2018:06:00:32 +0800] "GET /api/index/game-type HTTP/1.0" 200 269 "http://yooooooooo.com/" "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36"
```

以php的predis客户端为例向redis推送数据
> [predis下载地址](https://github.com/nrk/predis)

```php
<?php
use Predis\Client;
require __DIR__ . '/src/Autoloader.php';

Predis\Autoloader::register();

// 使用predis来链接redis
$client = new Client('tcp://192.168.1.147:6379');
// 开始一个死循环
while (true) {
    // 每次向redis的redis_log这个list推送10000条数据
    foreach (range(0 ,10000) as $value) {
        $client->lpush('redis_log' ,'127.0.0.1 - - [21/Aug/2018:06:00:32 +0800] "GET /api/index/game-type HTTP/1.0" 200 269 "http://yooooooooo.com/" "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36"');

        echo "$value \n";
    }

    // 推送完成休息一秒 
    sleep(1);
}
```

运行这个php例子

```bash
php ./pushToRedis.php
```

假设链接没有问题 , 你会在elk那个终端里看到输出 , 我这里因为配置了json却输入的字符串 , 才会输出的全是错误

![]({{ env.cdn_accelerate }}/2018/08/48058c4dd5316bd740b6902e29ca495e.png)

### 在kibana建立redis索引

> 来到 management 部分

![]({{ env.cdn_accelerate }}/2018/08/95fd2fd7c7f91b4b369bced1745d146a.png)

![]({{ env.cdn_accelerate }}/2018/08/af19c683cb1aec32e72ff1e8d530500b.png)

一路下一步 ,创建完成

![]({{ env.cdn_accelerate }}/2018/08/b28e7e1cb4d4e18344b67f298a1320d7.png)

回到首页(一定到确保左上角是redis... 如果不是就点名字旁边的按钮来切换到redis) ,然后打开自动刷新 , 数据就会源源不断的渲染到页面上了

![]({{ env.cdn_accelerate }}/2018/08/c215e77c6e9cb18c48e75ba6a0c8ef5a.png)

并且我们发现 , 左侧是筛选条件和右侧的数据都多了很多字段 , 这就是修改配置文件时 ,加入的filter段的功劳

![]({{ env.cdn_accelerate }}/2018/08/e9a8c61874e2cc2d427a42fc543eb9f4.png)

# 大功告成

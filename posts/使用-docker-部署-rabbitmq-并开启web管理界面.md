---
display-name: 使用 docker 部署 rabbitmq 并开启web管理界面
date: 2019-04-25 17:37:50
tags: [ "Linux" ]
---

### 拉取 rabbitmq 镜像

```shell
$ docker pull rabbitmq
```

### 启动 rabbitmq 容器

```shell
$ docker run -d \
    --name rabbitmq \
    -p 5672:5672 -p 15672:15672 \ 
    -p 25672:25672 rabbitmq
```

### 开启 rabbitmq web管理界面

```shell
$ docker exec 2f32c7191004 rabbitmq-plugins enable rabbitmq_management
Enabling plugins on node rabbit@2f32c7191004:
    rabbitmq_management
The following plugins have been configured:
    rabbitmq_management
    rabbitmq_management_agent
    rabbitmq_web_dispatch
Applying plugin configuration to rabbit@2f32c7191004...
    The following plugins have been enabled:
    rabbitmq_management
    rabbitmq_management_agent
    rabbitmq_web_dispatch
  
started 3 plugins.
```

#### 配置rabbit开机自启动

> 以下内容加入到 /etc/rc.local 中

```shell
/usr/bin/systemctl start docker && \
    /usr/bin/docker start rabbitmq_container && \
    /usr/bin/logger "`date` rabbitmq container started"
```

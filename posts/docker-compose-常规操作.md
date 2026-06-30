---
display-name: docker-compose 常规操作
date: 2018-05-15 22:39:37
categories:
- Docker
- Linux
tags:  
- docker-compose
- docker
---


**启动所有服务 ，不一定全新**

```shell
$ docker-compose up
````

**全新的启动所有服务 ，不使用缓存**

```shell
$ docker-compose up -d --force-recreate 
$ docker-compose up -d --force-recreate --build
```

**关闭所有服务并删除容器**

```shell 
$ docker-compose down
```

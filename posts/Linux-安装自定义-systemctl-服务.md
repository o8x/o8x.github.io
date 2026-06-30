---
display-name: Linux 安装自定义 systemctl 服务
date: 2020-05-26 11:13:58
categories:
- Linux
tags:

- Linux
- systemd

---

> 实现对服务的更新和启动

`/usr/lib/systemd/system/` 或 `/etc/systemd/system/` 建立文件 `blog.service` 写入以下内容

```ini
[Unit]
Description = println.fun
Documentation = http://fun.println
After = network.target remote-fs.target nss-lookup.target

[Service]
ExecStart = /usr/bin/java -jar /opt/blog/current/target/println-0.1.jar --spring.profiles.active=qa
ExecReload = /bin/kill -s HUP $MAINPID
ExecStop = /bin/kill -s QUIT $MAINPID
PrivateTmp = true

[Install]
WantedBy = multi-user.target
```

## 具体含义：

- Unit.Description
  > 简介

- Unit.Documentation
  > 文档链接

- Unit.After
  > 本服务在哪些服务启动后才能启动

- Service.ExecStart
  > 使用完全路径的启动程序命令

- Service.ExecReload
  > 使用完全路径的重启程序的命令，$MAINPID 为当前服务的 PID ，简单的直接使用 kill 就可以重启.    
  > 复杂的可以指定一个脚本并把 PID 传入进去处理 , 例如 ExecReload=/bin/restart-blog.sh —pid=$MAINPID

- Service.ExecStop
  > 与 reload 一致，功能为关闭程序

- Install.WantedBy
  > 为面向的用户 ,multi-user.target 为多用户
- Sevice.Type
  `simple`
  > `simple`
  ，这是默认的Type，当Type和BusName配置都没有设置，指定了ExecStart设置后，simple就是默认的Type设置。simple使用ExecStart创建的进程作为服务的主进程。在此设置下systemd会立即启动服务，如果该服务要启动其他服务（simple不会forking），它们的通讯渠道应当在守护进程启动之前被安装好（e.g.
  sockets,通过sockets激活）。

  `forking`
  > `forking`，如果使用了这个Type，则ExecStart的脚本启动后会调用fork()
  函数创建一个进程作为其启动的一部分。当一切初始化完毕后，父进程会退出。子进程会继续作为主进程执行。这是传统UNIX主进程的行为。如果这个设置被指定，建议同时设置PIDFile选项来指定pid文件的路径，以便systemd能够识别主进程。

  `oneshot` , `onesh`
  > `oneshot` , `onesh`  的行为十分类似`simple`
  ，但是，在systemd启动之前，进程就会退出。这是一次性的行为。可能还需要设置RemainAfterExit=yes，以便systemd认为j进程退出后仍然处于激活状态。

  `dbus`
  `dbus`，这个设置也和`simple`很相似，该配置期待或设置一个name值，通过设置BusName=设置name即可。

  `notify`
  > notify，同样地，与simple相似的配置。顾名思义，该设置会在守护进程启动的时候发送推送消息(通过sd_notify(3))给systemd。

## 命令指南

> 使服务生效:

    systemctl enable blog

> 启动服务

    systemctl start blog

> 重启服务

    systemctl restart blog

> 关闭服务

    systemctl stop blog

> 查看服务状态

    systemctl status blog

> 加入开机启动

    systemctl enable blog

> 显示服务状态是否 Active

    systemctl is-active blog

> 从开机启动中删除

    systemctl disable blog

> 显示所有已启动服务

    systemctl list-units --type=service

> 刷新服务

    systemctl daemon-reload


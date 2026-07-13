---
display-name: 使用 supervisor 守护进程
date: 2019-03-08 10:46:04
tags: [ "Linux" ]
---

## 安装

```bash
pip install supervisor
```

## 配置

首先我们使用 `echo_supervisord_conf` 得到默认的配置文件

```bash
echo_supervisord_conf > /etc/default-supervisord.ini
```

然后对它进行几处修改，只剩下这些就可以了

```ini
[unix_http_server]
file = /tmp/supervisor.sock   ; 默认的 socket 文件

[supervisord]
logfile = /tmp/supervisord.log ; 主要的日志文件，默认的是 $CWD/supervisord.log
logfile_maxbytes = 50MB        ; 日志文件大小，默认50M
logfile_backups = 10           ; 日志文件备份，0表示不备份，默认为10
loglevel = info                ; 日志级别，默认是 info，其他可选项: debug,warn,trace
pidfile = /tmp/supervisord.pid ; pid　文件位置，默认为 supervisord.pid
nodaemon = false               ; 在前台启动，默认不
minfds = 1024                  ; 保持默认即可
minprocs = 200                 ; 保持默认即可

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl = unix:///tmp/supervisor.sock

; 启动时加载的其他配置文件
[include]
files = /etc/supervisor/*.ini

; 关闭主进程时 , 同时关闭子进程
stopasgroup = true
killasgroup = true
```

现在假设我们是需要监听 rabbitmq 来处理队列中的任务．并且我们在 `/www/rabbitmq` 中创建了一个命名为 `cli.php`的 php 脚本， 使用 `cli.php start`
命令来启动任务，并且我们希望把脚本的标准输出写入到 `/var/log/rabbitmq_stdout.log` 作为日志以供查阅．

那么依据以上的这些假设，为我们的任务创建一个符合 supervisor 规则的惯例配置文件

```bash
touch /etc/supervisor/rabbitmq-listen-task.ini
```

写入以下内容

```ini
; 我们把任务命名为 rabbitmq-listen
[program:rabbitmq-listen]
; 程序的启动目录
directory = /www/rabbitmq
; 启动命令
command = /usr/bin/php /www/rabbitmq/cli.php start &
; 在 supervisord 启动的时候也自动启动
autostart = false
; 启动 5 秒后没有异常退出，就当作已经正常启动了
startsecs = 5
; 程序异常退出后自动重启
autorestart = true
; 启动失败自动重试次数，默认是 3
startretries = 3
; 用哪个用户启动
user = root
; 把 stderr 重定向到 stdout，默认 false
redirect_stderr = true
; stdout 日志文件大小，默认 50MB
stdout_logfile_maxbytes = 20MB
stdout_logfile_backups = 20
; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）
stdout_logfile = /var/log/rabbitmq_stdout.log
```

保存即可

## 启动

使用 `supervisord` 命令启动 , 并且加载我们修改过的配置文件，由于我们的include配置，在启动后 `supervisor` 会自动加载我们为 `rabbitmq` 脚本创建的惯例文件

```bash
supervisord -c /etc/supervisord.conf
```

## 管理

`supervisord` 为我们提供了一些很好的管理工具，web 和 命令行版本的都有，本文只讨论交互式的命令行工具 `supervisorctl`．

直接运行就可以看到任务的运行状况

```bash
[root@localhost opt]# supervisorctl 
rabbitmq-listen                RUNNING   pid 3912, uptime 0:53:32
supervisor>
```

上述命令出现如下报错的话

```bash
$ supervisorctl
http://localhost:9001 refused connection
supervisor> status
http://localhost:9001 refused connection
supervisor>
```

使用如下命令即可正常

```bash
supervisorctl -c /etc/supervisord/supervisord.conf
rabbitmq-listen                RUNNING   pid 3912, uptime 0:53:32
supervisor>
```

查看状态

```bash
supervisor> status
```

重启任务

```bash
supervisor> restart rabbitmq-listen
rabbitmq-listen: stopped
rabbitmq-listen: started
```

启动任务

```bash
supervisor> start rabbitmq-listen
rabbitmq-listen: started
```

关闭任务

```bash
supervisor> stop rabbitmq-listen
rabbitmq-listen: stopped
```

重新读取配置文件，加入新的任务，但是不会自动启动

```bash
supervisor> reread
No config updates to processes
```

重启配置文件修改过的任务

```bash
supervisor> update
```

这些命令也可以在终端里直接运行

```bash
supervisorctl status
supervisorctl reread
supervisorctl update
supervisorctl stop rabbitmq-listen
supervisorctl start rabbitmq-listen
supervisorctl restart rabbitmq-listen
```

---
display-name: 从 systemctl 传递参数到 unit 文件
date: 2023-01-09 11:34:54
publish: true
categories:

- Linux

tags:

- Linux

---

## 前言

大部分 systemd service 都是以单例形式运行的，只有很少服务需要以多个实例运行。如果我们恰好需要多例运行，那解决方案绝对不是为多个实例编写多个重复的
unit file，于是就有了 systemd specifiers 这一特性，我们需要使用到的便是其中的 instance name 这一变量

其他更多的 specifiers [http://0pointer.de/public/systemd-man/systemd.unit.html](http://0pointer.de/public/systemd-man/systemd.unit.html)

## 示例

以操作系统内置的 `/lib/systemd/system/serial-getty@.service` 服务为例，instance name 即为 serial-getty@ttyS0.service
中@到.service中间的字符串。

```shell
systemctl status serial-getty@ttyS0.service
```

## 如何使用

接下来将会编写一个无实际意义的 unit file，动态实现对设备文件的监听。文件命名为 `/etc/systemd/system/tailf@.service`

```unit file (systemd)
[Unit]
Description=tail -f on %i

[Service]
Type=simple
ExecStart=/usr/bin/tail -f /dev/%i
ExecStop=/bin/kill -9 $MAINPID
Restart=on-failure
KillMode=process
```

测试

```shell
systemctl start tailf@null tailf@random
```

```shell
root@loalhost:~# systemctl status tailf@null tailf@random
● tailf@null.service - tail -f on null
   Loaded: loaded (/etc/systemd/system/tailf@.service; static; vendor preset: enabled)
   Active: active (running) since Mon 2023-01-09 14:02:14 CST; 3min 27s ago
 Main PID: 2369 (tail)
    Tasks: 1 (limit: 2358)
   Memory: 268.0K
   CGroup: /system.slice/system-tailf.slice/tailf@null.service
           └─2369 /usr/bin/tail -f /dev/null

Jan 09 14:02:14 alexecs systemd[1]: Started tail -f on null.

● tailf@random.service - tail -f on random
   Loaded: loaded (/etc/systemd/system/tailf@.service; static; vendor preset: enabled)
   Active: active (running) since Mon 2023-01-09 14:05:18 CST; 23s ago
 Main PID: 2431 (tail)
    Tasks: 1 (limit: 2358)
   Memory: 228.0K
   CGroup: /system.slice/system-tailf.slice/tailf@random.service
           └─2431 /usr/bin/tail -f /dev/random

Jan 09 14:05:18 alexecs systemd[1]: Started tail -f on random.
```

有了这种基础，我们也可以发挥出更多的用法，比如方便的为程序启动 debug 或 prod 模式。 或为 unit file 设置软连接固定一些
instance name。

```shell
ln -s tailf@.service tailf@null.service
```

### 转义

假设我们除了设备文件还想进一步监控其他任意文件，例如 /var/log/messages 文件。

但是事实上和我们想象的不太一样，在去掉 unit file 中的 /dev/ 之后执行 `systemctl start tailf@/var/log/messages`
，会发现命令执行失败了，原因是 systemctl 默认会转义 / 为 -，实际上执行的命令是 `/usr/bin/tail -f -var-log-messages` 而
-var-log-messages 这个文件并不存在。

```shell
root@localhost:# systemctl start tailf@/var/log/messages
Invalid unit name "tailf@/var/log/messages" was escaped as "tailf@-var-log-messages" (maybe you should use systemd-escape?)
root@localhost:# systemctl status tailf@-var-log-messages
● tailf@-var-log-messages.service - tail -f on -var-log-messages
   Loaded: loaded (/etc/systemd/system/tailf@.service; static; vendor preset: enabled)
   Active: failed (Result: exit-code) since Mon 2023-01-09 14:21:23 CST; 4s ago
  Process: 2710 ExecStart=/usr/bin/tail -f -var-log-messages (code=exited, status=1/FAILURE)
 Main PID: 2710 (code=exited, status=1/FAILURE)
```

解决方案也很简单，只要将 unit file 中的 %i 改为 %I
即可使用没有转义的字符。进一步的，使用 `systemctl start tailf@-var-log-messages` 来启动服务，可以将 `Invalid unit name`
错误也消除掉。

## 缺点

1. 显而易见的，使用这种变量时需要为 unit 文件命名增加@后缀。
2. / 被转义之后有点难以理解，但不转义使用又会出现错误提示。

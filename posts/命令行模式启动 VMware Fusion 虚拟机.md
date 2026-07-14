---
display-name: 命令行模式启动 VMware Fusion 虚拟机
date: 2020-09-07
tags: ["杂项"]
---



直接启动

```shell
vmrun -T ws start Centos.vmwarevm
```

启动到后台，不显示图形界面，可以使用ssh链接

PID 是后台进程ID，可以使用PID对虚拟机进行进行销毁等操作

```shell
vmrun -T ws start Centos.vmwarevm nogui
2020-09-07T10:03:54.567| ServiceImpl_Opener: PID 14175
```


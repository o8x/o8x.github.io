---
display-name: cp 命令的高级替代品 install
date: 2022-07-06 08:57:39
tags: [ "Linux" ]
---

install 命令是 coreutils 中的一个命令，它可以在完成cp命令功能的同时进行文件属性设置等工作

## 典型应用

- 自动创建不存在的目录
- 将文件 app.ini 复制为 /etc/apt/sources.list.d/app.list
- 设置目标文件权限为 755
- 原文件在覆盖前将被备份为 `/etc/apt/sources.list.d/app.list~`

```shell
install -b -D -m 755 app.list /etc/apt/sources.list.d/app.list
```

使用 cp 命令实现

```shell
mkdir -p /etc/apt/sources.list.d
cp /etc/apt/sources.list.d/app.list /etc/apt/sources.list.d/app.list~
cp app.list /etc/apt/sources.list.d/app.list
chmod 755 /etc/apt/sources.list.d/app.list
```

## 常见参数

#### --backup

复制文件时进行备份

none, off 不进行任何备份

```shell
install --backup=off app.ini /etc/app/app.ini
```

numbered, t 备份文件进行数字编号，本例将生成`app.ini.~1~`备份文件，数字部分将随着执行次数自增

```shell
install --backup=numbered app.ini /etc/app/app.ini
```

simple, never 始终进行简单备份，将生成`app.ini~`备份文件，多次执行会覆盖此备份文件

```shell
install --backup=simple app.ini /etc/app/app.ini
```

existing, nil 如果存在数字备份文件则递增，否则按照简单模式处理（与-b参数一致）

```shell
install --backup=nil app.ini /etc/app/app.ini
```

#### -b

与 --backup 功能相同，但不接受参数，效果等同 `--backup=simple`

```shell
install -b app.ini /etc/app/app.ini
```

#### -C, --compare

比较源文件和目标文件的文件属性，某些情况下不进行复制，例如当目标和源文件完全一致

```shell
install -C app.ini /etc/app/app.ini
```

#### -d, --directory

将所有参数视为目录，即最终将会得到名为 `app.ini` 的目录而非 ini 文件

```shell
install -d app.ini /etc/app/app.ini
```

#### -D

自动创建除目标文件以外的文件（目录），此例中将会自动创建尚不存在的 `/etc/app/test` 目录

```shell
install -D app.ini /etc/app/test/app.ini
```

#### -g, --group，-o, --owner

设置文件的所有组与所有者

```shell
install -g alex -o alex app.ini /etc/app/test/app.ini
```

```shell
> ll /etc/app/test/app.ini
0 -rwxr-xr-x 1 alex alex 0 Aug  4 16:11 /etc/app/test/app.ini
```

#### -m, --mode

为目标文件设置权限，参数与 chmod 相同

```shell
install -m 755 app.ini /etc/app/app.ini
```

#### -p, --preserve-timestamps

复制文件时，连文件时间戳一起复制

```shell
> ll app.ini
0 -rw-r--r-- 1 root root 0 Aug  4 16:00 app.ini
> install -p app.ini /etc/app/app.ini
> ll /etc/app/app.ini
0 -rwxr-xr-x 1 root root 0 Aug  4 16:00 /etc/app/app.ini
```

#### -S, --suffix

覆盖默认备份文件的后缀，本例备份文件将被命名为 `app.ini.bak`

```shell
install -S '.bak' -b app.ini /etc/app/app.ini
```

#### -v, --verbose

打印被操作的文件详情

#### --preserve-context

保留文件的 SELinux 安全属性

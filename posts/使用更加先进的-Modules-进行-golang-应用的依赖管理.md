---
display-name: 使用更加先进的 Modules 进行 golang 应用的依赖管理
date: 2020-07-16 14:59:07
tags: ["Golang"]
---

## [Modules](https://github.com/golang/go/wiki/Modules)

历史：

*Go 自1.11版本起，包含了对 Modules 的支持，初始原型于2018年2月宣布。2018年7月 Modules 正式进入主 Go 存储库。*

*在 [Go 1.14](https://golang.org/doc/go1.14) 中，Modules 被视为可供生产使用，鼓励所有用户从其他依赖管理系统迁移到 Modules*

简介：

Modules 是 golang 官方推出的包管理器，类似 nodejs 的 npm yarn、java 的 maven ……，用法为简单的 `go mod [command]` 。

**要求：** go 版本大于 1.11，且不能在 GOPATH 中使用 Modules

## 如何使用

#### 开启 go mod

Go 1.13 自动检测是否存在 go.mod 来决定是否开启 Go mod，其它版本需要显式的设置环境变量

**go > 1.13**

```shell
go env -w GO111MODULE=on
```

**go < 1.13**

```shell
export GO111MODULE=on
```

#### 工程初始化

```shell
$ unset GOPATH
$ go mod init project_name
$ cat go.mod
module project_name

go 1.14
```

#### 使用网络依赖

在代码中直接 import 远程依赖即可

```go
package main

import (
  "fmt"
  . "github.com/ymzuiku/hit"
)

func main() {
  fmt.Println(If(true, 500, 200))
}
```

#### 安装/更新网络依赖

mod tidy 类似 maven update , 将会寻找到项目内引用的三方依赖并移除无用的依赖

```shell
$ go mod tidy
go: finding module for package github.com/ymzuiku/hit
go: downloading github.com/ymzuiku/hit v0.0.0-20190525155149-18097f1d08f4
go: found github.com/ymzuiku/hit in github.com/ymzuiku/hit v0.0.0-20190525155149-18097f1d08f4
$ cat go.mod
module project_name

go 1.14

require github.com/ymzuiku/hit v0.0.0-20190525155149-18097f1d08f4
$ cat go.mod
github.com/ymzuiku/hit v0.0.0-20190525155149-18097f1d08f4 h1:WDJK0bmetdi+uFDkgA8nl+sAY0ENbBeRgQhcjCh2dsM=
github.com/ymzuiku/hit v0.0.0-20190525155149-18097f1d08f4/go.mod h1:M4eSqqTk46uUlszklsh2qMc5LnMRGzAm+Ukf1dD0crU=
```

#### 验证当前的依赖关系

解析依赖关系，验证下载的依赖包有没有修改，没有修改则无输出

```shell
$ go mod verify
all modules verified
```

#### 下载依赖包

将依赖包下载到 $GOPATH/pkg/mod 中，在多个项目间共享包缓存。

```shell
$ go mod download
```

#### 将依赖转移到本地

将下载好的依赖拷贝到vendor目录，不拷贝也可以编译，拷贝完有助于IDE识别

```shell
$ go mod vendor
```

#### 其它命令

| 命令  | 作用                       |
| ----- | -------------------------- |
| edit  | 通过一些工具编辑 go.mod    |
| graph | 打印依赖关系图             |
| why   | 对为什么需要这个包进行解释 |

## 其它命令

- 查看某个依赖包的所有可用版本

```
go list -m -versions github.com/ymzuiku/hit
```

- 清理mod缓存

```shell
go clean -modcache
```

## go.mod 指令

- replace ，用于管理需要的依赖包

```go
require github.com/ymzuiku/hit v0.0.0-20190525155149-18097f1d08f4
require github.com/xxxx
require github.com/xxxx
```

等价于：

```shell
require (
    github.com/ymzuiku/hit v0.0.0-20190525155149-18097f1d08f4
    github.com/xxxx
    github.com/xxxx
)
```

- replace 替换依赖为别的依赖

将一个依赖库的某个版本替换成另一个依赖库，在直连网络不佳的时候，尤为重要

不过看起来 GOPROXY 已经解决了这个问题

```shell
replace (
    github.com/Sirupsen/logrus v1.6.0 => github.com/sirupsen/logrus v1.6.0
    github.com/sirupsen/logrus v1.6.0 => github.com/Sirupsen/logrus v1.6.1
)
```

也可以使用命令操作

```shell
go mod edit -replace=github.com/ymzuiku/hit@latest=github.com/xxxxx/hit@latest
```

- 使用本地依赖

```go
require (
mymod v1.0.0
)

replace (
mymod v1.0.0 = >../mod/mymod
)
```

- 其它指令
    - exclude：忽略一些依赖项
    - module：指定 project_name，即 go mod 第一行

## 将已有项目改为使用 go mod 管理

1. 注销 GOPATH 变量，否则不能开启 go mod

```shell
unset GOPATH
```

2. 初始化为 go mod 项目

```shell
go mod init projec_name
```

3. 检查依赖，并且自动更新 go.mod

可能会遇到一些问题，根据前面介绍的指令都能解决。例如：replace

```shell
go mod tidy
```

4. 将下载的依赖转移到本地

```shell
go mod vendor
```

5. 运行测试

可能会因为依赖库的版本，无法完成测试。一个一个解决即可

```shell
go test ./...
```

6. 尝试编译

```shell
go build -v -a -o app .
```

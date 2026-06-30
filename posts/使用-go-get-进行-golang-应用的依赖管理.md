---
display-name: 使用 go get 进行 golang 应用的依赖管理
date: 2020-07-16 14:59:07
categories:
- Golang
tags:

- golang

---

## Golang 依赖管理

**go get 和 GOPATH**

go get 是 golang 提供的依赖管理工具，可以很方便的使用 go get 安装网络中的依赖。但是因为无法进行集中管理而遭人诟病。他也是 Modules 实现的基础，所以本文会提及到。

GOPATH 作用类似 nodejs 中的 node_modules 。在执行 go get 之后，系统将会在 GOPATH 指向的路径中安装依赖包，go build 和 go run 也将会在 GOPATH 中查找依赖进行编译。

### 基本用法

为了简单的观察产生的变化，我们把GOPATH就设置到当前目录

```shell
export GOPATH=$(pwd)/.gopath
```

- 安装依赖包

这是一个可以实现类似三元表达式操作的包，只有两个API：`If()`,`Or()`

```shell
go get github.com/ymzuiku/hit
```

只需要简单的 import 即可使用 go get 安装的依赖包

```shell
$ echo ${GOPATH}     
/tmp/testgoget/.gopath

$ cat main.go
package main

import (
    . "github.com/ymzuiku/hit"
    "fmt"
)

func main() {
    fmt.Println(If(true , 500 , 200))
}

$ go run main.go
500
```

- GOPATH

可以发现我们指定的 GOPATH 被自动创建，并且创建了 pkg 以 src 两个子目录

```shell
$ tree -a -L 6
.
├── .gopath
│ ├── pkg
│ │ └── darwin_amd64
│ │     └── github.com
│ │         └── ymzuiku
│ │             └── hit.a
│ └── src
│     └── github.com
│         └── ymzuiku
│             └── hit
│                 └── ...
└── main.go
```

**${GOPATH}/pkg**

存储包编译后的二进制文件

| 目录       | 作用    |
| --------- | ------- |
| pkg                          | 存放依赖包编译形成的.a文件     |
| pkg/github.com               | 通过 goget 安装的依赖的域名，来自github的包都会在这个文件夹下存储 |
| pkg/github.com/ymzuiku       | 来自 github 中 ymzuiku 这个组织或作者的包都会在这个目录下存储 |
| pkg/github.com/ymzuiku/hit.a | 来自 github 中 ymzuiku 这个组织或作者的创建的 hit 包被编译为 `包名.a` |

**${GOPATH}/src**

存储包源码，作用类似 nodejs 中的 node_modules 和 php 的 vendor

| 目录 | 作用    |
| --------- | ------- |
| src                          | 存放依赖包的源码                              |
| src/github.com               | 通过 goget 安装的依赖的域名，来自github的包都会在这个文件夹下存储 |
| src/github.com/ymzuiku       | 来自 github 中 ymzuiku 这个组织或作者的包都会在这个目录下存储 |
| src/github.com/ymzuiku/hit   | 来自 github 中 ymzuiku 这个组织或作者的创建的 hit 包在这个目录下存储 |
| src/github.com/ymzuiku/hit/* | 来自 github 中 ymzuiku 这个组织或作者的创建的 hit 包的源码   |

## 命令行参数

| 参数        | 作用                                                         |
| ----------- | ------------------------------------------------------------ |
| -d          | 在下载后停止，即只下载不安装                                 |
| -f          | 在使用了 -u 时生效，强制不对 -u 时引用的其它包进行网络获取。 |
| -fix        | 在解析依赖项或生成代码之前先修复包                           |
| -t          | 在安装包时，同时也执行包内的所有测试                         |
| -u          | 强制使用网络来下载、更新包和他们的依赖关系                   |
| -v          | 输出安装的详细过程，即执行的命令                             |
| -unsecurity | 允许从存储库中获取数据并进行解析，使用不安全方案（如HTTP）的自定义域时，要小心使用 |

#### 其它命令

- 更新依赖到最新的版本

```shell
go get github.com/ymzuiku/hit@master
```

- 更新到最新的补丁版本，不更新版本，只更新补丁

```sh le lsh l
go get -u=patch github.com/ymzuiku/hit
```

## GOPROXY

国内的包镜像站，原理是在别人使用 GOPROXY 来下载包之后，这个包就会缓存到 PROXY 中，你再次使用就会直接拿到镜像中的缓存，而无需链接到github或其它的托管服务器。解决通过网络下载海外服务器中的包速度慢的问题。

### 配置

可选镜像列表

| 地址                                | 提供方                   |
| -------------------- | ------------------------ |
| https://proxy.golang.org            | golang 官方（较慢）      |
| https://goproxy.cn                  | 七牛云（推荐）           |
| https://goproxy.io                  | 中国golang俱乐部（推荐） |
| https://mirrors.aliyun.com/goproxy/ | 阿里云（一般）           |
| https://mirrors.tencent.com/go/     | 腾讯                     |
| https://athens.azurefd.net/         | 微软                     |

**go > 1.13**

```shell
go env -w GOPROXY="https://goproxy.io,direct"
```

**go < 1.13**

```shell
# 配置 GOPROXY 环境变量
export GOPROXYhttps://goproxy.io
```

#### 其它配置

**设置不走 proxy 的私有仓库，多个用逗号相隔**

```shell
go env -w GOPRIVATE=*.corp.example.com
```

**设置不走 proxy 的私有组织**

```shell
go env -w GOPRIVATE=example.com/org_name
```


---
display-name: golang 基础
date: 2020-07-16 08:53:33
tags:

- golang

categories:
- Golang
---

## 语法

文档地址：https://golang.org/doc/

包文档：https://golang.org/pkg/

## 运行 go 项目

使用 go run

```shell
$ cat main.go
package main

func main() {
    println("hello world")
}
$ go run main.go
hello world
```

## 编译 go 项目

使用 go build

```shell
$ cat main.go
package main

func main() {
    println("hello world")
}
$ go build  -a -v -o main main.go
runtime/internal/sys
runtime/internal/atomic
internal/cpu
runtime/internal/math
internal/bytealg
runtime
command-line-arguments
$ ./main
hello world
```

编译器选项

```
go build -ldflags "-w -s -X main.Version=${VERSION} -X main.Build=${BUILD}"
```

| 选项 | 作用                                         |
| ---- | -------------------------------------------- |
| -w   | 去掉调试信息，无法使用gdb调试二进制文件了    |
| -s   | 去掉符号表，panic时候的不展示任何文件名/行号 |
| -X   | 设置包中的变量值，其值来自环境变量           |

### 其它编译参数

|参数|作用|
| ----- | ------------------------------------------- |
| -v    | 编译时显示包名                              |
| -p n  | 开启并发编译，默认情况下该值为 CPU 逻辑核数 |
| -a    | 强制重新构建                                |
| -n    | 打印编译时会用到的所有命令，但不真正执行    |
| -x    | 打印编译时会用到的所有命令                  |
| -race | 开启竞态检测                                |

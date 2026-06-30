---
display-name: Go 1.20 更新内容
date: 2023-02-11 09:19:24
publish: true
categories:

- Golang

tags:

- golang

---
> [Go 1.20 is released!](https://go.dev/blog/go1.20)
> Go 1.20 在 2023年2月1日 迎来了发布，仍与旧的版本[保证兼容](https://tip.golang.org/doc/go1compat)，迄今为止所有的 Go
> 程序都能在 1.20 中正常编译运行

本文只对 Go 1.20 中的常用功能更新进行了说明，完整日志可查看 [Go 1.20 Release Notes
](https://tip.golang.org/doc/go1.20)

## 语言特性更新

### 切片到数组指针的转换

https://tip.golang.org/ref/spec#Conversions_from_slice_to_array_or_array_pointer

```go
s := make([]byte, 2, 4)

a0 := [0]byte(s)
a1 := [1]byte(s[1:]) // a1[0] == s[1]
a2 := [2]byte(s) // a2[0] == s[0]
a4 := [4]byte(s) // panics: len([4]byte) > len(s)

s0 := (*[0]byte)(s) // s0 != nil
s1 := (*[1]byte)(s[1:]) // &s1[0] == &s[1]
s2 := (*[2]byte)(s) // &s2[0] == &s[0]
s4 := (*[4]byte)(s) // panics: len([4]byte) > len(s)

var t []string
t0 := [0]string(t) // ok for nil slice t
t1 := (*[0]string)(t)    // t1 == nil
t2 := (*[1]string)(t) // panics: len([1]string) > len(t)

u := make([]byte, 0)
u0 := (*[0]byte)(u) // u0 != nil
```

## 操作系统兼容性

**Windows**

Go 1.20 将会是最后一个支持 Windows 7 8, Server 2008 2012 的版本，从 Go 1.21 开始最低将依赖 Windows 10, Server 2016

**Darwin**

Go 1.20 也是最后一个支持 MacOS 10.13 或 10.14 的版本。从 Go 1.21 开始将至少需要 macOS 10.15 或更高

## 标准库更新

- 新增 crypto/ecdh 用于替代 crypto/elliptic 在某些场景下的用法

### errors.Join

新增 Join 方法，用于合并多个错误，errors.Is 和 errors.As 也将自动支持该特性

```go
package main

import (
	"errors"
	"fmt"
)

func main() {
	err1 := errors.New("err1")
	err2 := errors.New("err2")
	err := errors.Join(err1, err2)
	fmt.Println(err)

	if errors.Is(err, err1) {
		fmt.Println("err is err1")
	}

	if errors.Is(err, err2) {
		fmt.Println("err is err2")
	}
} 
```

### errors.Unwrap

如果在 fmt.Errorf 中使用 %w 来输入一个错误，返回值的 error 类型将会自动实现 Unwrap interface

```go
interface {
    Unwrap() error
}

```

Unwrap 会自动判断 errors 是否实现了 Unwrap interface，如果是则调用其 Unwrap 方法并返回

```go
err1 := errors.New("error 1")
err2 := fmt.Errorf("error 2 %w", err1)
fmt.Println(err2)
fmt.Println(errors.Unwrap(err2))
```

运行结果

```shell 
error 2 error 1
error 1
```

### Bytes.Cut

提供像 TrimPrefix 的功能，但返回了是否找到

    func CutPrefix(s, prefix []byte) (after []byte, found bool)

提供像 TrimSuffix 的功能，但返回了是否找到

    func CutSuffix(s, suffix []byte) (before []byte, found bool)

```go
before, after, found := bytes.Cut([]byte("Hello World"), []byte(" "))
fmt.Println(string(before), string(after), found)

prefix, f := bytes.CutPrefix([]byte("Hello World"), []byte("H"))
fmt.Println(string(prefix), f)

suffix, f := bytes.CutSuffix([]byte("Hello World"), []byte("World"))
fmt.Println(string(suffix), f)
```

运行结果

```go
Hello World true
ello World true
Hello  true
```

### context.WithCancelCause

允许在 cancel 是提供一个错误，并可以通过 context.Cause 取出该错误。

```go
ctx, cancel := context.WithCancelCause(context.Background())
cancel(fmt.Errorf("error in WithCancelCause Context"))
fmt.Println(ctx.Err())
fmt.Println(context.Cause(ctx))
```

运行结果

```shell
context canceled
error in WithCancelCause Context
```

### time

终于为 Go 中最常用的日期时间格式提供了常量，不需要再每次使用都查一遍 2006-01-02 15:04:05 了

time.DateTime

    2006-01-02 15:04:05

time.DateOnly

    2006-01-02

time.TimeOnly

    15:04:05

```go
fmt.Println(time.DateTime, time.DateOnly, time.TimeOnly)
fmt.Println(
    time.Now().Format(time.DateTime),
    time.Now().Format(time.DateOnly),
    time.Now().Format(time.TimeOnly),
)
```

运行结果

```shell
2006-01-02 15:04:05 2006-01-02 15:04:05
2023-02-11 10:24:39 2023-02-11 10:24:39
```

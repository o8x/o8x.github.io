---
display-name: golang 单元测试入门
date: 2020-07-16 14:58:05
tags: ["Golang"]
---

## 单元测试

对系统进行最小粒度的测试，具体到测试某个函数或表达式。

golang 直接为我们提供了单元测试工具 go test

## 入门 Go test

**所有的测试用例，文件名都应该以 _test.go 结束，方法名都应该以 Test 开始**

待测试文件 main.go

```go
package main

import "math"

func Pow2(x float64) float64 {
	return math.Pow(x, 2)
}
```

测试用例 main_test.go

```go
package main

import (
	"testing"
)

func TestPow(t *testing.T) {
	cases := []struct {
		x float64
		y float64
	}{
		{2, 4},
		{1, 1},
		{4, 16},
		{8, 64},
		{1000, 1000000},
	}

	for _, option := range cases {
		y := Pow2(option.x)
		if y != option.y {
			t.Error(y)
		}
		t.Log(y)
	}
}
```

运行测试

go test 在调用 Error 等API时，将会终止测试，并认为本次测试失败

```shell
$ go test
PASS
ok      org.println/go-mod-test 0.833s
```

## 测试替身 Mock

未完待续

## 打桩 Stub

未完待续

## 相关API

> 所有API一览 https://golang.org/pkg/testing/#pkg-index

本文只介绍部分API

|Type T 方法签名    | 作用 |
| ---- | ---- |
| func (c *T) Cleanup(f func()) | 测试及其所有子测试完成时调用的方法 |
| func (c *T) Error(args ...interface{}) | 等同于 Log 但会终止测试 |
| func (c *T) Errorf(format string, args ...interface{}) | 对 Error 提供格式化支持，语法同 printf |
| func (c *T) Fail() | 标记测试失败，但不终止测试 |
| func (c *T) Failed() bool | 在测试失败的时候抛出异常 |
| func (c *T) Fatal(args ...interface{}) | 等于 FailNow，但会终止测试 |
| func (c *T) Fatalf(format string, args ...interface{}) | 对 FailNow 提供格式化支持，语法同 printf |
| func (c *T) Helper() | 将调用的函数标记为助手函数 |
| func (c *T) Log(args ...interface{}) | Log 打印日志，不会造成测试终止 |
| func (c *T) Logf(format string, args ...interface{}) | 对 Log 提供格式化支持，语法同 printf |
| func (c *T) Name() string | 返回正在运行的测试的名称 |
| func (c *T) Skip(args ...interface{}) | 等同于 Log，后支持 SkipNow |



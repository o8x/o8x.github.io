---
display-name: Golang 解决TCP的数据无边界性问题（粘包）
date: 2023-01-22 10:13:22
publish: true
categories:

- Golang

tags:

- golang

---

## 什么是数据的无边界性问题

这个问题和 TCP 没有任何的关系，究其根本是 TCP 原理和我们使用的方式差异的造成的问题。

TCP 是一种流式协议，数据传输就像水流，并没有固定的边界，而我们基于数据包的开发方式却需要固定的边界来取出具体的数据包。

在数据包没有固定边界的情况下，由于服务器和客户端并不总是同时收发数据包或网络拥塞等原因，造成客户端发送的多个数据包被服务器当做一个数据包接收，只能将其作为数据流处理，一般将其称之为粘包问题。

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/clipboard_20230122_104525.png)

## 解决粘包

只要客户端在发送的每个数据包最前面增加上包的长度，服务端就可以通过读取固定长度的数据流得到一个完整的数据包。

### 客户端

定义一个数据包 Reader

```go
b := bytes.NewBuffer([]byte(".....packet"))
```

包结构

```
+----------------+
| packet content |
|----------------|
|     -byte      |
+----------------+
```

使用 binary 生成一个4字节的 int 作为包头，理论上最大支持 2^32 长度的包。

```go
data := make([]byte, 4)
binary.BigEndian.PutUint32(data, uint32(b.Len()))
```

将数据包拼接到包头后面，形成要发送的数据包

```go
data = append(data, b.Bytes()...)
```

包结构

```
+-------------------------------------+
|  packet length  |  packet content   |
|-------------------------------------|
|      4byte      |       -byte       |
+-------------------------------------+
```

### 服务器

读取4个字节，获取到包的长度

```go 
pl := make([]byte, 4)
if n, err := conn.Read(pl); err != nil || n != 4 {
    return nil, err
}
```

转换为 int32

```go 
l := binary.BigEndian.Uint32(pl)
```

设置读取超时，防止发生无限阻塞

```go
conn.SetReadDeadline(time.Now().Add(time.Second * 3))
defer conn.SetReadDeadline(time.Time{})
```

进行单个包读取

go 可以简单的实现从数据流中读取指定长度的字节。创建一个固定长度的 []byte，使用 ReadFull 将其读满就相当于读到了固定长度的包。

```go
bs := make([]byte, l)
if _, err := io.ReadFull(conn, bs); err != nil {
    return nil, err
}
```

## 测试代码

### 客户端

```go 
package main

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"io"
	"math/rand"
	"net"
	"time"

	"github.com/sirupsen/logrus"
)

func init() {
	rand.Seed(time.Now().UnixNano())
}

func main() {
	dial, err := net.Dial("tcp", "localhost:51906")
	if err != nil {
		logrus.WithError(err).Fatalf("dial server failed")
	}

	// 生成测试数据
	b := bytes.NewBuffer(nil)
	for i := 0; i < 10000; i++ {
		b.WriteString(fmt.Sprintf("DATA-%d,", i))
		if i%10 == 0 {
			b.WriteString("\n")
		}
	}

	for {
		bs := make([]byte, rand.Intn(100))
		n, err := b.Read(bs)
		if err == io.EOF {
			dial.Close()
			return
		}

		data := make([]byte, 4)
		binary.BigEndian.PutUint32(data, uint32(n))

		if _, err = dial.Write(append(data, bs...)); err != nil {
			logrus.WithError(err).Fatalf("write server failed")
		}
	}
}

```

### 服务端

```go 
package main

import (
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"time"

	"github.com/sirupsen/logrus"
)

func main() {
	l, err := net.Listen("tcp", "localhost:51906")
	if err != nil {
		logrus.WithError(err).Fatalf("listen failed")
	}

	for {
		conn, err := l.Accept()
		if err != nil {
			if err == io.EOF {
				return
			}
			logrus.WithError(err).Fatalf("accept")
			continue
		}

		go func(c net.Conn) {
			readNextPacket := func() ([]byte, error) {
				head := make([]byte, 4)
				if n, err := conn.Read(head); err != nil || n != 4 {
					return nil, err
				}

				c.SetReadDeadline(time.Now().Add(time.Second * 3))
				defer c.SetReadDeadline(time.Time{})

				bs := make([]byte, binary.BigEndian.Uint32(head))
				if _, err := io.ReadFull(conn, bs); err != nil {
					return nil, err
				}

				return bs, nil
			}

			for {
				packet, err := readNextPacket()
				if err == io.EOF {
					return
				}

				fmt.Printf("packat: %s", packet)
			}
		}(conn)
	}
}

```

---
display-name: Golang 中的 XOR 运算
date: 2023-01-22 19:24:49
categories:

- Golang

tags:

- golang

---

## 原理

XOR 实际上是一种或运算，一般使用 ^ 进行运算，但只有两个值不同时才会为 true，运算值表如下/

| 运算    | 值   |
|-------|-----|
| 0 ^ 0 | 0   | 
| 0 ^ 1 | 1   | 
| 1 ^ 0 | 1   | 
| 1 ^ 1 | 0   | 

按表进行 16 xor 5 运算

```
16 xor 5 
= 00010000 xor 00000101
= 00010000
  00000101
= 00010101
= 21
```

## 运算定律

### 任何值与自身进行异或，值总是等于0

```
x ^ x = 0
```

原理

```
5 xor 5 
= 00000101 xor 00000101
= 00000101
  00000101
= 00000000
= 0
```

### 任何值与0进行异或，值总是等于自身

```
x ^ 0 = x
```

原理

```
5 xor 0
= 00000101 xor 00000000
= 00000101
  00000000
= 00000101
= 5
```

### 可交换性

```
x ^ y = y ^ x
```

原理

无论运算子谁在前，按位异或的结果也总是一致

## 在 Go 中使用异或

go 也使用 ^ 运算符进行异或运算

```go
func Sum[T int | int64 | int8 | int32 | byte](a T, b T) T {
    return a ^ b
}
```

## 加解密

可以使用 XOR 进行简单的加解密，实际上 AES 和 DES 等算法的本质也是多次和更为复杂的异或运算

```go
func Encode(bs []byte, key string) []byte {
	var result []byte
	for i, c := range bs {
		result = append(result, Sum(c, key[i%len(key)]))
	}

	return result
}
```

测试

```go
text := []byte("Hello World")
key := "123456"
encode := xor.Encode(text, key)

fmt.Println("text:  ", text)
fmt.Println("key:   ", key)
fmt.Println("encode:", encode)
fmt.Println("decode:", xor.Encode(encode, key))
```

运行 

```shell
text:   [72 101 108 108 111 32 87 111 114 108 100]
key:    123456
encode: [121 87 95 88 90 22 102 93 65 88 81]
decode: [72 101 108 108 111 32 87 111 114 108 100]
```

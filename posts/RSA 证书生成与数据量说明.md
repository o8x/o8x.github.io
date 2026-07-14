---
display-name: RSA 证书生成与数据量说明
date: 2018-02-05 20:09:17
tags: [ "Linux" ]
---

### 私钥生成

```shell
$ openssl genrsa -out rsa_private_key.pem 2048
```

### 转换 PKCS#8 (java)

```shell
$ openssl pkcs8 -topk8 -inform PEM -in rsa_private_key.pem -outform PEM -nocrypt
```

### 公钥生成

```shell
$ openssl rsa -in rsa_private_key.pem -pubout -out rsa_public_key.pem
```

### 转换

#### PKCS#1 转 PKCS#8:

```shell
$ openssl rsa -RSAPublicKey_in -in pkcs1.pem -pubout
```

#### PKCS#8 转 PKCS#1:

```shell
$ openssl rsa -pubin -in pkcs8.pem -RSAPublicKey_out
```

### 密钥最大可承载数据量的问题

加密数据量根据密钥长度而定 , 最长为 : `密钥长度 / 8 - 11 个字节` 例如 2048级别的密钥 , 就是 `2048 / 8 - 11 = 245`。如果数据量字节过长就要使用分段加密

---
display-name: Python 与 PHP 使用RSA互相加解密传输数据
date: 2019-12-05 10:22:06
tags: ["php"]
---

## 需求

使用 PHP 服务加密（公钥）数据并经由网络传递到另一台服务器由 python 服务解密（私钥）。

> *PHP 服务使用的公钥由 python 服务提供*

## 生成密钥对

**生成 PKCS#1 格式的私钥**

    openssl genrsa -out private.pem 2048

**使用私钥生成 PKCS8 格式的公钥**
> openssl 默认生成的公钥都是 PKCS8 , 需要自行转换为 PKCS#1

    openssl rsa -in private.pem -pubout -out public.pem

## python 加密

> 使用 rsa 库 https://pypi.org/project/rsa/    
> 由于该库只支持 PKCS#1 格式的公钥    
> 所以我们需要再将公钥转换为 PKCS#1 格式才可以

### 转换公钥为 PKCS#1 格式

- 仅输出公钥

```shell
 openssl rsa -pubin -in public.pem -RSAPublicKey_out
```

- 将输出写入文件

```shell
openssl rsa -pubin -in public.pem -RSAPublicKey_out -out public_pkcs1.pem
```

### 公钥加密

```python
import base64
import rsa

public = """
-----BEGIN RSA PUBLIC KEY-----
...
-----END RSA PUBLIC KEY-----
"""
pubkey = rsa.PublicKey.load_pkcs1(public.encode())
print(
    base64.b64encode(rsa.encrypt("原文", pubkey))
)
```

### 私钥解密

```python
import base64
import rsa

private = """
-----BEGIN RSA PRIVATE KEY-----
....
-----END RSA PRIVATE KEY-----
"""

privkey = rsa.PrivateKey.load_pkcs1(private.encode())
print(
    base64.b64decode(rsa.decrypt("密文", privkey).decode())
)
```

## PHP 加解密

> php 使用 openssl 系列函数完成 RSA 加解密，且不区分 PKCS#1 PKCS8，从这点来说 **PHP是最好的语言**

### 加密

直接使用更加安全的 PKCS8 即可，无需使用转换的 PKCS#1

```php
$public = <<<PUB
-----BEGIN PUBLIC KEY-----
...
-----END PUBLIC KEY-----
PUB

openssl_public_encrypt("原文" , $encrypted , $public);
// 密文
echo base64_encode($encrypted)
```

### 解密

```php
$private = <<<PRI
-----BEGIN RSA PRIVATE KEY-----
....
-----END RSA PRIVATE KEY-----
PRI

openssl_private_decrypt(base64_decode("密文") , $decrypted , $private);
// 原文
echo $decrypted
```

## 其他

由于RSA密钥的长度和能够加密的数据长度息息相关，所以我们需要对明文分片加密。
大致原理为：`片数 = (明文长度(bytes) / (密钥长度(bytes) - 11)) 的整数部分+1，即不满一片的按一片算`

# 大功告成

此时只需要 PHP 使用公钥加密的内容经由 https 传输到 python 解密即可

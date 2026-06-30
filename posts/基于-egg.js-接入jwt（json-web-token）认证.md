---
display-name: 基于 egg.js 接入jwt（json web token）认证
date: 2020-06-15 16:20:41
tags:

- egg.js

---

### 什么是 JWT

> JSON Web Token (JWT) 是一个开放标准([RFC 7519](https://tools.ietf.org/html/rfc7519))
> ，定义了一种紧凑且自包含（免存储）的方式，以JSON对象的形式在各方之间安全地传输信息。你可以验证和信任该信息，因为它经过了数字签名。JWTs可以使用密钥(HMAC)、RSA、ECDSA 公钥/私钥对其签名。

### 如何使用

[jwt官网](https://jwt.io/)列出了一系列可用的JWT类库，本文选用[jose](https://github.com/panva/jose)

#### 安装

```shell
yarn add jose
```

#### 生成

```javascript
const {JWT, JWK} = require('jose')
const key = JWK.asKey({
    kty: 'oct',
    // 自定义密钥
    k: 'k04zAv2i134GU6W8mhGFqnftI1lLXRY-Sl7oV0PNy35',
})

const jwt = JWT.sign({
    // 可在任何地方解密的明文信息
    timestamp: new Date(),
}, key, {
    // 颁发给谁
    audience: ['urn:web:client'],
    // 由谁颁发
    issuer: 'https://stdout.com.com',
    // 过期时间，2 min 两分钟，2s 两秒，可自定义
    expiresIn: '2 hours',
    // 头信息
    header: {
        typ: 'JWT',
    }
})

// eyJ0eXAiOiJKV13iLCJhbGciOiJIUzI1NiJ9.eyJ0aW1lc3RhbXAiOiIyMDIwLTA2LTE1VDA4OjQxOjIxLjE5MFoiLCJhdWQiOlsidXJuOndlYjpjbGllbnQiXSwiaXNzIjoiaHR0cHM6Ly9wcmludGxuLm9yZyIsImlhdCI6MT15MjIxMDQ4MSwiZXhwIjoxNTkyMjE3NjgxfQ.A_jBEcn7aC6-9l717WCktXDxPqS5epjXF3SVEG4GjPQ
```

#### 验证

```javascript
const {JWT, JWK} = require('jose')
const key = JWK.asKey({
    kty: 'oct',
    // 自定义密钥，必须与生成时密钥保持一致
    k: 'k04zAv2i134GU6W8mhGFqnftI1lLXRY-Sl7oV0PNy35',
})

try {
    const info = JWT.verify(token, key, {
        // 务必与颁发时保持一致
        audience: 'urn:web:client',
        issuer: 'https://stdout.com.com',
        clockTolerance: '2 hours',
    })
} catch (e) {
    // 验证错误
    // e.code === 'ERR_JWT_EXPIRED' 时，为token过期，可用于重新颁发 token
    // 其他 code 详见文档
}
```

#### 解析

```javascript
const {JWT, JWK} = require('jose')
const key = JWK.asKey({
    kty: 'oct',
    // 自定义密钥，必须与生成时密钥保持一致
    k: 'k04zAv2i134GU6W8mhGFqnftI1lLXRY-Sl7oV0PNy35',
})

const detail = JWT.decode(jwt, key)

// detail
{
    "timestamp"
:
    "2020-06-15T08:54:22.086Z",
        "aud"
:
    [
        "urn:web:client"
    ],
        "iss"
:
    "https://stdout.com.com",
        "iat"
:
    1592211262,
        "exp"
:
    1592218462
}
```

### 接入 egg.js

> Egg.js 大致用法参考[使用 egg.js 为 hexo 搭建后端，实现短链接服务](https://stdout.com.com/url/MjY=)

#### 封装

app/utils/jwt.js

```javascript
const {JWT, JWK} = require('jose')

// 验证 token
module.exports.verifyToken = token => JWT.verify(token, this.asKey(), {
    audience: 'urn:web:client',
    issuer: 'https://stdout.com.com',
    clockTolerance: '2 hours',
})

// 生成token
module.exports.asKey = () => JWK.asKey({
    kty: 'oct',
    k: 'k04zAv2i134GU6W8mhGFqnftI1lLXRY-Sl7oV0PNy35',
})

module.exports.makeToken = () => {
    return JWT.sign({
        timestamp: new Date(),
    }, this.asKey(), {
        audience: ['urn:web:client'],
        issuer: 'https://stdout.com.com',
        expiresIn: '2 hours',
        header: {
            typ: 'JWT',
        },
    })
}

module.exports.decode = jwt => {
    return JWT.decode(jwt, this.asKey())
}
```

#### 控制器

```javascript
const {makeToken, verifyToken} = require('../utils/jwt')
const Controller = require('egg').Controller

class AuthController extends Controller {
    // 生成 jwt-token
    makeToken() {
        // 可选操作，登陆注册等前置操作

        let token = makeToken()
        this.ctx.body = {
            token,
        }
    }

    // 验证token
    checkToken() {
        if (!this.ctx.request.body.token) {
            return this.ctx.body = {
                message: 'token is required',
            }
        }

        try {
            // 获取信息，返回值与 decode 一致
            const client = verifyToken(this.ctx.request.body.token)
        } catch (e) {
            if (e.code === 'ERR_JWT_EXPIRED') {
                // 可选操作，刷新 token
            } else {
                return this.ctx.body = {
                    message: e.message,
                }
            }
        }

        // 业务逻辑
    }
}

module.exports = AuthController
```

#### 路由

```javascript
router.get('/api/secret/make-token', controller.auth.makeToken)
router.get('/api/secret/check-token', controller.auth.checkToken)
```

####    

#### 尝试

```shell
$ curl -L 'https://api.stdout.com.com/api/secret/make-token'
{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0aW1lc3RhbXAiOiIyMDIwLTA2LTE1VDA5OjA4OjA5LjU4NFoiLCJhdWQiOlsidXJuOndlYjpjbGllbnQiXSwiaXNzIjoiaHR0cHM6Ly9wcmludGxuLm9yZyIsImlhdCI6MTU5MjIxMjA4OSwiZXhwIjoxNTkyMjE5Mjg5fQ.WPA46o4rXlAgktIi-ktKA8I351tyL49Z2qdnGeGdALU"}
```


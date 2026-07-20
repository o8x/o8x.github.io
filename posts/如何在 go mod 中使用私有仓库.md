---
display-name: 如何在 go mod 中使用私有仓库
date: 2020-11-10 14:58:21
tags: ["Golang"]
---

## 申请权限

申请 read_repository 权限的 gitlab AccessToken

![image-20201110150456292]({{ env.cdn_accelerate }}/20201110150459.png)

![image-20201110150617958]({{ env.cdn_accelerate }}/20201110150619.png)

## 修改 repo 代理

核心原理就是刚才申请的 token 可以进行免密 clone，`git clone https://oauth2:${TOKEN}@${MODREPO}`

以下命令的作用是将 go mod 中使用默认http无认证的链接，替换为使用token认证的链接，进行免密clone

```shell
TOKEN="xxxx"
MODREPO="gitlab.private.org/backend/repo.git"

$ git config --global url."https://oauth2:${TOKEN}@${MODREPO}".insteadOf "https://${MODREPO}"
```

## 跳过GOPROXY

否则 go mod tidy 时将会被代理到设置的地址，无法获取到包

```shell
$ go env -w GOPRIVATE=gitlab.private.org
```

## 测试

```shell
$ go mod tidy -v
get "gitlab.private.org/backend/repo.git": found meta tag get.metaImport{Prefix:"gitlab.private.org/backend/repo.git", VCS:"git", RepoRoot:"https://gitlab.private.org/backend/repo.git"} at //gitlab.private.org/backend/repo?go-get=1
go: downloading gitlab.private.org/backend/repo.git v1.0.0
```

## 其他git服务器

以上教程适用于 gitlab，其他git服务器可以使用账号密码进行操作、也可以使用 ssh-key 认证

```shell
$ git config --global url."https://gitlabuser:gitlabpassword@${MODREPO}".insteadOf "https://${MODREPO}"
```






---
display-name: 本站的git钩子与自动部署脚本
draft: false
date: 2020-06-22 12:44:33
tags:

- linux
- git

---

## 当前版本

```yml
kind: pipeline
type: ssh
name: deploy

clone:
    depth: 1

server:
    host: stdout.com.com
    user: root
    password:
        from_secret: password

steps:
    -   name: build
        environment:
            PATH: "$$PATH:/opt/node-v14.3.0-linux-x64/bin/"
        commands:
            - yarn
            - yarn build
            - mv config/robots.txt public/robots.txt

    -   name: deploy
        commands:
            - rm -rf /var/www/*
            - mv public/* /var/www/
            - chmod -R 777 /var/www/
            - echo Done!
```

### 历史版本

GIT 钩子

```shell
ssh deploy@stdout.com.com "~/deploy.sh"
```

部署脚本 deploy.sh

```bash
#!/usr/bin/env bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"

# 根目录
root="/opt/stdout.com.com"
# 当前版本
current="${root}/$(date "+%y%m%d-%H%M%S")"

function checkRoot() {
    [[ ! -d $1 ]] && mkdir $1
    [[ ! -f "$1/deploy.sh" ]] && touch "$1/deploy.sh"
}

function install() {
    git clone git@git.stdout.com.com:println.fun/alex-tech.git $1
    cd $1
    yarn && yarn build
    mv config/robots.txt public/robots.txt
    mv config/deploy.sh ${root}
    chmod -R 755 $1
}

function deploy() {
    install $1
    ln -snf $1 "${root}/current"
    # 删除3天前的版本
    rm -rf "${root}/$(date -d "+3 day ago" "+%y%m%d")-*"
}

checkRoot ${root}
deploy ${current}

echo -e "https://stdout.com.com deploy done!"
```

[1] [Alex.如何使用 drone 进行持续集成]( https://stdout.com.com/url/ODQ=)

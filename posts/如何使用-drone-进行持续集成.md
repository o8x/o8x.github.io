---
display-name: 如何使用 drone 进行持续集成
date: 2020-07-09 14:04:46
tags:

- drone

---

## 什么是 Drone

*Drone 是一个现代化的持续集成和持续交付平台，使忙碌的团队能够自动构建、测试和发布工作流。使用 Drone 的团队发布软件的频率更高，bug更少。*<sup>[1](https://docs.drone.io/)</sup>

人话：*Drone 是一个轻量级的 jenkins ，可以简单的实现软件的流水线化测试、编译、部署。并且可以和 gitlab github gogs gitea 轻松的结合到一起。*

## 前提

本文对读者作出以下假设：

- 具有较为丰富的 git 使用经验

- 可以熟练的操作某种 git 服务平台，如 gogs、github、gitlab …. 本文以gogs为例

- 具有一定的 linux 和 docker 的知识储备和操作经验

- 或许也会使用 docker-compose

- 或许懂一点 k8s

环境配置：

- 本文使用 Gogs 为例

- drone 为当前最新版：1.8.x

本文涉及到的工程文件：[https://github.com/o8x/drone-tutorial](https://github.com/alex-techs/drone-tutorial)

## Docker

安装

```shell
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
```

配置镜像加速

https://cr.console.aliyun.com/cn-shanghai/instances/mirrors

```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://xxxx.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 原理

> 个人观点，仅供参考

参与角色

| 角色          | 功能                                                   |
| ------------- | ------------------------------------------------------ |
| 用户          | Gogs                                                   |
| Drone Server  | Drone 主服务，提供Web界面                              |
| Drone Runner  | 我理解为实现各种操作的适配器，例如ssh、docker、k8s操作 |
| Drone Agent   | 操作宿主机 Docker API 的代理程序                       |
| Docker Server | 宿主机的 Doker 程序                                    |

![image-20200709162255567](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200709162257.png)

## 安装

整个 Drone 体系都是基于docker运行的，所以无需安装，拉下几个镜像即可。当然也可以等运行的时候自动处理。

这里只是列出这些镜像和说明其作用

- 主服务

```shell
docker pull drone/drone
```

- docker操作代理

```shell
docker pull drone/agent
```

- ssh runner

以 [ssh runner](https://docs.drone.io/pipeline/ssh/overview/) 为例

```shell
docker pull drone/drone-runner-ssh
```

## 配置

没什么配置，只是几个docker的启动参数而已。

#### server

| 参数                      | 作用                                                  |
| ------------------------- | ----------------------------------------------------- |
| DRONE_GOGS_SERVER         | 要连接的 GOGS 服务器地址                              |
| DRONE_GIT_ALWAYS_AUTH     | 在克隆公共repo时依然进行身份认证                      |
| DRONE_RPC_SECRET          | DRONE 主服务对外接口的密钥，调用所有接口均需要提供    |
| DRONE_SERVER_HOST         | DRONE 主服务启动时监听的地址，类似 server_name 的概念 |
| DRONE_SERVER_PROTO        | DRONE 主服务启动时的协议，http , https，非必须        |
| DRONE_DEBUG               | 默认false，是否输出debug日志，非必须                  |
| DRONE_PROVIDER            | 服务提供者，声明是 gogs，非必须                       |
| DRONE_DATABASE_DATASOURCE | 声明主服务使用的数据源，非必须                        |
| DRONE_DATABASE_DRIVER     | 声明主服务使用的数据库驱动，非必须                    |
| DRONE_GOGS_SKIP_VERIFY    | 是否强制使用TLS与gogs建立链接，默认false，非必须      |

#### agent

| 参数             | 作用                                     |
| ---------------- | ---------------------------------------- |
| DRONE_RPC_SERVER | 即 DRONE_SERVER_HOST                     |
| DRONE_RPC_SECRET | 即 DRONE_RPC_SECRET                      |
| DRONE_DEBUG      | 默认false，是否输出debug日志，非必须     |
| DOCKER_HOST      | 宿主机 docker 的 json api 默认监听的地址 |
| DRONE_RPC_PROTO  | DRONE 主服务启动时的协议，http , https   |

#### ssh-runner

| 参数             | 作用                  |
| ---------------- | --------------------- |
| DRONE_RPC_PROTO  | 即 DRONE_SERVER_PROTO |
| DRONE_RPC_HOST   | 即 DRONE_SERVER_HOST  |
| DRONE_RPC_SECRET | 即 DRONE_RPC_SECRET   |

其它参数大全：[https://docs.drone.io/server/reference/](https://docs.drone.io/server/reference/)

#### 如何使docker监听 tcp 2375 端口

> DOCKER_HOST 需要这个值

编辑宿主机的 /usr/lib/systemd/system/docker.service 文件

找到：

```ini
 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

修改为：

```ini
 ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H fd:// --containerd=/run/containerd/containerd.sock
```

重新加载 service 缓存

```shell
systemctl daemon-reload
```

重启docker

```shell
systemctl restart docker
```

## 启动

#### 环境变量

```shell
export GOGS_URL="http://1.1.2.3:2048"
export DRONE_HOST="0.0.0.0"
export DRONE_SECRET="xh1HJLO2yfandlwjeHdsL3Kklwheour89"
export DOCKER_HOST="tcp://`docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge`:2375"
```

#### server

```shell
docker run -d \
    --volume=/var/lib/drone:/data \
    --env=DRONE_GOGS_SERVER=${GOGS_URL} \
    --env=DRONE_RPC_SECRET=${DRONE_SECRET} \
    --env=DRONE_SERVER_HOST=${DRONE_HOST} \
    --env=DRONE_SERVER_PROTO=http \
    --publish=3005:80 \
    --restart=always \
    --name=drone \
    drone/drone
```

#### agent

```shell
docker run -d \
    --env=DOCKER_HOST=${DOCKER_HOST} \
    --env=DRONE_RPC_SERVER=http://drone-server \
    --env=DRONE_RPC_SECRET=${DRONE_SECRET} \
    --restart=always \
    --name=drone-agent \
    --link drone:drone-server \
    drone/agent
```

#### ssh-runner

```shell
docker run -d \
  -e DRONE_RPC_HOST=drone-server \
  -e DRONE_RPC_SECRET=${DRONE_SECRET} \
  --restart always \
  --name runner \
  --link drone:drone-server \
  drone/drone-runner-ssh
```

## 使用 Web 界面管理构建

如果你正确的启动了上述的几个镜像，那么你打开浏览器，输入IP:3005 可以进入到 DRONE主服务的web管理界面的登陆界面，账号密码为 `DRONE_GOGS_SERVER` 设置的 Gogs 服务器的账号密码。

注意：防火墙一定要开放3005端口，否则是无法访问到 Drone 的

**主界面：**

当你的Gogs加入了新的项目，可以使用 SYNC 按钮同步到 Drone 中来

![image-20200710090528175](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710090530.png)

**为新工程开启构建**

保护设置为，如果勾选 Protected，则不会自动进行构建，需要手动点击允许。

更新：设置公开之后无需登录即可查看项目构建状态。私有则必须登录才可以

![image-20200710092645980](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710092647.png)

**坑**

Save之后将会自动生成 Gogs WebHook，但是它生成的地址未经转换，直接是 DRONE_HOST 拼接了 /hook，那就会产生一些问题

1. 我们配置地址为0.0.0.0是为了公网可访问，那它生成这样的地址要上哪里发回调。我们要手动改成浏览器中可以访问的那个地址，例如：`http://xxx.org:3005/hook`。

   **无论你配置的什么地址，都应该亲自来 Gogs 中看一看，是否是可访问的地址**

   ![image-20200710093643951](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710093646.png)

1. 如果我们配置的 DRONE_HOST 是 127.0.0.1/
   那么它将会生成这样的地址，暂时先不关注端口的话，就只有多了个/的问题。按常理来讲多一个/不会影响请求效果，但是Drone会受影响，要手动去掉/，修改为正确地址才可以。例如：`http://xxx.org:3005/hook`。

   ![image-20200710093815148](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710093817.png)

1. 配置完成后你需要点铅笔符号，拉到最下面，有一个 Test Delivery ，点击下去观察是否可以成功推送。

   如果是这样，那就要重新检查你的 Webhook 域名配置了。

   ![image-20200710094735492](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710094737.png)

   如果是绿色，说明你的配置正确。**并且 Drone 将会启动第一次构建，但是因为我们没有 .drone.yml 文件，所以构建一定是失败的**

   ![image-20200710094911258](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710094913.png)

**项目详情界面**

![image-20200710091938754](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710091940.png)

## 书写 .drone.yml 配置文件

#### Hello World

在你的项目根目录，新建 .drone.yml 并写入以下内容

```yml
kind: pipeline
name: default
steps:
    -   name: Hello World
        image: centos
        commands:
            - echo Hello World
```

| Key            | 含义                                                         |
| -------------- | ------------------------------------------------------------ |
| kind           | 默认为 pipeline                                              |
| type           | 这里没有用到，标志本次构建使用的 runner 类型，默认是  docker 即默认使用Docker Runner |
| name           | 因为drone支持同时书写多个构建任务，所以需要为本任务起个名字  |
| steps          | 数组结构，流水线化的构建步骤                                 |
| steps.images   | 本步骤运行在哪个docker镜像中，该镜像必须存在于 docker hub 中 |
| steps.commands | 构建过程中，将会依次执行的命令，如果命令退出码非0，将会终止构建本次构建 |

提供 JSON 版本来辅助理解数据结构。当然也可以直接使用json，因为json是合法的yml格式

```json
{
    "kind":  "pipeline",
    "name":  "default",
    "steps": [
        {
            "name":     "Hello World",
            "image":    "centos",
            "commands": [
                "echo Hello World"
            ]
        }
    ]
}
```

Drone 配置文件除 yml 和 json 之外，还可以使用
jsonnet，官方示例：[https://docs.drone.io/pipeline/scripting/jsonnet/](https://docs.drone.io/pipeline/scripting/jsonnet/)

#### 一次大胆的尝试

```shell
cat >.drone.yml<<EOF
kind: pipeline
name: default
steps:
    -   name: Hello World
        image: centos
        commands:
            - echo Hello World
EOF

git add .drone.yml
git commit -am "first commit"
git push origin master
```

**Gogs**

![image-20200710103206262](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710103208.png)

**Drone**

![image-20200710103405063](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710103406.png)

![image-20200710103716309](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710103718.png)

![image-20200710103924129](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710103925.png)

**注：**如果你的构建一直处于等待开始状态，也就是齿轮转圈不成功也不失败。你就要检查一下 agent 容器是否正确的启动和drone 主服务是否能正确的链接到 agent 容器中了。一般来说是主服务没有链接上，一直在等待 agent。

## 关于秘密

`为新工程开启构建` 一节已经略微解释过秘密的作用。本节主要描述如何使用秘密

#### 新建秘密

为什么我们要定义一个叫做 log-path 的值，而不是password等真的秘密。一会儿你就知道了

![image-20200710110347778](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710110349.png)

添加完成

![image-20200710110444166](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710110445.png)

#### 在 .drone.yml 中使用秘密

修改 Hello World 时建立的 .drone.yml，使用 from_secret 来取出秘密的值

```yml
cat >.drone.yml<<EOF
kind: pipeline
name: default
steps:
    -   name: Hello World
        image: centos
        environment:
            VARPATH: /var
            LOGPATH:
                from_secret: log-path
        commands:
            - echo $${VARPATH}
            - echo $${LOGPATH}
            - ls $${LOGPATH}
    EOF

    git add .drone.yml
    git commit -am "first commit"
    git push origin master
```

我们加入了 environment 组，该组的作用是在运行的容器内预先设置一些环境变量。并且建立了几个环境变量。

**重点：** VARPATH是直接明文，LOGPATH 则是使用了 from_secret 并输入了我们刚才在web界面上新建的秘密的key。

所以可以简单的理解 from_secret 是为了从秘密读取某个key，from_secret 除了 environment 之外，也可以应用于任意的字段中。

**注：**一般的shell命令使用一个$来获取变量，而 commands 使用$$ 是因为 yml 会解析$，并且替换为yml变量值，使用两个$$转义则可以保持原文。

#### 验证

![image-20200710112713961](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710112714.png)

**注：**因为无法看到原文，所以使用password举例的话并不能验证是否正确。使用一个目录来 ls 则可以判断是否真的读取到了秘密的值

## Runner

*管道可帮助您自动执行软件交付过程中的步骤，例如启动代码生成、运行自动测试以及部署到暂存环境或生产环境。管道执行由源代码存储库触发。代码更改会触发运行相应管道的 Drone 的
Webhook。其他常见触发器包括自动计划或用户启动的工作流。通过将文件放在 git 存储库的根目录来配置管道。yaml 语法设计为易于阅读和表达，以便查看存储库的任何人都可以理解工作流。*

本例使用刚才启动的 ssh
runner，其它runner的使用可参考官方示例[https://docs.drone.io/pipeline/overview/](https://docs.drone.io/pipeline/overview/)

```shell
npm init
npm install helloworld

cat >.drone.yml<<EOF
kind: pipeline
type: ssh
name: default

server:
    host: xxxx.org
    user: root
    password:
        from_secret: password
  # ssh_key:
  #         from_secret: ssh_key
    
steps:
    -   name: list
        commands:
            - ls /var
    -   name: npm
        environment:
            PATH: "$$PATH:/opt/node-v14.3.0-linux-x64/bin/"
        commands:
            - pwd
            - node --version
            - npm version
            - npm install
EOF

git add .
git commit -am "first commit"
git push origin master
```

**注：**

1. 这里的 password 我们使用的就是从秘密中获取到的
1. 也可以使用 ssh_key 来链接，但是我们启动 ssh runner 时并未映射key文件，所以使用密码进行演示。
1. npm init 是为了让项目转换成npm项目，以演示 npm 等命令，并非必须
1. PATH设置这个值是我的 node安装目录，为了让 commands 中的 npm 可以正确执行。你可以换成你自己的node安装路径
1. 这次配置了多个 step，drone 也将会在ssh链接到的主机中依次执行这些命令。

#### 执行结果

![image-20200710135012935](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710135015.png)

![image-20200710135107129](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710135108.png)

执行正确，构建完成。

![image-20200710135930241](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710135931.png)

## 复合构建任务

我们在 Hello World 中提到过，是可以书写多个构建任务的。原理是利用 yml 可以使用 `--- …` 拼接多个文件的特性，简单的可以理解为 .drone.yml 可以是多个 .drone.yml 拼起来的。

示例：将我们的 Hello World 和 ssh runner 任务拼起来，同时执行。

```yml
---
kind: pipeline
name: Hello World
steps:
    -   name: Hello World
        image: centos
        environment:
            VARPATH: /var
            LOGPATH:
                from_secret: log-path
        commands:
            - echo $${VARPATH}
            - echo $${LOGPATH}
            - ls $${LOGPATH}

---

kind: pipeline
type: ssh
name: Ssh-Runner

server:
    host: xxxxx.org
    user: root
    password:
        from_secret: password

steps:
    -   name: list
        commands:
            - ls /var
    -   name: npm
        environment:
            PATH: "$$PATH:/opt/node-v14.3.0-linux-x64/bin/"
        commands:
            - pwd
            - node --version
            - npm version
            - npm install
...
```

每一对`---`中间，就是一个构建任务。`...` 表示结束，可省略。

### 效果

![image-20200710142452894](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710142454.png)

![image-20200710142522447](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710142523.png)

## 使用 docker-compose 编排容器

本文不对 docker-compose 进行讲解，可前往官网学习。

这份文件的作用与启动一节的ssh命令效果一致。其中的DOCKER_HOST 需要根据实际的值来进行替换

```shell
cat >docker-compose.yml<<EOF
version: '3'
services:
    drone-server:
        image: drone/drone
        ports:
            - 3005:80
        volumes:
            - /var/lib/drone:/data
        environment:
            - DRONE_GOGS_SERVER=http://1.1.2.3:2048
            - DRONE_RPC_SECRET=xh1HJLO2yfandlwjeHdsL3Kklwheour89
            - DRONE_SERVER_HOST=0.0.0.0
            - DRONE_SERVER_PROTO=http

    drone-agent:
        image: drone/agent
        depends_on:
            - drone-server
        environment:
            - DRONE_RPC_SERVER=http://drone-server
            - DRONE_RPC_SECRET=xh1HJLO2yfandlwjeHdsL3Kklwheour89
            - DOCKER_HOST=tcp://172.17.0.1:2375
        links:
            - drone-server

    drone-ssh:
        image: drone/drone-runner-ssh
        depends_on:
            - drone-server
        environment:
            - DRONE_RPC_PROTO=http
            - DRONE_RPC_HOST=drone-server
            - DRONE_RPC_SECRET=xh1HJLO2yfandlwjeHdsL3Kklwheour89
        ports:
            - 3000:3000
        links:
            - drone-server
EOF

docker-compose up -d
```

## 插件

Drone 还有相当丰富的插件可以使用，示例：[https://docs.drone.io/plugins/overview/](https://docs.drone.io/plugins/overview/)

并不像其它的软件一样提供插件开发的api，drone 插件的原理就是运行docker镜像。在容器启动时自动加载step中写入的环境变量或命令。你可以完全将插件可以将它当作一种 step。

原理简单，不再赘述。

## 我们最终的代码结构

```shell
.
├── .git
│ └── ...
├── node_modules
│ └── helloworld
│     └── ...
├── .drone.yml
├── package-lock.json
└── package.json
```

## 补充

在 Settings 页面的底部，可以生成一个小图标链接，标志当前工程的最近一次构建状态。b格满满hhhhh

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710162450.png)

一瞬间成就感就来了hhhhh，感觉花两天时间研究 drone 是超值的

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200710162640.png)

## 总结

我们已经学会了 drone 的安装、配置、基本使用，也知道了如何使用drone进行自动构建和排查出现的问题，学到了“秘密”的使用方法，还学会了一个 ssh runner 和执行多个构建任务。

那么现在我们就可以实现在代码更新后自动操作远程主机，更新、测试、编译、部署，实现基本的持续集成。

但是**Drone 的能力，远不止于此。**

## 附录

**一键部署脚本**

```shell
#!/bin/bash
set -e

export GOGS_URL="http://yougogshost"
export DRONE_HOST="youhost:3000"
export DRONE_SECRET="you secret"
export DOCKER_HOST="tcp://`docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge`:2375"

docker kill drone-agent runner drone || true
docker rm drone-agent runner drone || true

docker run -d \
    --volume=/var/lib/drone:/data \
    --env=DRONE_GOGS_SERVER=${GOGS_URL} \
    --env=DRONE_RPC_SECRET=${DRONE_SECRET} \
    --env=DRONE_SERVER_HOST=${DRONE_HOST} \
    --env=DRONE_SERVER_PROTO=http \
    --publish=3000:80 \
    --restart=always \
    --name=drone \
    drone/drone

docker run -d \
    --env=DOCKER_HOST=${DOCKER_HOST} \
    --env=DRONE_RPC_SERVER=http://drone-server \
    --env=DRONE_RPC_SECRET=${DRONE_SECRET} \
    --restart=always \
    --name=drone-agent \
    --link drone:drone-server \
    drone/agent

docker run -d \
  -e DRONE_RPC_HOST=drone-server \
  -e DRONE_RPC_SECRET=${DRONE_SECRET} \
  --restart always \
  --name runner \
  --link drone:drone-server \
  drone/drone-runner-ssh
```


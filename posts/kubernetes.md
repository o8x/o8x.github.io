---
display-name: kubernetes  
date: 2024-06-02 15:59:10
tags: ["Linux"]
---

- 本文内容部分来自 `https://kubernetes.io/zh-cn/docs/tutorials`

## 理论

主要概念

### Pod

> Pod 是 Kubernetes 抽象出来的， 表示一组一个或多个应用容器（如 Docker），以及这些容器的一些共享资源。这些资源包括：

- 共享存储，当作卷
- 网络，作为唯一的集群 IP 地址
- 有关每个容器如何运行的信息，例如容器镜像版本或要使用的特定端口

![](https://cdn-1252251443.cos.ap-nanjing.myqcloud.com/x/1717317988127.png)

### Node

> Pod 总是运行在节点上。节点是 Kubernetes 中参与计算的机器，可以是虚拟机或物理计算机，具体取决于集群。每个节点由控制面管理。节点可以有多个 Pod，Kubernetes 控制面会自动处理在集群中的节点上调度 Pod。控制面的自动调度考量了每个节点上的可用资源。

每个 Kubernetes 节点至少运行：

- Kubelet，负责 Kubernetes 控制面和节点之间通信的进程；它管理机器上运行的 Pod 和容器。
- 容器运行时（如 Docker）负责从镜像仓库中提取容器镜像、解压缩容器以及运行应用。

![](https://cdn-1252251443.cos.ap-nanjing.myqcloud.com/x/1717318226323.png)

### ReplicaSet

> ReplicaSet 的目的是维护一组在任何时候都处于运行状态的 Pod 副本的稳定集合。因此，它通常用来保证给定数量的、完全相同的 Pod 的可用性。
> 每个 ReplicaSet 都通过根据需要创建和删除 Pod 以使得副本个数达到期望值，进而实现其存在价值。当 ReplicaSet 需要创建新的 Pod 时，会使用所提供的 Pod 模板。

因此，我们可以在外部动态的调整副本数量，而无需直接触及容器管理，这些工作由 ReplicaSet 自动完成。

### Deployment

> 一个 Deployment 为 Pod 和 ReplicaSet 提供声明式的更新能力。
> 你负责描述 Deployment 中的目标状态，而 Deployment 控制器（Controller） 以受控速率更改实际状态， 使其变为期望状态。你可以定义 Deployment 以创建新的 ReplicaSet，或删除现有 Deployment， 并通过新的 Deployment 收养其资源。

Deployment 是对 ReplicaSet 和 Pod 的更高级抽象。因此我们可以从外部定义业务状态，由 Controller 动态管理 ReplicaSet 以达成这种状态，ReplicaSet 再根据需求动态管理 Pod 数量，Pod 再自动进行容器状态的维护。

### Service

> Kubernetes 中 Service 是 将运行在一个或一组 Pod 上的网络应用程序公开为网络服务的方法。关键目标是让你无需修改现有应用以使用某种不熟悉的服务发现机制。你可以在 Pod 集合中运行代码，无论该代码是为云原生环境设计的，还是被容器化的老应用。你可以使用 Service 让一组 Pod 可在网络上访问，这样客户端就能与之交互。
> 如果你使用 Deployment 来运行你的应用， Deployment 可以动态地创建和销毁 Pod。在任何时刻，你都不知道有多少个这样的 Pod 正在工作以及它们健康与否； 你可能甚至不知道如何辨别健康的 Pod。Kubernetes Pod 的创建和销毁是为了匹配集群的预期状态。Pod 是临时资源（你不应该期待单个 Pod 既可靠又耐用）。
> 每个 Pod 会获得属于自己的 IP 地址（Kubernetes 期待网络插件来保证这一点）。对于集群中给定的某个 Deployment，这一刻运行的 Pod 集合可能不同于下一刻运行该应用的 Pod 集合。

### Namespace

很好理解的常见概念，就是将同一集群中的资源划分为相互隔离的组。

***作用域仅针对带有Namespace的对象（例如 Deployment、Service 等），这种作用域对集群范围的对象（例如
StorageClass、Node、PersistentVolume 等）不适用。***

### Gateway API

其前身为 Ingress 组件

#### Ingress

> Ingress 是对集群中服务的外部访问进行管理的 API 对象，典型的访问方式是 HTTP。可以提供负载均衡、SSL 终结和基于名称的虚拟托管。

可以认为类似对 Service 暴露的端口进行反向代理并向外部提供类似负载均衡、TLS、域名解析的服务。

#### Gateway API

> Gateway API 通过使用可扩展的、角色导向的、 协议感知的配置机制来提供网络服务。它是一个附加组件， 包含可提供动态基础设施配置和高级流量路由的 API 类别。

Gateway API 具有三种稳定的 API 类别：

> GatewayClass： 定义一组具有配置相同的网关，由实现该类的控制器管理。
> Gateway： 定义流量处理基础设施（例如云负载均衡器）的一个实例。
> HTTPRoute： 定义特定于 HTTP 的规则，用于将流量从网关监听器映射到后端网络端点的表示。 这些端点通常表示为 Service。

![](https://cdn-1252251443.cos.ap-nanjing.myqcloud.com/x/1718381504292.png)

简而言之就是对协议层进行了更高级别抽象 Ingress，以支持不同协议。

### ConfigMap

> ConfigMap 是一种 API 对象，用来将非机密性的数据保存到键值对中。使用时 Pod 可以将其用作环境变量、命令行参数或者存储卷中的配置文件。
> ConfigMap 将你的环境配置信息和容器镜像解耦，便于应用配置的修改。

***ConfigMap 并不提供保密或者加密功能。如果你想存储的数据是机密的，请使用 Secret，或者使用其他第三方工具来保证你的数据的私密性，而不是用
ConfigMap。***

类似CI过程中外部注入的机密信息，例如 gitlab ci 的 Variables 或 github action 的 Secrets。

#### Secret

> Secret 是一种包含少量敏感信息例如密码、令牌或密钥的对象。 这样的信息可能会被放在 Pod 规约中或者镜像中。 使用 Secret 意味着你不需要在应用程序代码中包含机密数据。
> 由于创建 Secret 可以独立于使用它们的 Pod， 因此在创建、查看和编辑 Pod 的工作流程中暴露 Secret（及其数据）的风险较小。 Kubernetes 和在集群中运行的应用程序也可以对 Secret 采取额外的预防措施， 例如避免将敏感数据写入非易失性存储。
> Secret 类似于 ConfigMap 但专门用于保存机密数据。

Secret 本质上只是 base64(ConfigMap)，如果不进行 RBAC 和 静态加密的话，任何有权限在命名空间中创建 Pod 的人都可以使用该访问权限读取该命名空间中的任何 Secret。

## 部署本地单节点集群

本文不使用 minikube 而是以 Docker Desktop 中的 kubernetes 为例。如图所示，勾选 Enable kubernetes 并 Apply & Restart 即可在本地开启单节点的 k8s 集群。

![](https://cdn-1252251443.cos.ap-nanjing.myqcloud.com/x/1717315248885.png)

### kubectl

验证和安装

```shell
which kubectl || brew install kubectl
```

使用 kubectl 验证本地节点工作是否正常：

```shell
kubectl version
```

输出示例

```shell
Client Version: v1.30.1
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.29.2
```

获取节点

```shell
kubectl get nodes
```

输出示例

```shell 
NAME             STATUS   ROLES           AGE    VERSION
docker-desktop   Ready    control-plane   3d5h   v1.29.2
```

## 部署应用

### 示例应用

在这个应用中我们在80端口启动了一个 http server，实现了获取请求和系统信息，并把这些信息通过响应发送给请求者和打印在控制台上。

```go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
)

func main() {
	http.DefaultServeMux.HandleFunc("/", func(writer http.ResponseWriter, request *http.Request) {
		data, _ := json.Marshal(map[string]any{
			// "version":     "v2", // 在 v2 版本中启用
			"time":        time.Now(),
			"remote_addr": request.RemoteAddr,
			"uri":         request.RequestURI,
			"method":      request.Method,
			"user_agent":  request.Header.Get("User-Agent"),
			"hostname":    os.Hostname(),
			"env":         os.Environ(),
		})

		fmt.Println(string(data))
		_, _ = writer.Write(data)
	})

	if err := http.ListenAndServe("0.0.0.0:80", http.DefaultServeMux); err != nil {
		panic(err)
	}
}
```

示例 Dockerfile

```dockerfile
FROM golang:1.22.3-bookworm as builder

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

COPY . .

RUN go build -v -o /app/app main.go

FROM alpine:edge

COPY --from=builder /app/app /usr/bin/app

EXPOSE 80
CMD ["/usr/bin/app"] 
```

编译

```shell
docker build --platform linux/amd64 -t registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server .
```

运行验证

```shell
docker run -it -p 8080:80 registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server
```

```shell
curl http://localhost:8080
{"env":[...],"method":"GET","node":"http-server-544cd85769-5s26v","remote_addr":"192.168.65.3:56444","time":"2024-06-02T12:34:43.719519587Z","uri":"/","user_agent":"curl/8.4.0"}
```

推送

```shell
docker push registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server
```

### 部署 deployment

让我们使用 kubectl create deployment 部署应用，以下命令中的 `http-server` 是 deployment 的名字，`registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server` 是镜像的位置

```shell
kubectl create deployment http-server --image=registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server
```

列出现有的 deployments

```shell
kubectl get deployments
```

```shell
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
http-server   1/1     1            1           7s
```

- NAME 列出 Deployment 在集群中的名称。
- READY 显示当前/预期（CURRENT/DESIRED）副本数的比例。
- UP-TO-DATE 显示为了达到预期状态，而被更新的副本的数量。
- AVAILABLE 显示应用有多少个副本对你的用户可用。
- AGE 显示应用的运行时间。

## 查看应用

pod 是 kubernetes 的原子单元，每个 deployments 都至少有一个 pod。pod 运行在私有的、隔离的网络上。这些 pod 在同一 kubernetes 集群内可见。因此我们事实上无法从外部访问这个应用。

```shell
kubectl get pods
```

```shell
NAME                           READY   STATUS    RESTARTS   AGE
http-server-544cd85769-lwdzg   1/1     Running   0          21s
```

我们可以通过 kubectl proxy 创建一个代理，将通信转发到 kubernetes 集群的私有网络中。

```shell
kubectl proxy
```

输出

```shell
Starting to serve on 127.0.0.1:8001
```

因为我们可以通过 http://127.0.0.1:8001 来访问应用。使用 `curl http://127.0.0.1:8001/version` 请求可以得到以下结果。

```json
{
    "major":        "1",
    "minor":        "29",
    "gitVersion":   "v1.29.2",
    "gitCommit":    "4b8e819355d791d96b7e9d9efe4cbafae2311c88",
    "gitTreeState": "clean",
    "buildDate":    "2024-02-14T10:32:40Z",
    "goVersion":    "go1.21.7",
    "compiler":     "gc",
    "platform":     "linux/arm64"
}
```

获取 pod 信息

```shell
pod_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
curl http://localhost:8001/api/v1/namespaces/default/pods/$pod_NAME/
```

```json
{
    "kind":       "pod",
    "apiVersion": "v1",
    "metadata":   {
        "name":   "http-server-f95c5b745-xhdfn",
        "labels": {
            "app": "http-server"
        }
    },
    ...
}
```

## 故障排除

获取容器名

```shell
POD_NAME="$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')"
```

查看容器日志

```shell
kubectl logs "$POD_NAME"
```

执行命令，打印环境变量

```shell
kubectl exec "$POD_NAME" -- env
```

交互式执行

```shell
kubectl exec -it "$POD_NAME" -- sh
```

## 暴露并公开应用

Kubernetes Pod 是短暂的，具有生命周期。当工作节点故障时，上面的 Pod 会失效。ReplicaSet 确保集群通过自动创建新 Pod 来保持目标状态。例如，一个图像处理后端程序可能有3个可替换副本，前端无需关心后端Pod的具体实例。每个Pod在集群中都有唯一IP，但需要通过Service进行内部和外部通信。

Kubernetes Service 定义了Pod的逻辑集合和访问协议，实现Pod间的松耦合。Service用YAML或JSON定义，可公开Pod的访问方式。类型包括：

- ClusterIP（默认）：仅集群内访问。
- NodePort：集群节点上公开，可外部访问。
- LoadBalancer：在云环境中创建外部负载均衡器。
- ExternalName：映射到外部域名。

某些Service用例不需要定义selector，允许手动映射到特定端点或使用ExternalName类型。

![](https://cdn-1252251443.cos.ap-nanjing.myqcloud.com/x/1717322022724.png)

列举当前集群中的 Service

```shell
kubectl get services
```

默认有一个名为 kubernetes 的 Service 在 docker desktop 启动集群时被创建。

```shell
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   3d7h
```

如果要创建 service 并暴露给外部，需要使用 expose 命令，并指定类型为 NodePort。

```shell
kubectl expose deployment/http-server --type="NodePort" --port 80
```

以上命令将为 http-server 这个 deployment 创建一个 service，并自动代理容器内的 80 端口，可以通过以下命令查询代理端口。

```shell
NODE_PORT="$(kubectl get services/http-server -o go-template='{{(index .spec.ports 0).nodePort}}')"
```

或通过 `kubectl get services/http-server` 查看端口映射

```shell
NAME          TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
http-server   NodePort   10.108.107.132   <none>        80:32663/TCP   3m52s
```

当然也可以方便的指定目标端口

```shell
kubectl expose deployment/http-server --type="NodePort" --port 80 --target-port=9376
```

运行 `curl -v "http://localhost:$NODE_PORT"`，然后我们就会收到应用响应。

```shell
*   Trying [::1]:30594...
* Connected to localhost (::1) port 30594
> GET / HTTP/1.1
> Host: localhost:30594
> User-Agent: curl/8.4.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Sun, 02 Jun 2024 10:07:24 GMT
< Content-Length: 127
< Content-Type: text/plain; charset=utf-8
< 
* Connection #0 to host localhost left intact
{"env":[...],"method":"GET","node":"http-server-544cd85769-5s26v","remote_addr":"192.168.65.3:56444","time":"2024-06-02T12:34:43.719519587Z","uri":"/","user_agent":"curl/8.4.0"}
```

## 启动多个实例

Deployment 仅创建了一个 Pod 用于运行这个应用。当流量增加时，我们需要通过改变 Deployment 中的副本数量来实现的容器数量的扩缩，以使应用满足用户需求。如果要动态扩容，则需要 LoadBalancer 类型的服务。对 Deployment 横向扩容将保证新的 Pod 被创建并调度到有可用资源的 Node 上，扩容会将 Pod 数量增加至新的预期状态。一旦有了多个应用实例，就可以进行滚动更新而无需停机。

> 运行多实例的应用，需要有方法在多个实例之间分配流量。Service 有一个集成的负载均衡器， 将网络流量分配到一个可公开访问的 Deployment 的所有 Pod 上。服务将会一直通过端点来监视 Pod 的运行，保证流量只分配到可用的 Pod 上。

删除和重建服务

```shell
kubectl delete services/http-server
kubectl expose deployment/http-server --type="LoadBalancer" --port 80 --target-port=9376
```

*注：LoadBalancer 无法在集群外部访问，需要交给前端负载均衡器如 ingress，再由 ingress 暴露到外部访问。*
*因此，后续将仍然参考 NodePort 进行实验。*

### 扩容

扩容到3个实例

```shell
kubectl scale deployments/http-server --replicas=3
```

使用 `kubectl get deployments` 重新列出 deployments，会发现 AVAILABLE 变成了3，即三个副本对用户生效。

```shell
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
http-server   3/3     3            3           5m2s
```

使用 `kubectl get pods -o wide` 观察 pod

```shell
NAME                           READY   STATUS    RESTARTS   AGE     IP          NODE             NOMINATED NODE   READINESS GATES
http-server-544cd85769-5s26v   1/1     Running   0          6m30s   10.1.0.12   docker-desktop   <none>           <none>
http-server-544cd85769-6fp9m   1/1     Running   0          94s     10.1.0.13   docker-desktop   <none>           <none>
http-server-544cd85769-ztwx9   1/1     Running   0          94s     10.1.0.14   docker-desktop   <none>           <none>
```

现在有 3 个 Pod，各有不同的 IP 地址。这一变化会记录到 Deployment 的事件日志中。可以使用 describe 来查看

```shell
kubectl describe deployments/http-server
```

可以从日志输出中看到，副本数量被 Scaled 从 1 变更到了 3

```text
....
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  7m28s  deployment-controller  Scaled up replica set http-server-544cd85769 to 1
  Normal  ScalingReplicaSet  2m32s  deployment-controller  Scaled up replica set http-server-544cd85769 to 3 from 1
```

虽然副本数量大于1，但我们仍然可以通过 LoadBalancer 获得统一的入口IP和端口。获取方法与前文获取 `NODE_PORT` 方法一致。

即：

```shell
kubectl get services/http-server -o go-template='{{(index .spec.ports 0).nodePort}}'
```

可以使用以下命令查看端口是否切实被监听

```shell
ss -tnlp || netstat -ALlaW 
```

我们通过发送多次请求来确认负载均衡是否正常运行

```shell
seq 10 | xargs -I {} curl -s 127.0.0.1:32663 | jq .node
```

通过10次发送，命中了三个不同的 pod

```
"http-server-544cd85769-5s26v"
"http-server-544cd85769-5s26v"
"http-server-544cd85769-6fp9m"
"http-server-544cd85769-6fp9m"
"http-server-544cd85769-ztwx9"
"http-server-544cd85769-6fp9m"
"http-server-544cd85769-5s26v"
"http-server-544cd85769-6fp9m"
"http-server-544cd85769-5s26v"
"http-server-544cd85769-6fp9m"
```

### 缩容

与扩容使用相同的命令

```shell
kubectl scale deployments/http-server --replicas=2
```

和扩容相同，也可以使用 `kubectl describe deployments/http-server` 查看日志，可以观察到副本数量被 Scaled 从 3 变更到了 2

```text
....
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  58m   deployment-controller  Scaled up replica set http-server-544cd85769 to 3 from 1
  Normal  ScalingReplicaSet  6s    deployment-controller  Scaled down replica set http-server-544cd85769 to 2 from 3
```

## 滚动更新

滚动更新允许通过使用新的实例逐步更新 Pod 实例，实现零停机的 Deployment 更新。

```shell
kubectl describe pods -l app=http-server
```

在输出中检索 Image 字段或使用 `grep Image: | head -1` 管道来查看当前服务版本

更新镜像版本

```shell
kubectl set image deployments/http-server hello=registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server-v2
```

该镜像尚不存在，因此 `kubectl get pods` 将会出现 ImagePullBackOff 错误。

```shell
NAME                           READY   STATUS             RESTARTS   AGE
http-server-544cd85769-6fp9m   1/1     Running            0          84m
http-server-544cd85769-ztwx9   1/1     Running            0          84m
http-server-66f45b6b5b-tr4tn   0/1     ImagePullBackOff   0          15s
```

### 修改镜像

我们修改程序，增加 version 字段并重新编译和推送

```text 
...
data, _ := json.Marshal(map[string]any{
	"version":     "v2",
	...
})
...
```

编译和推送

```shell
docker build --platform linux/amd64 -t registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server-v2 .
```

```shell
docker push registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server-v2
```

### 确认更新完成

再次执行 `kubectl set image` 即可重新更新

```shell
kubectl rollout status deployments/http-server
```

可见输出为更新成功

```shell
deployment "http-server" successfully rolled out
```

如果更新比较慢，则可能输出为

```shell
Waiting for deployment "http-server" rollout to finish: 1 out of 2 new replicas have been updated...
```

再次确认 `kubectl describe pods` 中的 Image 字段值

```text 
...
    Image:          registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server-v2
...
```

### 回滚

回滚到上一个版本

```shell
kubectl rollout undo deployments/http-server
```

回滚成功

```shell
deployment.apps/http-server rolled back
```

## 清理本地集群

```shell
kubectl delete deployments/http-server services/http-server
```

## 配置组件

创建一个配置文件

```shell
cat >http-server-config.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
    name: http-server-config
data:
    client-config: |
        {
            "type": "client",
            "version": "v2c",
            "config": "from-config-map"
        }
    server-config: |
        {
            "type": "server",
            "version": "v2c",
            "config": "from-config-map"
        }
EOF

```

应用这个配置文件

```shell
kubectl apply -f http-server-config.yaml
```

查看配置

```shell
kubectl describe configmap http-server-config
```

以 yaml 格式查看

```shell
kubectl get configmap http-server-config -o yaml
```

删除配置

```shell
kubectl delete configmap/http-server-config
```

以文件格式删除

```shell
kubectl delete -f http-server-config.yaml
```

### 在 Deployment 中挂载 ConfigMap

文件生成自命令行

```shell
kubectl create deployment http-server --image=registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server -o yaml > deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    creationTimestamp: "2024-06-03T02:51:31Z"
    generation: 1
    labels:
        app: http-server
    name: http-server
    namespace: default
    resourceVersion: "197263"
    uid: 750f3d90-025e-4b79-a688-8344044c79f9
spec:
    progressDeadlineSeconds: 600
    replicas: 1
    revisionHistoryLimit: 10
    selector:
        matchLabels:
            app: http-server
    strategy:
        rollingUpdate:
            maxSurge: 25%
            maxUnavailable: 25%
        type: RollingUpdate
    template:
        metadata:
            creationTimestamp: null
            labels:
                app: http-server
        spec:
            containers:
                -   image: registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server
                    imagePullPolicy: IfNotPresent
                    name: hello
                    resources: { }
                    terminationMessagePath: /dev/termination-log
                    terminationMessagePolicy: File
                    volumeMounts:
                        -   name: app-config
                            mountPath: /config
            volumes:
                -   name: app-config
                    configMap:
                        name: http-server-config
                        items:
                            -   key: server-config
                                path: server.conf
                            -   key: client-config
                                path: client.conf
            dnsPolicy: ClusterFirst
            restartPolicy: Always
            schedulerName: default-scheduler
            securityContext: { }
            terminationGracePeriodSeconds: 30
status: { } 
```

以上配置文件做了如下工作

1. 将名为 `http-server-config` 的 ConfigMap 在 `spec.template.spec.volumes` 部分声明到了 `app-config` 卷
2. 将 key 挂载为文件
	1. 在 `app-config` 卷中，将 `http-server-config` 这个 ConfigMap 中的 `data.client-config` 声明为文件 `client.conf`
	2. 在 `app-config` 卷中，将 `http-server-config` 这个 ConfigMap 中的 `data.server-config` 声明为文件 `server.conf`
3. 在 `spec.template.spec.containers.volumeMounts` 中将 `app-config` 卷挂载到 `/config` 目录

应用 yaml 文件创建 deployment

```shell
kubectl apply -f deployment.yaml
```

`kubectl get pods` 查看 pods

```shell                                                      
NAME                          READY   STATUS    RESTARTS   AGE
http-server-76c474fff-8t8qc   1/1     Running   0          3m55s
```

执行 `kubectl exec -it http-server-76c474fff-8t8qc -- ls -l /config` 来查看真实的目录映射

```shell
total 12
drwxrwxrwx    3 root     root          4096 Jun  3 03:36 .
drwxr-xr-x    1 root     root          4096 Jun  3 03:36 ..
lrwxrwxrwx    1 root     root            20 Jun  3 03:36 client.config -> ..data/client.config
lrwxrwxrwx    1 root     root            20 Jun  3 03:36 server.config -> ..data/server.config
```

文件内容也和 ConfigMap 中定义的一样

```shell
kubectl exec -it http-server-76c474fff-8t8qc -- cat /config/server.config
{
    "type": "server",
    "version": "v2c",
    "config": "from-config-map"
}
```

也可以直接省略 items 的手动映射过程，deployment 会自动映射

```text 
...
		volumeMounts:
			-   name: app-config
				mountPath: /config
volumes:
	-   name: app-config
		configMap:
			name: http-server-config
...
```

查看目录结构发现，自动在文件系统中映射了与 ConfigMap 的两个 key 同名的文件，查看内容也与手动映射一致

```shell
total 0
lrwxrwxrwx    1 root     root            20 Jun  3 04:31 client-config -> ..data/client-config
lrwxrwxrwx    1 root     root            20 Jun  3 04:31 server-config -> ..data/server-config
```

查看内容 `kubectl exec -it http-server-79554d4b94-9qm2s -- cat /config/server-config`

```shell
{
    "type": "server",
    "version": "v2c",
    "config": "from-config-map"
}
```

*重新 apply configmap，pod 是无感知的，重启 pod 后生效*

### 在 Pod 中挂载 ConfigMap

并不推荐单独创建 Pod，因为文件比较简单，可操作性较差。但用来测试效果是可以的

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: redis
spec:
    containers:
        -   name: redis
            image: registry.cn-hongkong.aliyuncs.com/o8x/hello:http-server-v2
            command:
                - /usr/bin/app
                - /server-config-data/server.config
            env:
                -   name: MASTER
                    value: "true"
            ports:
                -   containerPort: 6379
            resources:
                limits:
                    cpu: "0.1"
            volumeMounts:
                -   mountPath: /server-config-data
                    name: data
    volumes:
        -   name: config
            configMap:
                name: http-server-config
                items:
                    -   key: http-server-config
                        path: server.config
```

## 鸟枪换炮，在虚拟化环境部署生产集群

使用 k3s 搭建一个可用于生产环境的真正的多节点 k8s 集群。以下以 k3s v1.30.0 为例，节点运行时为 multipass

### 下载必要资源

```shell
mkdri k3s && cd k3s
curl -LO https://github.com/k3s-io/k3s/releases/download/v1.30.0%2Bs1/k3s
curl -LO https://github.com/k3s-io/k3s/releases/download/v1.30.0%2Bs1/k3s-airgap-images-arm64.tar.gz
curl -LO https://raw.githubusercontent.com/k3s-io/k3s/master/install.sh
```

### 部署一个中心两个节点

根据本地环境修改以下脚本中变量的初始值后，将脚本内容写入文件并命名为 `local-cluster.sh`

```shell
#!/usr/bin/env bash

IMAGE_VER="22.04"
INTERFACE="enp0s1"
MASTER_NAME="master"
NODE_PREFIX="node"

MASTER_IP=""
NODE_TOKEN=""
NODE_IP=""
NODE_IP6=""

function launch_node() {
    node_id=$1
    master_ip=$2
    master_token=$3

    multipass delete "$node_id" || true
    multipass purge
    multipass launch --verbose --name "$node_id" -- "$IMAGE_VER"
    multipass transfer k3s/k3s-arm64 "$node_id":/tmp/k3s
    multipass transfer k3s/install.sh "$node_id":/home/ubuntu
    multipass transfer k3s/k3s-airgap-images-arm64.tar.gz "$node_id":/tmp
    multipass exec "$node_id" -- sudo hostnamectl set-hostname "$node_id"
    multipass exec "$node_id" -- sudo mkdir -p /var/lib/rancher/k3s/agent/images
    multipass exec "$node_id" -- sudo mv /tmp/k3s-airgap-images-arm64.tar.gz /var/lib/rancher/k3s/agent/images
    multipass exec "$node_id" -- sudo mv /tmp/k3s /usr/local/bin/k3s
    multipass exec "$node_id" -- sudo sed -i 's|ports.ubuntu.com|mirrors.ustc.edu.cn|g' /etc/apt/sources.list
    multipass exec "$node_id" -- sudo apt update -y
    multipass exec "$node_id" -- sudo apt install -y containerd socat conntrack ebtables ipset

    NODE_IP=$(multipass exec master -- python3 -c "import netifaces; print(netifaces.ifaddresses('$INTERFACE')[netifaces.AF_INET][0]['addr'])")
    NODE_IP6=$(multipass exec master -- python3 -c "import netifaces; print(netifaces.ifaddresses('$INTERFACE')[netifaces.AF_INET6][0]['addr'])")
    echo -e "launch node $node_id, master: $master_ip, host: $NODE_IP, $NODE_IP6"

    if [[ -z "$master_ip" && -z "$master_token" ]]; then
        multipass exec "$node_id" -- INSTALL_K3S_SKIP_DOWNLOAD=true /home/ubuntu/install.sh

        NODE_TOKEN=$(multipass exec master -- sudo cat /var/lib/rancher/k3s/server/node-token)
        MASTER_IP="$NODE_IP"
    else
        multipass exec "$node_id" -- \
            INSTALL_K3S_SKIP_DOWNLOAD=true \
            K3S_URL="https://$master_ip:6443" \
            K3S_TOKEN="$master_token" /home/ubuntu/install.sh
    fi

    multipass exec "$node_id" -- sudo kubectl version
}

set -ex

which multipass || brew instlal multipass

multipass find --only-images
echo -e "use image $IMAGE_VER"

# 安装 master
launch_node "$MASTER_NAME" "" ""
(set -x && sleep 5)

# 部署多台 slave
for id in {1..2}; do
    launch_node "$NODE_PREFIX-$id" "$MASTER_IP" "$NODE_TOKEN"
done

multipass list
multipass exec "$MASTER_NAME" -- sudo kubectl get node
```

运行 `./local-cluster.sh` 进行自动部署

```shell
...
+ multipass list
Name                    State             IPv4             Image
master                  Running           192.168.65.12    Ubuntu 22.04 LTS
                                          10.42.0.0
                                          10.42.0.1
node-1                  Running           192.168.65.13    Ubuntu 22.04 LTS
                                          10.42.1.0
                                          10.42.1.1
node-2                  Running           192.168.65.14    Ubuntu 22.04 LTS
                                          10.42.2.0
+ multipass exec master -- sudo kubectl get node
NAME     STATUS   ROLES                  AGE     VERSION
master   Ready    control-plane,master   5m2s    v1.30.0+k3s1
node-1   Ready    <none>                 3m10s   v1.30.0+k3s1
node-2   Ready    <none>                 56s     v1.30.0+k3s1
```

---
display-name: 部署 Docker Registry  
date: 2024-06-16 20:04:10  
categories:

- docker

tags:

- docker

---


部署一个私有的 docker registry 实现 docker hub 镜像源加速效果，基本条件是具有一台海外服务器。

## Docker Registry

1. 创建一个目录用于搭建

```shell
mkdir /root/docker-registry
```

2. 在目录中创建一个 docker-compose.yaml

```yaml
version: "3"
services:
    docker-registry:
        image: registry:2
        container_name: registry-server
        restart: always
        ports:
            - "5000:5000"
        volumes:
            - /root/docker-registry/data:/data
        environment:
            - REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io
            - REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data
```

3. 启动

启动完成之后可以使用 host:5000 进行连接

```shell
doker-compose up -d
```

## HTTPS

使用 web 服务器反向代理 5000 端口并实现 https，https 证书以 certbot 为例

```
apt install nginx certbot python-certbot-nginx
```

创建文件 /etc/nginx/conf.d/registry.server.name 并运行 `certbot --nginx` 自动生成 https nginx conf，以下为文件示例

```nginx
server {
    listen 443 ssl http2;
    server_name registry.server.name;

    location / {
		proxy_pass http://localhost:52031;
		proxy_set_header X-Real-IP $remote_addr;
    }

    ssl_certificate /etc/letsencrypt/live/registry.server.name/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/registry.server.name/privkey.pem;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";  
}

server {
    if ($host = registry.server.name) {
        return 301 https://$host$request_uri;
    }
}
```

## 使用

```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
  	"https://registry.server.name"
  ]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

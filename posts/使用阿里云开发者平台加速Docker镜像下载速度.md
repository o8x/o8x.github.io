---
display-name: 使用阿里云开发者平台加速Docker镜像下载速度
date: 2018-02-28 15:59:47
tags: [ "Linux" ]
---

1. 进入 `https://dev.aliyun.com/search.html` 点击创建我的容器镜像并登陆阿里云账号
2. 进入控制台 ,点击左侧TAB中的镜像加速器 .
   ![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/02/60ef66be7765bba405ab146e54236011.png)
3. 按照教程执行操作即可
   ![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/02/c7ec859e6c33ab69d4fb09fc1df88ae6.png)

**教程**

```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://r2txxxx.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

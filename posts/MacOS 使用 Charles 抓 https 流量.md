---
display-name: macos 使用 Charles 抓 https 流量
date: 2024-09-10 14:29:00
tags: ["杂项"]
---



本文不是手机抓包配置教程，只是对macos抓包。手机端可进行参考

## 打开 MacOs Proxy 监听

点击 Charles 的 Proxy 菜单的 macOs Proxy 或 Proxy Setting 中的 macOS 来开启

![image-20200718084432099](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718084434.png)

## 配置 Proxy 端口和类型，使网卡转发流量到 Charles

点击 Charles 的 Proxy 菜单的 Proxy Setting

![image-20200718084348349](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718084350.png)

## 调整 SSL Proxy Setting 监听 443 端口

打开 Proxy 菜单的 SSL Proxy Settings，配置443 端口

![image-20200718084739223](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718084740.png)

点击Add后即弹出下图的菜单

Host 为 监听的域，*为全部监听，端口填写443（默认ssl端口），也可以是其它的自定义ssl端口

![image-20200718084829025](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718084830.png)

## 安装 SSL 根证书

上面做的这一切都依赖于证书的成功安装，否则还是无法解析 SSL 流量。

点击 Charles 的菜单 Help

![image-20200718085551567](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718085553.png)

理论上点击 Install Charles Root Certificate 即可，但是有些时候会直接报错。那么就使用 Save Charles Root Certificate 来保存 pem 证书到本地手动安装。

![image-20200718085828453](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718085829.png)

打开 Keychain 程序，点击左侧的 Login，而后直接将该证书拖到右侧证书列表中即可。此时证书不受信任

![image-20200718090047259](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718090048.png)

手机端抓包则同时在手机上配置 IOS或Mobile 证书，打开转发即可。

## 信任 SSL 根证书

不受信任的证书无法通过maco的安全策略，Charles 还是无法正常抓包。

双击刚才安装的证书，将 Trust 中的 Use System Defaults 改为 Always Trust。然后按一下指纹，即可保存成功

![image-20200718090326946](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718090328.png)

## 重启 Charles

经过测试，QQ音乐的https JSON已经正确的被Charles解析了。其它的当然也一样

![image-20200718092046948](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718092048.png)

**注：** 如果抓取不正常，请检查代理配置是否正确

在 系统偏好设置 -> 网络（对应的网卡） -> 高级设置 -> 代理配置 -> 中查看网络是否正确的配置了代理，这里的 8888 是第二部分配置的端口号。

该配置会随着 Charles 的关闭而被关闭

![image-20200718093015546](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20200718093016.png)

如果配置完还是有一部分应用的流量无法解析正确解析，则说明该应用可能使用了自签证书，无法抓取是正常的。


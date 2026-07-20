---
display-name: 将Plugin 提交到 Jetbrains Market
date: 2020-11-21 11:57:39
tags: ["Intellij SDK"]
---

## 注意事项：

- plugin.xml 中的 id 项必须保持唯一
- plugin.xml 中的 name 不能为中文
- plugin.xml 中的 vendor 中必须是合法的电子邮寄地址和名称
- plugin.xml 中的 description 中不能包含中文

## 编译插件

先使用gradle 中的 buildPlugin，将插件编译成 zip 包。编译产物一般位于 build/distributions/name-version-SNAPSHOT.zip

![image-20201225151214946]({{ env.cdn_accelerate }}/20201225151216.png)

## 提交审核

先到这里注册一个账户，可以直接使用 github 账户登陆。https://plugins.jetbrains.com/

登陆成功点击 Upload plugin 或直接访问：https://plugins.jetbrains.com/plugin/add 即可进入提交页面。

![image-20201225150810188]({{ env.cdn_accelerate }}/20201225150812.png)

![image-20201225151026820]({{ env.cdn_accelerate }}/20201225151028.png)

上传刚才获得的name-version-SNAPSHOT.zip之后，点击蓝色按键即可提交审核，审核过程一般需要3-5天，有任何变动都将会给你的电子邮件发送信息。

审核过程中，插件是无法在IDE和市场中搜索到的。


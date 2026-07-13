---
display-name: PlantUML
date: 2019-05-05 14:24:14
tags: ["杂项"]
---

*序列图*

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2020/05-26-outofstack.png)

> 代码以及说明

```ini
@startuml
' 定义顶部标题，非必须支持 HTML
title
微信小程序支付
end title

' 创建一个画布,盒子，非必须
' skinparam backgroundColor #EEEBDC
skinparam ParticipantPadding 20
skinparam BoxPadding 20

' 使用刚才定义画布，将 end box 之前的内容都装进盒子里, 非必须
' box
' 为信息自动编号，非必须
autonumber
' 定义实体类型，非必须
actor 用户 as User
' 普通参与者，as 定义别名，用法类似常量，非必须
participant 微信小程序 as MiniProgram
' 指定参与者惭色，非必须
participant 商户系统 as Business #red
entity 微信后台 as Wechat

' 调用过程
User -> MiniProgram : 进入小程序，下单()
' 激活生命线
activate User

MiniProgram -> Business : 请求下单支付()
activate MiniProgram
' 为生命线配置颜色
activate Business #red

Business -> Wechat : 调用小程序登录API()
activate Wechat

' 返回写法有两种，等效
' Business <<- Wechat : 返回 OpenId()
Wechat -->> Business : 返回 OpenId()
' 撤销激活生命线
deactivate Wechat

' 自调用
Business -> Business : 生成商户订单()
' 绘制自调用嵌套生命线
' 不关闭嵌套生命线，也可以在嵌套生命线中调用过程，直到生命线关闭
activate Business #red
deactivate Business

Business -> Wechat : 调用统一下单API()
activate Wechat
Wechat -->> Business : 返回预付订单信息(perpay_id)
deactivate Wechat

Business -> Business : 将组合数据再次签名
activate Business #red
deactivate Business

Business -->> MiniProgram : 返回支付参数(5个参数和Sign)
deactivate Business
deactivate MiniProgram

User -> MiniProgram : 用户确认支付()
activate MiniProgram

MiniProgram -> Wechat : 鉴权调起支付()
activate Wechat
Wechat -->> MiniProgram : 返回支付结果()
deactivate Wechat

MiniProgram -> MiniProgram : 展示支付结果()
activate MiniProgram
deactivate MiniProgram
' 上一行只是关闭了嵌套生命线，所以需要再关闭一次原有的生命线
deactivate MiniProgram

Wechat -->> Business : 推送支付结果()
activate Wechat

activate Business #red
Business -> Business : 更新订单状态()
activate Business #red
deactivate Business #red
deactivate Business

deactivate Wechat
' 关闭盒子
' end box
@enduml
```

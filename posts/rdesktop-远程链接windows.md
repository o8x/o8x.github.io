---
display-name: rdesktop 远程链接windows
date: 2018-06-21 15:51:09
tags:

- Linux

---

# 安装

> sudo yum -y install rdesktop

# 使用

> 查看帮助 ： rdesktop --help    
> 直接链接 ： rdesktop -f 192.168.31.121

# 参数配置

> rdesktop -f -a 16 -u username -p password IP -r sound:on/off -g 1024x768   
> rdesktop -f -a 32 -u admin 192.168.31.121 -r sound:on/off -g 1920x1016
> 使用空密码 ，忽略-p参数即可

**-g 参数中的 x 是小写 X 不是 ***

1、username和password分别是目标电脑的帐号和密码，-a 16表示位色，最高就是16位；
2、IP为目标电脑的IP地址（可能需要先连接VPN）；
3、sound：on表示传送目标电脑的声音，off则为关闭；
4、-g 后接想要显示的分辨率，使用 -g workarea 可自适应铺满当前linux窗口大小

**更多参数：**

5、使用 -f 参数进入全屏模式，中途可使用Ctrl+Alt+Enter组合键退出全屏（不知道的就郁闷了）;
6、-r** disk:share_name=/local-disk** 将本地磁盘映射到远程电脑，其中share_name为显示名称，可自定义，local-disk表示本地linux的一个目录，比如 /data。
7、-r clipboard:PRIMARYCLIPBOARD 允许在远程主机和本机之间共享剪切板，就是可以复制粘贴。

> 以上本人只进行了部分修正与补充   
> 原作者：zhwhong 來源：简书    
> 链接：https://www.jianshu.com/p/91fb0b1c6815

---------------------------------

# Windows 配置

> windows 并不是直接就可以被rdesktop链接的 ，需要一些简单的配置

1. **配置允许远程协助**

   ![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/607928d78a773897bbb9ab329e29a76c.png)

1. **编辑组策略配置允许空密码登录 ，不使用空密码可忽略**

    - 打开组策略
      ![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/e074991f7fb7e3643ded0007885456e4.png)

    - 禁用空密码只能进行控制台登录
      ![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/06/c95416457271e29e61e24a8e00925232.png)

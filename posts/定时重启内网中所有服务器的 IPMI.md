---
display-name: 定时重启内网中所有服务器的 IPMI
date: 2019-03-18 17:24:01
tags: [ "Linux" ]
---

## 代码

```bash
#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# 重启ipmi
reboot_ipmi () {
    logger "$1 $2 $3"
    ipmitool -I lanplus -H $1 -U $2 -P $3 mc reset cold || /usr/bin/logger "$1 $2 $3 重启失败"
}

# 解析参数
parse_list()
{
    # 读取文件 , 删除所有空行 , 接入 while 管道逐行读取数据
    cat $1 | grep -v "^$" | while read LINE
    do
        # 解析参数
        ip=`echo ${LINE} | awk '{print $1}'`
        user=`echo ${LINE} | awk '{print $2}'`
        pass=`echo ${LINE} | awk '{print $3}'`

        # 重启IPMI
        reboot_ipmi ${ip} ${user} ${pass} &
        sleep 2
    done
}


inifile="/etc/list.ini"
if [[ $1 ]]
then
    if [[ -f $1 ]]
    then
        ${inifile}=${1}
        else
        echo "参数1必须是一个包含IP列表的文件 . "
        exit
    fi
fi

# 解析IP列表
parse_list ${inifile}
```

## IP 列表文件格式

> IP地址 用户名 密码

```ini
192.168.10.206    root    root
192.168.10.207    root    root
192.168.10.208    root    root
192.168.10.209    root    root
```

## 使用方法

```bash
# 指定 IP 列表文件路径参数
./reboot-ipmi.sh /etc/list.ini

# 使用默认的IP列表文件路径参数
./reboot-ipmi.sh
```

## 定时执行

```bash
# 添加定时任务
echo "0 30 1 * * ? /bin/reboot-ipmi.sh /etc/list.ini" >> /var/spool/cron/root
# 重启定时任务组件
service crond restart
```

## 查看执行日志

```bash
journalctl | grep ipmi
```

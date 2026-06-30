---
display-name: MacOS DNS配置  
date: 2023-05-22 14:24:39
---

查看打开的所有网卡

```shell
networksetup -listallnetworkservices
```

清空网卡的DNS

```shell
networksetup -setdnsservers Wi-Fi empty
```

查看网卡的DNS

```shell
networksetup -getdnsservers Wi-Fi
```

清空DNS缓存

```shell
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

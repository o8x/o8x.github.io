---
display-name: python 服务器监控脚本，兼容 windows 和 linux
date: 2018-12-05 17:42:04
tags:

- Python

---

# 依赖

> pip 包 psutil requests

# 脚本

```python 
# -*- coding: utf-8 -*-

import psutil
import json
import socket
import datetime
import time
import requests
import os

'''
向服务器推送数据，支持socket和http

本脚本应该位于 /opt/pusher.py
'''
class pusher(object):
    def __init__(self, ip, port):
        self.ip = ip
        self.port = port

    def pushed(self):
        '''
            推送数据到中心服务器
        '''
        try:
            return self.pushWithHttp(self.ip, self.port).text
        except:
            return self.pushWithSocket(self.ip, self.port)

    def pushWithHttp(self, ip, port):
        '''
            使用 HTTP 协议发送
        '''
        return requests.post("http://%s/User/LeaseAgent/push" % ip, {
            'state': self.postData,
            'sn': self.getSn()
        })

    def pushWithSocket(self, ip, port):
        '''
            使用 RPC
        '''
        conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        conn.connect((ip, port))
        conn.send(data)
        return conn.close()

    def setData(self, data):
        '''
            设置数据
        '''
        self.postData = data
        return self

    def getData(self):
        '''
            整理数据
        '''
        return self.encodeData({
            'useInfo': self.getUseInfo(),
            'countInfo': self.getCountInfo(),
            'systemInfo': self.getSystemInfo()
        })

    def encodeData(self, data):
        '''
        转义数据
        '''
        return json.dumps(data)

    def getSystemInfo(self):
        '''
            获取系统信息
        '''
        return {
            'bootTime': datetime.datetime.fromtimestamp(psutil.boot_time()).strftime("%Y-%m-%d %H:%M:%S"),
            'sumBootTime': round((time.time() - psutil.boot_time()) / 86400, 1)
        }

    def getCountInfo(self):
        '''
            获取数量信息
        '''
        return {
            'cpuCount': str(psutil.cpu_count(logical=False)) + ' / ' + str(psutil.cpu_count()),
            'pidCound': len(psutil.pids())
        }

    def getUseInfo(self):
        '''
        获取CPU使用数据
        '''
        total_cpu = psutil.cpu_times().user+psutil.cpu_times().idle
        user_cpu = psutil.cpu_times().user
        mem = psutil.virtual_memory()
        return {
            'cpu': round(user_cpu / total_cpu * 100, 2),
            'memory': round(mem.used / float(mem.total) * 100, 2),
            'disk': round(psutil.disk_usage('/').used / float(psutil.disk_usage('/').total) * 100, 2),
        }

    def getSn(self):
        '''
            获取主板SN
        '''
        try:
            if (os.name == 'nt'):
                sn = os.popen('wmic bios get serialnumber')
                return sn.read().split('\n\n')[1].rstrip().replace('\n', '')
            
            output = os.popen('/usr/sbin/dmidecode | grep \'Serial Number\' | head -n 1')
            return output.read().split(': ')[1].rstrip().replace('\n', '')
        except:
            return ''

'''
    运行
'''
pusher = pusher('domain', 8083)
pusher.setData(pusher.getData().encode(encoding='utf-8'))
print (pusher.pushed())
```

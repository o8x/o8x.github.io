---
display-name: elasticsearch 公网集群
date: 2018-09-19 11:51:36
tags:  
- Linux
- elasticsearch
---

> 参数不多，只有4个

注：6版本已经无需使用如下参数了

```yaml
node.master
node.data 
```

# 参数配置

当前集群名称，各个节点该参数需要保持一致

```yaml
cluster.name: es-cluster
```

当前节点在集群中的名字，尽可能不要重复

```yaml
node.name: node-1
```

集群的其他节点IP，9200 9300 端口需要可以从外部访问，否则无法发现该集群节点      
且，本机IP不能包含在数组里

```yaml
discovery.zen.ping.unicast.hosts: [ "1.2.34.43:9300" ]
```

整个集群中，可以成为master的节点数量，
> 如果集群中总共只有两个节点，那么也就只有一台有机会成为master，也就是说如果其中一台挂了，另一台就会自动成为master。      
> 如果节点数量大于3，就有2台甚至更多的节点有机会成为master

```yaml
discovery.zen.minimum_master_nodes: 1
```

# 效果图

![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/09/4837bf05dace79e4fcfae02fb50d1465.png)
![](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/2018/09/40de87cda6468398075cfc123b65117e.png)

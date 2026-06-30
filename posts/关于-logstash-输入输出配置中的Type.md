---
display-name: 关于 logstash 输入输出配置中的Type
date: 2018-09-21 09:16:51
tags:

- elk

---
假设我们的数据是json格式，并且可以利用其中的 project 字段区分数据来源，那我们可以这样配置输出

```nginx
output{
    if [project] == "readius" {
        elasticsearch {
            hosts=>"12.4.5.71:9200"
            index=>"logstash-radius-%{+YYYY.MM.dd}"
        }
    } else if [project] == "redis" {
        elasticsearch {
            hosts=>"12.4.5.71:9200"
            index=>"logstash-redis-%{+YYYY.MM.dd}"
        }
    }
    
    // 
}
```

假设我们的数据是json格式，但是没有任何字段可以标志数据来源，那我们我可以在输入上下手 , 用多个输入并加以type来辅助标志数据来源 ，但是要注意此时json中不能有type字段，否则会和定义的type冲突

```nginx
input {
    kafka {
        bootstrap_servers => "3.6.28.66:9092"
        group_id => "logstash-group"
        topics => "logstash_topic"
        auto_offset_reset =>"earliest"
        codec => json
        type => redis
    }
    
    kafka {
        bootstrap_servers => "3.6.28.66:9091"
        group_id => "logstash-group"
        topics => "logstash_topic"
        auto_offset_reset =>"earliest"
        codec => json
        type => redius
    }
}

output{
    if [type] == "readius" {
        elasticsearch {
            hosts=>"12.4.5.71:9200"
            index=>"logstash-radius-%{+YYYY.MM.dd}"
        }
    } else if [type] == "redis" {
        elasticsearch {
            hosts=>"12.4.5.71:9200"
            index=>"logstash-redis-%{+YYYY.MM.dd}"
        }
    }
    
    // 
}
```

如果我们的数据不是json，就和上面一样加入type字段来辅助，且无需关心数据中是否有type导致冲突的问题。除此之外，还可以通过filter把数据格式化为json，然后利用第一种方法区分数据来源，这里不做主要讨论

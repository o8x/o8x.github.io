---
display-name: 使用 sysbench 进行 mysql 基准测试
date: 2019-05-17 10:22:35
tags:

- Linux

---

### ubunut

```shell 
$ sysbench ./oltp_insert.lua \ 
    --db-driver=mysql \ 
    --mysql-host=127.0.0.1 \ 
    --mysql-port=3306 \ 
    --mysql-user=root \ 
    --mysql-db=db \ 
    --threads=10 \ 
    --table-size=20000000 \ 
    --time=120 \ 
    --report-interval=10 prepare
```

### centos

```shell
$ sysbench \ 
    --mysql-host=127.0.0.1 \ 
    --db-driver=mysql \ 
    --mysql-db=db \ 
    --mysql-port=3306 \ 
    --mysql-user=root \ 
    --mysql-password=memsql.t3st \ 
    --oltp-test-mode=complex \ 
    --oltp-table-size=20000000 \ 
    --test=oltp prepare
```

---
display-name: 解决mysql 5.7+ 1055 异常
date: 2018-10-22 17:05:32
tags: [ "mysql" ]
---

### 暂时解决

> 执行SQL，重启失效

```sql
set
@@global.sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
```

### 永久解决

> 修改 `/etc/mysql/conf.d/mysql.cnf`，并加入以下内容

```ini
[mysqld]
sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
```


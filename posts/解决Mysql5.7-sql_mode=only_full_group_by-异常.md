---
display-name: 解决Mysql5.7 sql_mode=only_full_group_by 异常
date: 2018-09-03 09:17:43
tags: [ "mysql" ]
---

ONLY_FULL_GROUP_BY 的意思是：对于GROUP BY聚合操作，如果在SELECT中的列，没有在GROUP BY中出现，那么这个SQL是不合法的，因为列不在GROUP BY从句中，也就是说查出来的列必须在group
by后面出现否则就会报错，或者这个字段出现在聚合函数里面。

解决方法

```sql
SELECT @@GLOBAL.sql_mode;
set
@@GLOBAL.sql_mode='';
set
sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
```

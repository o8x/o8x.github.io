---
display-name: SQL 替换某列中的某些字符串为另一个字符串
date: 2018-06-01 16:03:09
tags:

- mysql

---

**只需要REPLACE函数就可以了**

    update wp_posts set colName = REPLACE(colName ,'旧的字符串' ,'新的字符串')

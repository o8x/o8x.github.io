---
display-name: 利用存储过程循环清空mysql大表
date: 2018-09-07 13:57:05
tags:  
- mysql
---

```sql
-- 定界
delimiter
$$
-- 删除存在的过程 eachtable
drop procedure if exists eachtable $$
-- 创建新的过程 eachtable
create procedure eachtable()
-- 开始执行
begin
    -- 创建一个int类型变量 ，取名为sum，默认为0
        declare
sum int default 0;
        
        -- 用表的总行数赋值给变量sum
select count(*)
into sum
from radius.radpostauth;

-- 循环
while
(sum >= 0) do
            -- 倒着删除3000个
delete
from radius.radpostauth order by id desc limit 3000;

-- 给总数减去3000
set
sum = sum - 3000;
            -- 提交
commit;
end while;
end
$$
delimiter ;

-- 展示状态
show
procedure status;
-- 调用方法
call eachtable()
```

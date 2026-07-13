---
display-name: Linux 内核读写锁
date: 2022-06-18 10:51:19
tags: ["Linux"]
---

### 初始化锁

使用宏初始化锁，文件中将会自动定义 rw_lock 变量

```c
DEFINE_RWLOCK(rw_lock);
```

### 读锁

加锁

```c
read_lock_bh(&rw_lock);
```

解锁

```c
read_unlock_bh(&rw_lock);
```

### 写锁

```c

write_lock_bh(&rw_lock);
```

解锁

```c
write_unlock_bh(&rw_lock);
```

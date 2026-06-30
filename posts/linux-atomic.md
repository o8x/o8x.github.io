---
display-name: Linux 内核中的原子操作
date: 2022-06-18 10:21:53
categories:
- Linux
tags:

- Linux 内核

---

该 API 的用法与 golang atomic 包类似

## 定义原子变量

变量类型 `atomic_t`

```c
static atomic_t atomic_var = ATOMIC_INIT(0);
```

## 常用API

### 设置

```c
atomic_set(&atomic_var, 1);
```

### 读取

```c
int val = atomic_read(&atomic_var);
```

### 加

```c
atomic_add(1, &atomic_var);
```

返回设置后的新值

```c
atomic_add_return(1, &atomic_var);
```

返回一个bool值，含义为新值是否为0

```c
int new_value_is_zero = atomic_dec_and_test(&atomic_var);
```

返回一个bool值，含义为新值是否为负数

```c
int new_value_is_negative = atomic_add_negative(1, &atomic_var);
```

### 减

```c
atomic_sub(1, &atomic_var);
```

```c
atomic_sub_return(1, &atomic_var);
```

```c
bool new_value_is_zero = atomic_sub_and_test(&atomic_var);
```

### 自增

```c
atomic_inc(&atomic_var);
```

```c
int new_value = atomic_inc_return(&atomic_var);
```

```c
bool new_value_is_zero = atomic_inc_and_test(&atomic_var);
```

### 自减

```c
atomic_dec(&atomic_var);
```

```c
int new_value = atomic_dec_return(&atomic_var);
```

```c
bool new_value_is_zero = atomic_dec_and_test(&atomic_var);
```

### 其他API

https://www.kernel.org/doc/html/v4.12/core-api/atomic_ops.html

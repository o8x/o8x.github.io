---
display-name: Laravel 之模型软删除
date: 2017-10-21 14:01:13
tags: ["php"]
---

> 如果 laravel 模型配置了软删除，那么数据并不会真的被删除，而是更新 deleted_at 字段为当前时间戳。且查询时也会规避具有 deleted_at 的数据

### 模型

> 声明标志数据被删除的时间戳字段

```php
protected $dates = ['deleted_at']
```

此时 `$user->delete();`时deleted_at字段就会被更新为当前时间戳了.

#### 强制查询被删除的数据

```php
$users = User::withTrashed()->where('account_id', 1)->get();
```

### 数据迁移

```php
$table->softDeletes();
```

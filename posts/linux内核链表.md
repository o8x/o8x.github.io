---
display-name: Linux 内核链表"
date: 2022-06-18 11:04:50
categories:
- Linux 内核
tags:

- Linux 内核

---

linux 内核中提供了一种精妙无比的链表API，本文介绍其常用的用法

### 定义

`LIST_HEAD_INIT` 宏将会自动定义 test_head 变量

```c
struct list_head test_head = LIST_HEAD_INIT(test_head);
```

定义节点

```c
typedef struct {
    struct list_head head;
    char name[32];
    unsigned int name_len;
} node;
```

### 判断链表是否为空

```c
list_empty(&test_head)
```

### 增加元素

精妙之处就在于链表与数据类型无关，正常的链表是基于数据结构成为链表，而linux内核提供的链表恰好相反，是将数据结构挂在链表上

注： 增加元素前最好加读锁，否则可能有线程安全问题

```c
node *n = NULL;

n = kzalloc(sizeof(node), GFP_KERNEL);
list_add(&(n->head), &test_head);
```

### 遍历链表

`list_for_each_entry_safe` 宏展开后是 for 循环，所以这个结构中可以使用 continue，并且会在遍历结束后自动将头指针放回。

注： 遍历前最好加读锁，否则可能有线程安全问题

```c
struct *node, *n = NULL;
list_for_each_entry_safe(node, n, &test_head, head) {
     printk("%s %d", node->name, node->name_len);
}
```


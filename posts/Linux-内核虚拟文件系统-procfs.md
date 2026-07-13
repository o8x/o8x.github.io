---
display-name: Linux 内核虚拟文件系统 procfs
date: 2022-06-18 09:54:23
tags: ["Linux"]
---

### 选项

该模块在 linux kernel 5.6 时曾进行[变更](https://lore.kernel.org/netdev/20191225172546.GB13378@avx2/)，所以需要使用编译指令进行处理

```c
#if LINUX_VERSION_CODE >= KERNEL_VERSION(5, 6, 0)
static const struct proc_ops state_proc_ops = {
    .proc_read = proc_read_hook,
    .proc_write = proc_write_hook,
};
#else
static struct file_operations state_proc_ops =
{
    .owner = THIS_MODULE,
    .read = proc_read_hook,
    .write = proc_write_hook,
};
#endif
```

### 注册

内核模块启动后，将会生成文件 `/proc/net_state`

```c
static struct proc_dir_entry *state;
state = proc_create("net_state", 0660, NULL, &state_proc_ops);
```

同时在内核模块退出时，也需要取消注册

```c
proc_remove(state);
```

### 读

内核态通过 `copy_to_user` 和用户态交互

读取 `/proc/net_state` 将会打印出 debug = 1

```c
static ssize_t proc_read_hook(struct file *file, char __user *ubuf, size_t count, loff_t *ppos) {
    char buf[100];
    int len = 0;

    if(*ppos > 0 || count < 100){
        return 0;
    }

    len += sprintf(buf, "debug = %d\n", 1);
    if(copy_to_user(ubuf, buf, len)) {
        return -EFAULT;
    }

    *ppos = len;
	return len;
}
```

### 写

使用 `copy_from_user` 从用户态拷贝内容

返回值 EFAULT 与 -EFAULT 为成功和失败，向 `/proc/net_state` 写的内容将会被存储到 ubuf 变量中，count 则是该内容的长度

```c
static ssize_t proc_write_hook(struct file *file, const char __user *ubuf, size_t count, loff_t *ppos) {
	int number;
	char buf[1024];
	
	if (*ppos > 0 || count > BUFSIZE) {
	    return -EFAULT;
    }
		
	if (copy_from_user(buf,ubuf,count)) {
	    return -EFAULT
	}
	
	num = sscanf(buf, "%d", &number);
	printk(num);
	
    return EFAULT;
}
```


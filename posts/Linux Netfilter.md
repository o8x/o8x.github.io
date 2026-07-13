---
display-name: Linux Netfilter
date: 2022-06-18 13:39:18
tags: ["Linux"]
---

### 参数配置

```c
#include <linux/netfilter.h>
#include <linux/skbuff.h>

static struct nf_hook_ops hook_ops[] __read_mostly = {
    {
        .hook = hook,
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 13, 0)
        .pf = NFPROTO_INET,
#else
        .pf = PF_INET,
        .owner = THIS_MODULE,
#endif
        .hooknum = NF_INET_PRE_ROUTING,
        .priority = NF_IP_PRI_FIRST,
    }
};
```

### 注册

```c
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 13, 0)
    nf_register_net_hooks(&init_net, hook_ops, ARRAY_SIZE(hook_ops));
#else
    nf_register_hooks(hook_ops, ARRAY_SIZE(hook_ops));
#endif 
```

### 接受数据

```c
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 13, 0)
static u_int32_t hook(void *priv, struct sk_buff *sock_buff, const struct nf_hook_state *state) {
#else
unsigned int hook(const struct nf_hook_ops * hook, struct sk_buff * sock_buff, const struct net_device * in, const struct net_device * out, const struct nf_hook_state * state){
#endif

    int source_port;
    int dest_port;
    char source[32];
    char dest[32];
    unsigned char *data;
    int len;
    
    if (sock_buff == NULL) {
        return NF_ACCEPT;
    }
    
    ip_header = ip_hdr(sock_buff);
    if (!ip_header) {
        return NF_ACCEPT;
    }

    // 解析三层协议
    sprintf(source, "%pI4", &ip_header->saddr);
    sprintf(dest, "%pI4", &ip_header->daddr);
    
    // 解析四层协议
    switch (ip_header->protocol) {
        case IPPROTO_TCP:
            tcp_header = (struct tcphdr *) (ip_header + 1);
            dest_port = htons(tcp_header->dest);
            source_port = htons(tcp_header->source);
            data = sock_buff->data + ip_header->ihl * 4 + tcp_header->doff * 4;
            len = ntohs(ip_header->tot_len) - ip_header->ihl * 4 - tcp_header->doff * 4;
            break;
        case IPPROTO_UDP:
            udp_header = (struct udphdr *) (ip_header + 1);
            dest_port = htons(udp_header->dest);
            source_port = htons(udp_header->source);
            data = sock_buff->data + ip_header->ihl * 4 + 8;
            len = ntohs(ip_header->tot_len) - ip_header->ihl * 4 - 8;
            break;
        default:
            reutrn NF_ACCEPT;
    }
    
    printk("%s:%d -> %s:%d", source, source_port, dest, dest_port);
    print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 16, 1, data, len, true);
}
```

### 注销

```c
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 13, 0)
    nf_unregister_net_hooks(&init_net, hook_ops, ARRAY_SIZE(hook_ops));
#else
    nf_unregister_hooks(hook_ops, ARRAY_SIZE(hook_ops));
#endif
```

未完待续....

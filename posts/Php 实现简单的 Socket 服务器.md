---
display-name: php实现简单的socket服务器
date: 2018-12-06 15:12:39
tags: ["php"]
---

### server

```php
$sock = socket_create(AF_INET , SOCK_STREAM , SOL_TCP);
socket_bind($sock , '0.0.0.0' , 8083);
socket_listen($sock , 4);

while (true) {
    $client = socket_accept($sock);

    $data = '';
    while ($buf = @socket_read($client , 8192)) {
        $data .= $buf;
    }

    socket_write($client ,'ok' ,2);
    socket_close($client);
}

socket_close($sock);
```

### client

```php
$socket = socket_create(AF_INET , SOCK_STREAM , SOL_TCP);
socket_connect($socket , 'ip' , 23);

$data = '';
while ($socket_read = socket_read($socket , 8192 , PHP_NORMAL_READ)) {
    $socket_read .= $data;
}

var_dump($data);

socket_close($socket);
```

---
display-name: Php程序性能分析工具 Xhprof
date: 2017-08-13 14:48:31
tags: ["php"]
---

### Web Server

> xhprof 有内建 web server , 可以以图形化的方式把性能信息更为直观的呈现在浏览器上 . 安装 graphviz 即可支持该服务 .

### 配置

```php
<?php
  
xhprof_enable();
define('APP_DEBUG' , True);
define('APP_PATH' , './');
define('VENDOR_PATH', dirname(__FILE__). '/../vendor');
define('RUNTIME_PATH' , './Runtime/apps/');

require'./../Core/ThinkPHP.php';

$xhprofData=xhprof_disable();
require'/opt/web/vendor/xhprof/xhprof_lib/utils/xhprof_lib.php';
require'/opt/web/vendor/xhprof/xhprof_lib/utils/xhprof_runs.php';

$xhprofRuns=newXHProfRuns_Default();
$runId     =$xhprofRuns->save_run($xhprofData ,'xhprof_test');
```


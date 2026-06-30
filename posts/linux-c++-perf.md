---
short-path: linux-cxx-perf
display-name: Linux 下使用 Perf 分析 C++ 程序性能
date: 2025-03-27 12:16:00
visibility: open
---

## 安装

```shell
apt install -y linux-tools-common linux-tools-generic
```

## 采样

```shell
perf record -g -a -F 1000 -- sleep 10
```

## 分析

```shell
perf report
```

生成图

```shell
#!/bin/bash
 
set -ex 

cd /opt

function perf_command() {
	[[ -f /usr/bin/perf ]] || apt install -y linux-tools-common linux-tools-generic graphviz 
	[[ -d FlameGraph ]] || git clone --depth 1 https://github.com/brendangregg/FlameGraph.git
	
	perf record -g -a -F 1000 -- $1
	perf script -i perf.data | c++filt | perl FlameGraph/stackcollapse-perf.pl > out.folded
	perl FlameGraph/flamegraph.pl out.folded > out.svg
	rm out.folded
	
	perf report
}

perf_command "";
```

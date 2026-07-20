---
display-name: vcpkg
date: 2024-08-12 12:34:34
permalinkPattern: :year/:month/:day/:slug.html
tags: ["C++"]
---

来自 Microsoft 的 C/C++ 依赖管理器，适用于所有平台、构建系统和工作流程 [https://vcpkg.io](https://vcpkg.iol)。

**本文将使用 cmake 作为构建工具**

## 安装

clone vcpkg 仓库

```shell
git clone --progress https://github.com/microsoft/vcpkg ~/.example-vcpkg
```

将 vcpkg 命令加入系统环境变量

```shell
export PATH="$PATH:$HOME/.example-vcpkg"
```

安装（需要联网）

```shell
cd ~/.example-vcpkg
./bootstrap-vcpkg.sh
```

正确的输出如下

```shell
Downloading vcpkg-macos...
vcpkg package management program version 2024-08-01-fd884a0d390d12783076341bd43d77c3a6a15658

See LICENSE.txt for license information.
Telemetry
---------
vcpkg collects usage data in order to help us improve your experience.
The data collected by Microsoft is anonymous.
You can opt-out of telemetry by re-running the bootstrap-vcpkg script with -disableMetrics,
passing --disable-metrics to vcpkg on the command line,
or by setting the VCPKG_DISABLE_METRICS environment variable.

Read more about vcpkg telemetry at docs/about/privacy.md
```

## 使用

vcpkg 提供两种服务模式

- 经典模式和 pkg-config 区别不大，全局共享同一份依赖库且不支持锁定版本
- 清单模式类似 npm，将依赖包声明到一个 json 文件中，支持锁定版本

两种模式都以 fmt 包为例演示。

### 搜索软件包

```shell
vcpkg search fmt
```

输出如下

```shell
vcpkg search fmt            
fmt                      11.0.2           {fmt} is an open-source formatting library providing a fast and safe alter...
...
```

## 经典模式

### 安装依赖包

`vcpkg install fmt[:[arch]-[os]]` 架构以及系统参数可省略

```shell
vcpkg install fmt:arm64-osx
```

输出如下

```shell
Computing installation plan...
...
Installing 3/3 fmt:arm64-osx@11.0.2...
Elapsed time to handle fmt:arm64-osx: 4.99 ms
fmt:arm64-osx package ABI: 1de75c5883a2f083f271769aeeaf0c877b2d95ab703f88676c9b1c890e254b9a
Total install time: 7.89 ms
The package fmt provides CMake targets:

    find_package(fmt CONFIG REQUIRED)
    target_link_libraries(main PRIVATE fmt::fmt)
...
```

### 在 cmake 中导入依赖包

按照输出中的示例将依赖导入 cmake target

```shell
find_package(fmt CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)
```

### 调用依赖包

```shell
#include <fmt/core.h>

int main() {
    fmt::print("Hello World!\n");

    return 0;
}
```

### 编译

编译时需要先指定工具链为 vcpkg，后续编译时就会自动包含第三方包。例如 <fmt/core.h> 实际上位于
`~/.example-vcpkg/installed/arm64-osx/include/fmt/core.h`，所有导入该包的软件都共用这一份。

```shell
cmake -DCMAKE_TOOLCHAIN_FILE=~/.example-vcpkg/scripts/buildsystems/vcpkg.cmake -B build -S .
cmake --build build --target all -j `nproc`
```

### 运行

```shell
 ./build/vcpkg 
Hello World!
```

## 清单模式

清单模式通过 vcpkg.json 实现

### 初始化清单模式

```shell
vcpkg new --application
```

或手动创建 json 文件，基线可以通过 `cd ~/.example-vcpkg && git rev-parse HEAD` 命令查看。

```json
{
    "name":             "vcpkg",
    "version-string":   "1.0.0",
    "builtin-baseline": "e590c2b30c08caf1dd8d612ec602a003f9784b7d",
    "dependencies":     []
}
```

### 安装依赖包

清单模式只能手动增加依赖并进行 `vcpkg install`，vcpkg.json 全文如下

```json
{
    "name":             "vcpkg",
    "version-string":   "1.0.0",
    "builtin-baseline": "e590c2b30c08caf1dd8d612ec602a003f9784b7d",
    "dependencies":     [
        {
            "name":      "fmt",
            "version>=": "11.0.2"
        }
    ]
}
```

### 不使用 cmake 获取 vcpkg 依赖

不使用 cmake 工具链，vcpkg 包将会被导入到 `./vcpkg_installed` 目录中

```shell
vcpkg install
```

### cmake 获取 vcpkg 依赖

vcpkg 包将会被导入到 `./build/vcpkg_installed` 目录中

```shell
cmake -DCMAKE_TOOLCHAIN_FILE=~/.example-vcpkg/scripts/buildsystems/vcpkg.cmake -B build -S .
```

会先执行 `vcpkg install`（如果没有则先删除 build 目录再重新执行），输出如下。

```shell
-- Running vcpkg install
...
The package fmt provides CMake targets:

find_package(fmt CONFIG REQUIRED)
target_link_libraries(main PRIVATE fmt::fmt)
...
```

### 导入、调用依赖包

与经典模式一致，不再演示

### 编译

一样编译时需要先指定工具链为 vcpkg，但第三方包位置略有不同，例如 <fmt/core.h> 实际上位于
`./build/vcpkg_installed/arm64-osx/include/fmt/core.h`，这就是为什么清单模式能够管理依赖的版本。

### 运行

与经典模式一致，不再演示

## 原理

所有的包都在最初 git clone 的目录中，`vcpkg search` 也只是在本地仓库的 ports 目录中搜索。 例如
`~/.example-vcpkg/ports/fmt/usage` 就是 fmt 包的帮助文件。

因此在原理上，你可以在同一个系统维护多份不同的 vcpkg 版本的仓库

```shell
The package fmt provides CMake targets:

    find_package(fmt CONFIG REQUIRED)
    target_link_libraries(main PRIVATE fmt::fmt)

    # Or use the header-only version
    find_package(fmt CONFIG REQUIRED)
    target_link_libraries(main PRIVATE fmt::fmt-header-only)
```

### 依赖包文件

- 经典模式下依赖包会被下载到仓库中 `/repo/installed` 被整个系统共用。
- 清单模式下依赖包会被下载到项目根目录的 `/project/vcpkg_installed` 目录下，或 cmake 构建目录
  `/project/build/vcpkg_installed`

无论通过哪种方式拉取依赖包到本地，vcpkg 都会进行现场编译并生成链接库

### 更新软件包

获取新增包、更新包版本、包简介等

```shell
git pull
```

更新 Vcpkg 仓库

```shell
vcpkg upgrade --no-dry-run
vcpkg list --x-json --vcpkg-root=~/.example-vcpkg
vcpkg update
```

## 综合案例

通过 libpcap 和 drogon 进行综合案例演示。并将涉及到前文未提及但生产中常用的 pkg-config 和 Ninja 技术。

主体功能如下

1. 使用 drogon 启动 web server 并阻塞在主线程
2. 子线程通过 libpcap 进行抓包和统计包数量
3. 在 drogon 注册一个路由，打印抓包的统计信息（包含实际抓取包数、libpcap 接收包数，丢弃包数 等指标）

### vcpkg.json

安装 drogon 和 libpcap 两个包

```json
{
    "name":             "vcpkg",
    "version-string":   "1.0.0",
    "builtin-baseline": "e590c2b30c08caf1dd8d612ec602a003f9784b7d",
    "dependencies":     [
        {
            "name":      "libpcap",
            "version>=": "1.10.4#1"
        }, {
            "name":      "drogon",
            "version>=": "1.9.6"
        }
    ]
}
```

### CMakeLists.txt

libpcap 是通过 pkg-config 管理的，所以要通过 cmake 的 pkg-config 插件来管理 link 和 include

```cmake
cmake_minimum_required(VERSION 3.29)
project(vcpkg)

set(CMAKE_CXX_STANDARD 20)
set(ENV{PKG_CONFIG_PATH} "${CMAKE_CACHEFILE_DIR}/installed/arm64-osx/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")

add_executable(${PROJECT_NAME} main.cpp)

find_package(Drogon CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE Drogon::Drogon)

find_package(PkgConfig REQUIRED)
pkg_search_module(PKG_LIBPCAP REQUIRED libpcap)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PKG_LIBPCAP_LIBRARIES})
target_link_directories(${PROJECT_NAME} PRIVATE ${PKG_LIBPCAP_LIBRARY_DIRS})
target_include_directories(${PROJECT_NAME} PRIVATE ${PKG_LIBPCAP_INCLUDE_DIRS})
```

main.cpp

```cpp
#include <iostream>
#include <thread>
#include <pcap/pcap.h>
#include <drogon/drogon.h>

using namespace drogon;

int pkt_num = 0;
char errbuf[PCAP_ERRBUF_SIZE];
pcap_t* pc = pcap_open_live("en0", 65535, 1, 0, errbuf);

void capture() {
    std::cout << "snapshot: " << pcap_snapshot(pc) << std::endl;

    if (pcap_setnonblock(pc, 1, errbuf) != 0) {
        exit(1);
    }

    std::cout << "run on nonblock mode" << std::endl;
    while (true) {
        pcap_pkthdr* pkt_header;
        const u_char* pkt_data;

        if (pcap_next_ex(pc, &pkt_header, &pkt_data) != 1) {
            continue;
        }

        pkt_num++;
    }
}

void capture_stats_handler(const HttpRequestPtr& req, std::function<void (const HttpResponsePtr&)>&& callback) {
    pcap_stat stats;
    pcap_stats(pc, &stats);

    Json::Value json;
    json["result"] = "ok";
    json["captured"] = pkt_num;
    json["received by filter"] = stats.ps_recv;
    json["dropped by interface"] = stats.ps_ifdrop;
    json["dropped by kernel"] = stats.ps_drop;

    callback(HttpResponse::newHttpJsonResponse(json));
}

int main() {
    std::thread c(capture);

    app()
        .setLogLevel(trantor::Logger::kWarn)
        .addListener("localhost", 3000)
        .registerHandler("/", &capture_stats_handler, {Get, "LoginFilter"})
        .run();

    return 0;
} 
```

### 通过 Ninja 编译运行

使用 Ninja 进行 Release 模式构建

```shell
cmake -G Ninja -S . -B build \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_MAKE_PROGRAM=`which ninja` \
	-DCMAKE_TOOLCHAIN_FILE=~/.example-vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build build --target all -j `nproc`
```

运行并请求 `http://localhost:3000`

```shell
./build/vcpkg
snapshot: 65535
run on nonblock mode
```

输出符合预期，且多次刷新值会更新

```json
{
    "captured":             1040,
    "dropped by interface": 0,
    "dropped by kernel":    0,
    "received by filter":   1040,
    "result":               "ok"
}
```

## 将包加入 vcpkg

参考微软的官方教程：[打包 GitHub 存储库示例：libogg](https://learn.microsoft.com/zh-cn/vcpkg/examples/packaging-github-repos)

## 与 clion 集成

参考 Clion 官方文档：[Vcpkg integration](https://www.jetbrains.com/help/clion/package-management.html#install-packages)

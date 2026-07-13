---
display-name: C++ 与 lua 联合编程
date: 2024-09-02 10:20:38
tags: ["C++"]
---

## 环境部署

有两种方案

### 全局安装 lua 解释器

```shell
brew install lua
```

使用 pkg-config 在 cmake 中载入 lua

```cmake
find_package(PkgConfig REQUIRED)
pkg_check_modules(LUA REQUIRED lua)
target_link_libraries(main PRIVATE ${LUA_LIBRARIES})
target_link_directories(main PRIVATE ${LUA_LIBRARY_DIRS})
target_include_directories(main PRIVATE ${LUA_INCLUDE_DIRS})
```

### vcpkg

```json
{
    "name":             "cxx-lua",
    "version-string":   "1.0.0",
    "builtin-baseline": "e590c2b30c08caf1dd8d612ec602a003f9784b7d",
    "dependencies":     [
        {
            "name":      "lua",
            "version>=": "5.4.6"
        }
    ]
}
```

在 cmake 中载入 lua

```cmake
find_package(Lua REQUIRED)
target_include_directories(main PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(main PRIVATE ${LUA_LIBRARIES})
```

vcpkg 也支持全局模式，与 brew 用法区别不大不再赘述

## Hello World

为了避免函数名冲突，要使用 extern "C" 包裹lua头文件，声明这些是C的函数。
**lua 是脚本语言，修改 lua 文件之后无需重新编译 C++，重新执行程序即可**

main.lua

```lua
print "Hello World"
```

main.cpp

```cpp
#include <iostream>

// 避免函数签名冲突
extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

int main() {
    lua_State* L = luaL_newstate(); // 5.0 之后使用 luaL_newstate 替代 lua_open
    if (!L) {
        std::cerr << "Cannot create state: Not enough memory" << std::endl;
        return 1;
    }

    luaL_openlibs(L);

    if (luaL_loadfile(L, "main.lua")) {
        std::cerr << "lua load error: " << lua_tostring(L, -1) << std::endl;
    }

    if (lua_pcall(L, 0, 0, 0)) {
        std::cerr << "lua call error: " << lua_tostring(L, -1) << std::endl;
    }

    lua_close(L);
    return 0;
}
```

执行结果

```shell
Hello World
```

## 变量

全局变量，全局可用

```lua 
a = 100
```

本地变量，从当前作用域离开之后就会被垃圾回收，类似 RAII

```lua 
local a = 100 
```

## 数据类型

四个基础数据类型

- Nil
- Booleans
- Numbers
- Strings

Booleans 和 Nil 不赘述

### 识别变量类型

```lua
i = 100
s = "str"
print(type(i), type(s))
```

运行结果

```shell
number  string
```

### Numbers

在 lua 5.1 之后 int 类型基于双精度类型存储

```lua
a = 100
```

### Strings

```lua
a = "string"
```

多行字符串使用 [[]] 定义

```lua
s = [[
<html>
    <h1>Hello World
    </h1>
</html>
]]

print(s)
```

拼接字符串使用 .. 运算符，同时也可以拼接数字类型

```lua
a = "lua".."str"..123
```

一部分标准库

- 获取长度 `string.len(a)`
- 截取 `string.sub(a, 2, 3)`
- 查找 `local b, c = string.find(a, "HEAD or regex")`
- 替换 `string.gsub(a, "str or regex", "new str")`

### 类型转换

```lua
i = 100
s = "1"

print(type(i), type(s))
print(type(tostring(i)), type(tonumber(s)))
```

运行结果

```shell
number  string
string  number
```

### 数组

```lua
```

### 表

## 在 lua 中引用其他 lua 文件

```lua 
dofile("do.lua")
```

示例程序

main.lua

```lua
a = 100
local b = 1

print("print a in main.lua", a)
print("print b in main.lua", b)

dofile("sub.lua")
```

sub.lua

```lua
print("print a in sub.lua", a)
print("print b in sub.lua", b)
```

执行结果

全局变量可以跨文件读取，但局部变量不能

```shell
print a in main.lua     100
print b in main.lua     1
print a in sub.lua      100
print b in sub.lua      nil
```

## 流程控制

### 分支

分支采用 if then end 结构，elseif 也要加 then

```lua
a = 2;

if (a == 1 or a == 2) then
	print(12, a)
elseif (a == 3) then
	print(3, a)
else
	print(0, a)
end
```

### 循环

while

```lua
a = 0;

while (a < 5) do
    print(a)
    a = a + 1
end
```

运行结果

```shell
0
1
2
3
4
```

### repeat

repeat .. until 类似 do .. while

```lua
a = 0;

repeat
    print(a)
    a = a + 1
until a > 5
```

### for

```lua 
for 
```

## 泛型

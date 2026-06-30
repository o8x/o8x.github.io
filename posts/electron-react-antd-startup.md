---
display-name: Electron + React + Antd 初始化配置   
date: 2023-03-15 14:33:13  
categories:

- Electron

tags:

- React
- Electron

---

## 初始化

### React

初始化 React

```shell
npm init vite
✔ Project name: … dove
✔ Select a framework: › React
✔ Select a variant: › JavaScript

Scaffolding project in /.../dove...

Done. Now run:

    cd dove
    npm install
    npm run dev
```

安装路由器

```shell
npm install --save react-router-dom
```

### Electron

安装 electron

```shell
npm install --save-dev electron
```

修改 package.json

- 增加或修改 main 并指向到 main.js，以便让 electron 找到正确的 js 入口文件
- 将 type 从 module 改为 commonjs

```shell
{
    "main": "main.js",
    "type": "commonjs",
}

```

安装打包工具，可以自动将 electron 打包和生成为 .app 并打包成 zip。

```shell
npm install --save-dev @electron-forge/cli
```

设置脚手架

```shell
npx electron-forge import 
```

### Antd

```shell 
npm install --save antd @ant-design/icons
```

在 src/main.jsx 中导入 ant 样式表

```shell
import "antd/dist/reset.css"
```

### 浏览器测试

为了验证 Antd 是否配置完好，我们将 src/App.jsx 中 .card 中的 button 替换为 Antd 导入的 Button

修改前

```javascript
<button onClick={() => setCount((count) => count + 1)}>
    count is {count}
</button>
```

修改后

```jsx
import {Button} from "antd";

<Button type="primary" onClick={() => setCount((count) => count + 1)}>
    count is {count}
</Button>
```

运行查看

```shell
npm run dev
open http://localhost:5173
```

可以看到是来自 Antd 的按钮效果。

![](https://cdn-1252251443.cos.ap-nanjing.myqcloud.com/x/1678865547143.png)

## Electron

编写简单的 main.js 以使用 electron 打开初始化好的项目。

```javascript
const {app, BrowserWindow} = require("electron")

function createMainWindow() {
    let w = new BrowserWindow({
        width: 1024,
        height: 650,
    })

    w.loadURL("http://localhost:5173/")
}

app.whenReady().then(() => {
    createMainWindow()

    // MacOS 在没有窗口可用的情况下激活应用时会打开新的窗口
    app.on("activate", createMainWindow)
})

app.on("window-all-closed", () => {
    // macOS 应用通常即使在没有打开任何窗口的情况下也继续运行
    if (process.platform !== "darwin") {
        app.quit()
    }
})
```

### 预览

得益于我们刚才的工作，启动 electron 程序将变得非常简单

```shell
npm run start
```

![](https://cdn-1252251443.cos.ap-nanjing.myqcloud.com/x/1678865491515.png)

## 如何 Electron 判断是否处于生产环境

electron 官方提供了 isPackaged 属性，可以用做判断

```javascript
if (app.isPackaged) {
    w.openDevTools()
}
```

## Electron 预加载脚本

> Electron 的主进程是一个拥有着完全操作系统访问权限的 Node.js 环境。出于安全原因，渲染进程默认跑在网页页面上，而并非 Node.js里。为了将 Electron 的不同类型的进程桥接在一起，我们需要使用被称为 预加载 的特殊脚本。

> 并且从 Electron 20 开始，预加载脚本默认 沙盒化 ，不再拥有完整 Node.js 环境的访问权。 实际上，这意味着你只拥有一个 polyfilled 的 require 函数，这个函数只能访问一组有限的 API。

| 可用的 API           | 	详细信息              |
| -----|--------------------|
| Electron 模块	      | 渲染进程模块             |
| Node.js 模块        | 	events、timers、url |
| Polyfilled 的全局模块	 |Buffer、process、clearImmediate、setImmediate|

详细的沙盒教程 https://www.electronjs.org/zh/docs/latest/tutorial/sandbox

### 如何使用预加载脚本

创建主窗口的时候使用 preload 加载 js 文件

```javascript
let w = new BrowserWindow({
    width: 1024,
    height: 650,
    webPreferences: {
        preload: path.join(__dirname, "preload.js"),
    },
})
```

如上面所说，需要进行桥接。所以我们要在 preload.js 中导入 {contextBridge}

```javascript
const {contextBridge} = require("electron")

contextBridge.exposeInMainWorld("electron", {
    hello: name => {
        console.log("hello", name)
    },
})
```

此时我们向渲染进行 expose 了一个名为 electron 的对像，它具有一个名为 hello 的方法并接受一个 name 参数。我们可以简单的实现调用它向主进程问好。

```javascript
windows.electron.hello("react")
```

### 确认渲染进程已经完成DOM加载

这是一个传统的 javascript 事件，可以在 preload 中确认渲染进程的状态。 DOMContentLoaded 事件将会在 HTML 文档完全解析且所有延迟脚本都已下载并执行时被触发。但它不会等待图像、异步脚本等其他内容完成加载。

```javascript
window.addEventListener("DOMContentLoaded", (event) => {
    console.log("DOM fully loaded and parsed")
})
```

## 进程间通信

可以使用 Electron 的 ipcMain 模块和 ipcRenderer 模块来进行进程间通信。但这些模块只能在主进程中使用，而不能在 preload.js 中。

### on/send

这是一种传统通信方式，允许多次提供监听，在 send 时所有监听器都会被调用。只要主进程正在运行，渲染器就可以从多次调用的 ipcMain 通道接收数据。

```javascript
ipMain.on("listen", () => {
    console.log("in listen")
})
ipcRenderer.send("listen")
```

### handle/invoke

这是一组新的通信API，可以代替即将废弃的 remote 模块的部分功能。与 on/send 几乎没有功能差异。

```javascript
ipMain.handle("listen", () => {
    console.log("in listen")
})
ipcRenderer.invoke("listen")
```

### 繁琐的通信方法

如此一来，进程间通信就变得非常繁琐，渲染进程希望和主进程通信时在形式上要过两道桥。

例如我们试图在渲染进程中调用 electron 使用本地浏览器打开一个链接，就需要这样写。

preload.js

```javascript
const {contextBridge, ipcRenderer} = require("electron")

contextBridge.exposeInMainWorld("electron", {
    openUrlInBrowser: link => {
        ipcRenderer.invoke("open/url-in-browser", link)
    },
})
```

main.js

```javascript
let {shell, ipcMain} = require("electron")

ipcMain.handle("open/url-in-browser", (e, link) => {
    shell.openExternal(link)
})
```

index.html

```javascript
window.electron.openUrlInBrowser("https://github.com")
```

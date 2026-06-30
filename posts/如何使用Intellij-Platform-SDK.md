---
display-name: 如何使用Intellij Platform SDK
date: 2020-11-21 11:53:50
categories:
- Intellij Platform
tags:

- Intellij SDK

---



官方文档

- [https://jetbrains.org/intellij/sdk/docs/intro/welcome.html](https://jetbrains.org/intellij/sdk/docs/intro/welcome.html)
- [https://github.com/JetBrains/intellij-sdk-docs](https://github.com/JetBrains/intellij-sdk-docs)

官方示例：

- [https://github.com/JetBrains/intellij-sdk-code-samples](https://github.com/JetBrains/intellij-sdk-code-samples)

## 简单的插件工程

如图所示，我们可以使用 intellij IDEA 直接创建一个intellij Platform 插件

项目允许使用 Java 进行开发

![image-20201121135527170](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121135531.png)

**基本工程目录**

这是开发插件的最小工程，没有使用包管理器进行项目管理，所以如果需要外部依赖，则需要手动导入 jar 包

```tree
.
├── resources
│ └── META-INF
│     └── plugin.xml
├── src
└── project.iml

3 directories, 2 files
```

**相关文件**

| 文件                          | 功能                                                         |
| ----------------------------- | ------------------------------------------------------------ |
| project.iml                   | IDEA 的项目管理文件，无用                                    |
| src/                          | 源码目录，即插件的功能实现写在这里面                         |
| resources/META-INF/           | 配置资源目录，存放LOGO和配置文件等                           |
| resources/META-INF/plugin.xml | 默认的插件配置文件，用于管理插件的名称、版本、依赖、简介、更新日志、以及各种注册钩子 |

## 高级插件工程（推荐）

在 Gradle 选项中，创建 Intellij Platform Plugin 项目。

该选项允许使用 Java 或 kotlin 进行开发

![image-20201121140800034](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121140801.png)

**基本工程目录**

这是开发插件的最小工程，使用gradle包管理器进行项目管理

仔细观察，工程结构与上方的简单结构基本是对应的，只是多了 gradle 相关的文件和java这个顶级包

test 是单元测试，先不做介绍

```
.
├── build.gradle
├── gradlew
├── gradlew.bat
├── settings.gradle
└── src
    ├── main
    │ ├── java
    │ └── resources
    │     └── META-INF
    │         └── plugin.xml
    └── test
        ├── java
        └── resources
```

以下文章完全基于高级插件工程进行介绍。

## 配置项

插件项目配置，即 Plugin.xml

```xml

<idea-plugin>
    <id>插件ID，不可与其他项目重复，只允许英文与数字</id>
    <name>插件名称，不可出现中文</name>
    <vendor email="联系方式" url="插件官网">组织或作者名称</vendor>
    <description>插件描述，至少40个字符，可使用 html</description>
    <depends>com.intellij.modules.platform</depends>
    <change-notes>更新日志，可使用 html</change-notes>

    <!-- 扩展配置，生命周期钩子、设置项、工具栏等均需要在这里配置 -->
    <extensions defaultExtensionNs="com.intellij">
        <!-- 生命周期钩子 -->
        <postStartupActivity implementation="" id=""/>
    </extensions>

    <!-- 动作配置，上节已经演示过 -->
    <actions>
        <!-- 配置动作组 -->
        <group id="" text="xxx" popup="true">
            <!-- 动作组的位置 -->
            <add-to-group group-id="ToolsMenu" anchor="first"/>
            <!-- 动作 -->
            <action id="Action ID" class="Action Class" text="动作名"></action>
        </group>

        <!-- 不加入组的单独动作 -->
        <action id="Action ID" class="Action Class" text="动作名">
            <add-to-group group-id="ToolsMenu" anchor="first"/>
        </action>
    </actions>

    <!-- 项目组件 -->
    <project-components>
        <component>
            <!-- 旧版生命周期钩子，已废弃 -->
            <implementation-class>Class</implementation-class>
        </component>
    </project-components>
</idea-plugin>
```

## Hello World

我们开发一个简单的插件，实现在 intellij IDEA 使用弹出框显示 hello world

**创建Action**

首先在`/src/main/java`创建一个类并命名为`Main`，写入以下内容

```java
import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.ui.Messages;
import org.jetbrains.annotations.NotNull;

public class Main extends AnAction
{
    @Override
    public void actionPerformed(@NotNull AnActionEvent e)
    {
        Messages.showInfoMessage("Hello World", "INFO");
    }
}

```

**注册Action**

右键单击类名点击 Show Context Actions，或直接使用快捷键 Command + Enter。点击 Register Action 呼出以下菜单。

然后对 Main 类进行注册，将其注册成为 Action。

实际上可以简单的理解为，在顶部的工具栏中注册一个项目，在点击后调用我们写好的方法。

我现在的选项是，在Tools菜单的顶部，注册了一个名为 Hello World 的选项。

![image-20201121143642905](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121143646.png)

点击OK之后观察 plugin.xml 发现 actions 段多了以下内容，这便是注册菜单的实际行为，换言之我们完全可以不使用图形化的注册菜单，直接书写 xml 也能达到完全一致的效果。

```xml

<action id="Main" class="Main" text="Hello World" description="简单的 Hello World 示例">
    <add-to-group group-id="ToolsMenu" anchor="first"/>
</action>
```

**运行**

一般来说，通过IDEA创建的工程会自带一个类似这样的启动配置，直接点击即可运行项目

![image-20201121144955717](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121144957.png)

如果没有带？

则双击 shift 输入 gradle 进行Action搜索，选中第一个直接回车。

![image-20201121145219886](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121145221.png)

然后会打开如下样式的窗口，直接鼠标双击 intellij 下的 runIde 即可运行

![image-20201121145342920](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121145344.png)

**运行**

经过gradle编译之后，IDEA会启动一个新的IDEA实例来运行我们的插件（此处可能需要下载 IDEA Community 源码，耐心等待即可，加速方法懂得都懂）。

![image-20201121145515952](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121145517.png)

启动完成类似如下，我们按正常流程创建一个空项目即可。

不要创建 Java 项目，那样会在项目启动后自动建立 JVM索引，非常耗时。

**每次运行 runIde 都要新建项目，很麻烦？****

在空项目中新建一个文件并保存，下次运行就会自动打开该项目。

![image-20201121145637040](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121145638.png)通过单击顶部的 Tools
菜单，我们可以发现 Hello World 已经注册到了顶部。

![image-20201121150133725](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121150135.png)

**单击我们注册的 Hello World，大功告成**

![image-20201121150401447](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201121150403.png)

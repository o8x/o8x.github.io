---
display-name: Intellij Platform SDK UI
date: 2020-11-21 11:54:40
categories:
- Intellij Platform
tags:

- Intellij SDK

---



UI部分主要是由 swing 构成，所以最好先储备一些知识。甚至可以在 idea 中使用原生的 swing 进行编程。

## 使用GUI进行界面的绘制

新建一个包，然后在包名上右键单击，使用 New -> Swing UI Designer -> GUI Form 新建一个可视化的界面绘制器

![image-20201225161202610](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225161203.png)

大概像这样

![image-20201225162424706](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225162426.png)

### 绘制界面

接下来我们在IDEA中实现一个时钟，无论如何都居中并实时更新当前时间。![image-20201225164309836](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225164311.png)

首先从右侧选择JLabel，并在主JPanle任意位置点击，放置一个 Label用来显示时间，并将其改名为 timeBox。

![image-20201225162610723](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225162614.png)

在Label的左右两侧，添加两个 HSpacer 实现左右居中

![image-20201225162818091](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225162820.png)

在Label的上下两侧，添加两个 VSpacer 实现上下居中，默认为上下居中，但是为了实现可掌控的上下居中，我们也加上。最终效果如下图。

![image-20201225162938300](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225162939.png)

## 开始编程

默认会生成两个文件，一个 .form 一个 .java。

![image-20201225163214294](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225163215.png)

点击 .java，编程实现实时更新时间

```java
package ui;

import javax.swing.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class NowTime
{
    // 默认的面板，即这个ToolWindow
    private JPanel panel;
    // 即为刚才在设计器中定义的timebox
    private JLabel timeBox;

    public NowTime()
    {
        // 使用秒级定时器，每秒更新时间。
        ScheduledExecutorService service = Executors.newSingleThreadScheduledExecutor();
        service.scheduleAtFixedRate(() -> {
            // 更新Jlabel的时间
            timeBox.setText(
                new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())
            );
        }, 0, 1, TimeUnit.SECONDS);
    }

    // 将Panel暴露出去，以便于注册
    public JComponent getPanel()
    {
        return panel;
    }
}
```

创建 ToolWindowFactory 的实现类，用于将我们的ToolWindow绘制到IDE中。

```java
package ui;

import com.intellij.openapi.project.Project;
import com.intellij.openapi.wm.ToolWindow;
import com.intellij.openapi.wm.ToolWindowFactory;
import com.intellij.ui.content.Content;
import com.intellij.ui.content.ContentFactory;
import org.jetbrains.annotations.NotNull;

public class TimeboxWindow implements ToolWindowFactory
{
    public void createToolWindowContent(@NotNull Project project, @NotNull ToolWindow toolWindow)
    {
        // 获取刚才的类
        NowTime        window        = new NowTime();
        ContentFactory contentFactory = ContentFactory.SERVICE.getInstance();
        // 将 Panel 注册进IDE中
        Content        content        = contentFactory.createContent(window.getPanel(), "", false);
        toolWindow.getContentManager().addContent(content);
    }
}
```

在 plugin.xml 中注册ToolWindowFactory实现类

```xml

<extensions defaultExtensionNs="com.intellij">
    <!-- anchor 为注册的默认显示方向，bottom 为界面最下方，此外还有 left right 可用 -->
    <toolWindow id="Timebox" secondary="true" anchor="bottom" factoryClass="ui.TimeboxWindow"/>
</extensions>
```

## 效果图

![2020-12-25 16.06.15](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225160915.gif)

还可以通过修改 Font 选项，实现老年大字体模式。

![image-20201225164209704](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225164211.png)

![image-20201225164222907](https://alextech-1252251443.cos.ap-guangzhou.myqcloud.com/20201225164224.png)

## 后续

本文只简单介绍设计器的使用流程，其他的组件参考 Swing 使用即可


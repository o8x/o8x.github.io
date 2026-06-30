---
display-name: 利用 (git rebase, git cherry-pick) 迁移多次提交到新分支
date: 2019-01-23 10:04:57
tags:

- git

---

# cherry-pick

> 主要面对commi不多，且没有与其他分支合并的代码

迁移多个或单个commit到当前分支

1. 来到新分支

```bash
git checkout -b new/branch
```

1. 合并commit

```bash
git cherry-pick 4d24e7f9 206ea891 7ed294 76e81641 .... 
```

1. 推送到版本库

```bash
git push origin new/branch
```

---------------

# rebase

> 应用于有大量commit需要迁移，把多个commit中的一部分合并为一个

### 找到基线commit

    > 也就是从选择的基线commit之后的commit都合并成一个

```bash
git log -6
```

```git
commit 4fa4a96dd7007756e64eab3d8bf27bc7d110c0d7 (HEAD -> master)
Author: o <im@stdout.com.com>
Date:   Wed Jan 23 11:17:06 2019 +0800

    提交8

commit 0dcd341b904e923a13f689d29a058be1ba3aadde
Author: o <im@stdout.com.com>
Date:   Wed Jan 23 11:17:04 2019 +0800

    提交7

commit 396545af072c4943ffdc34390980833ef49321b9
Author: o <im@stdout.com.com>
Date:   Wed Jan 23 11:17:02 2019 +0800

    提交6

commit d015348313b25bcc5c9cadd1388a0c9c35a58534
Author: o <im@stdout.com.com>
Date:   Wed Jan 23 11:17:00 2019 +0800

    提交5

commit f189a136df16a7019d1146df1c669057f0ee2f7a
Author: o <im@stdout.com.com>
Date:   Wed Jan 23 11:16:58 2019 +0800

    提交4

commit 7f237cea5fa281c5e26dc19229dfd5fccf8425aa
Author: o <im@stdout.com.com>
Date:   Wed Jan 23 11:16:56 2019 +0800

    提交3
(END)
```

例如我们希望合并列表中除 `提交5` 之外的4次提交，那么基线提交就是 `提交3` (7f237cea5)

### 开始合并

> 有两种常用方法，自动和干扰自动合并（手动）

1. 自动进行，会自动合并 `提交3` 之后的所有提交，没有办法实现我们排除 `提交5` 的要求

```bash
git rebase 7f237cea5
```

2. 干扰自动合并（手动），可以实现对基线commit之后的每个commit的修改和管理

```bash
git rebase -i 7f237cea5
```

会得到一个类似这样的界面，根据提示我们可以知道，应该把需要合并的 commit 的 pick 修改成 s，不需要的改成 d

```bash
    pick f189a13 提交4
    pick d015348 提交5
    pick 396545a 提交6
    pick 0dcd341 提交7
    pick 4fa4a96 提交8

    # 变基 7f237ce..4fa4a96 到 7f237ce（5 个提交）
    #
    # 命令:
    # p, pick = 使用提交
    # r, reword = 使用提交，但修改提交说明
    # e, edit = 使用提交，但停止以便进行提交修补
    # s, squash = 使用提交，但和前一个版本融合
    # f, fixup = 类似于 "squash"，但丢弃提交说明日志
    # x, exec = 使用 shell 运行命令（此行剩余部分）
    # d, drop = 删除提交
    #
    # 这些行可以被重新排序；它们会被从上至下地执行。
    #
    # 如果您在这里删除一行，对应的提交将会丢失。
    #
    # 然而，如果您删除全部内容，变基操作将会终止。
    #
    # 注意空提交已被注释掉
```

修改后

```bash
p f189a13 提交4
d d015348 提交5
s 396545a 提交6
s 0dcd341 提交7
s 4fa4a96 提交8
```

这样就会在rebase 过程中排除 `提交5`，并在合并完成后使用 `提交4` 的说明，然后保存，退出即可进入自动rebase过程，完全按照提示操作即可，不再赘述

```bash
$ git status 
交互式变基操作正在进行中；至 7f237ce
......
```

### 合并完成

> 经过了一路的解决冲突和 `git rebase --continue` , 我们终于看到了

```bash
$ git rebase --continue
没有正在进行的变基？
$ git status
位于分支 master
无文件要提交，干净的工作区
```

再次查看log，会发现多出了一个整合了刚才rebase的所有commit的新commit

```bash
$ git log -1
commit 4e0d671a0b0ddb7e3c05f7ef4355b96827a72aa6 (HEAD -> master)
Author: o <im@stdout.com.com>
Date:   Wed Jan 23 11:16:58 2019 +0800

    提交4
    
    提交6
    
    提交7
    
    提交8
```

然后使用上文提到的 `cherry-pick` 把这个合并后的commit迁移到新分支

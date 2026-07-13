---
display-name: 永久删除Git中的文件，包括历史commit
date: 2020-05-26 11:29:14
tags: ["git"]
---

PATH-TO-YOUR-FILE-WITH-SENSITIVE-DATA就是你要删除的文件的相对路径(相对于git仓库的根目录), 替换成你要删除的文件路径即可

```shell
$ git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch PATH-TO-YOUR-FILE-WITH-SENSITIVE-DATA' \
  --prune-empty --tag-name-filter cat -- --all
```

添加到.gitignore文件里并push修改后的repo

```shell
$ echo "YOUR-FILE-WITH-SENSITIVE-DATA" >> .gitignore
$ git add .gitignore
$ git commit -m "Add YOUR-FILE-WITH-SENSITIVE-DATA to .gitignore"
[master 051452f] Add YOUR-FILE-WITH-SENSITIVE-DATA to .gitignore
1 files changed, 1 insertions(+), 0 deletions(-)
```

以强制覆盖的方式推送你的repo, 大功告成

```shell
git push origin --force --all
```

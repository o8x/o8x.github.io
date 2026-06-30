---
display-name: 如何批量替换git commit中的开发者信息
date: 2020-05-26 11:28:52
tags:

- git

---

```bash
#!/bin/sh
git filter-branch --env-filter '

OLD_EMAIL="im@stdout.com.com"
CORRECT_NAME="Alex"
CORRECT_EMAIL="alex@stdout.com.com"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_COMMITTER_NAME="$CORRECT_NAME"
export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_AUTHOR_NAME="$CORRECT_NAME"
export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

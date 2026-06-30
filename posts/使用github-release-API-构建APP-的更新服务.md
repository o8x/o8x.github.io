---
display-name: 使用github release API 构建APP 的更新服务
date: 2018-01-04 17:06:21
tags:  
- git
- github
---

### 使用

> 在github仓库创建一个不是预发布版本的release，写入内容和上传APK文件之后点击publish按钮发布。而后release中就会有一个zip和tar.gz版本可以下载。同时也会有对应的API 。

#### API 地址:

https://api.github.com/repos/所有者/工程名/releases/版本

#### 返回内容 :

```json
{
    "url":              "https://api.github.com/repos/DevTTL/LAMP/releases/9103900",
    "assets_url":       "https://api.github.com/repos/DevTTL/LAMP/releases/9103900/assets",
    "upload_url":       "https://uploads.github.com/repos/DevTTL/LAMP/releases/9103900/assets{?name,label}",
    "html_url":         "https://github.com/DevTTL/LAMP/releases/tag/1.0",
    "id":               9103900,
    "tag_name":         "1.0",
    "target_commitish": "master",
    "name":             "一个大致的完整版本",
    "draft":            false,
    "author":           {
        "login":               "DevTTL",
        "id":                  20666153,
        "avatar_url":          "https://avatars2.githubusercontent.com/u/20666153?v=4",
        "gravatar_id":         "",
        "url":                 "https://api.github.com/users/DevTTL",
        "html_url":            "https://github.com/DevTTL",
        "followers_url":       "https://api.github.com/users/DevTTL/followers",
        "following_url":       "https://api.github.com/users/DevTTL/following{/other_user}",
        "gists_url":           "https://api.github.com/users/DevTTL/gists{/gist_id}",
        "starred_url":         "https://api.github.com/users/DevTTL/starred{/owner}{/repo}",
        "subscriptions_url":   "https://api.github.com/users/DevTTL/subscriptions",
        "organizations_url":   "https://api.github.com/users/DevTTL/orgs",
        "repos_url":           "https://api.github.com/users/DevTTL/repos",
        "events_url":          "https://api.github.com/users/DevTTL/events{/privacy}",
        "received_events_url": "https://api.github.com/users/DevTTL/received_events",
        "type":                "User",
        "site_admin":          false
    },
    "prerelease":       false,
    "created_at":       "2017-11-15T07:18:44Z",
    "published_at":     "2018-01-04T08:59:13Z",
    "assets":           [
    ],
    "tarball_url":      "https://api.github.com/repos/DevTTL/LAMP/tarball/1.0",
    "zipball_url":      "https://api.github.com/repos/DevTTL/LAMP/zipball/1.0",
    "body":             "目前的命令的统计已经足以完整的搭建一个LAMP或者LNMP架构de WEB服务了"
}
```

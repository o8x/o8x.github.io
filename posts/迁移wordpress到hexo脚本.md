---
display-name: 迁移 wordpress 文章到 hexo
date: 2020-05-26 10:54:06
tags: ["杂项"]
---

### 已知缺陷

> tag 和目录将会丢失

### 基本原理

1. php 查询数据表，并转换成json
1. 遍历json，利用 [Turndown](https://www.npmjs.com/package/to-markdown) 将 `html` 转换为 `markdown`
1. 替换文章中的资源链接为COS链接
1. 按 `hexo` 格式生成带有标题和时间的 `markdown`
1. 再使用 `Blob`和`window.URL.createObjectURL` 这两个`api`生成下载链接

### 代码全文

> 临时使用，未格式化和封装

```php
$list = DB::table('wp_posts')->raw(
    "select id, post_date as date, post_title as title, post_content as content from wp_posts  where post_status = 'publish' and post_content != ''"
);

// 转JSON
$listJson = json_encode(list);
$script   = <<<HTML
<script src="path/to-markdown.js"></script>
<div class="list"></div>
<script>
    let time       = 0
    const contents = $listJson

    for (let it of contents) {
        // 生成符合 hexo 格式的markdown，只能使用 + 拼接
        // 不能使用插值表达式，因为与php的模板变量会产生冲突
        const content = '---\\ndisplay-name: ' + it.title 
                        + '\\ndate: ' + it.date 
                        + '\\ntags: \\n---\\n\\n' 
                        + toMarkdown(it.content)
        
        const blobContent = new Blob([content] , {type : 'text/html'})
        
        // 延迟下载，否则不能下载多个文件
        time = time + 100
        setTimeout(() => downloadFileByBlob(
            window.URL.createObjectURL(blobContent) ,
            it.title + '.md'
        ) , time);
    }
        
    function downloadFileByBlob(blobUrl, filename) {
        const eleLink = document.createElement('a')
        eleLink.download = filename
        eleLink.style.display = 'none'
        eleLink.href = blobUrl
        // 触发点击
        document.body.appendChild(eleLink)
        eleLink.click()
        // 然后移除
        document.body.removeChild(eleLink)
    }
    </script>
HTML;

file_put_contens('php://output' , $script);
```

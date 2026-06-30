---
display-name: MacOS Finder 隐藏文件  
date: 2023-05-22 14:27:36  
---

显示

```shell
defaults write com.apple.finder AppleShowAllFiles -boolean true
```

隐藏

```shell
defaults write com.apple.finder AppleShowAllFiles -boolean false
```

杀死 Finder 生效
```shell 
killall Finder
```

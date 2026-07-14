---
display-name: macos 基本操作
date: 2020-05-26 11:29:39
tags: ["杂项"]
---

## Finder

macos 在应用使用弹出式的文件选择器时选中被macos隐藏的目录，比如 /tmp/

在窗口中使用 cmd + shift + g 即可

## brew

> macos 上的包管理工具，类似linux的yum和apt

### 插件

- 特殊命令高亮

```shell
brew install zsh-syntax-highlighting

cat >>~/.zshrc<<EOF
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

source ~/.zshrc
```

**注：**如果高亮不生效，在 `~/.zshrc` 的 `plugins` 配置追加 `zsh-syntax-highlighting` 即可

- 自动建议填充

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
```

编辑 `~/.zshrc` , 在 `plugins` 中追加`zsh-autosuggestions`

### 更换源地址

- 中科大

```shell
cd $(brew --repo)
git remote set-url origin git://mirrors.ustc.edu.cn/brew.git

cd $(brew --repo)/Library/Taps/homebrew/homebrew-core
git remote set-url origin git://mirrors.ustc.edu.cn/homebrew-core.git

echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
```

- 清华

```shell
cd $(brew --repo)
git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/brew.git

cd $(brew --repo)/Library/Taps/homebrew/homebrew-core
git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew-core.git

echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles' >> ~/.bash_profile
```

- 恢复缺省地址

```shell
cd $(brew --repo)
git remote set-url origin https://github.com/Homebrew/brew.git

cd $(brew --repo)/Library/Taps/homebrew/homebrew-core
git remote set-url origin https://github.com/Homebrew/homebrew-core
```

## 显示缓存目录

```shell
brew --cache
```

## 为应用程序单独设置语言

```shell
defaults write com.apple.iWork.Pages AppleLanguages '("zh-Hans")'
```

## Macos 实时显示按键

```shell
brew cask install keycastr
```

## MacOS 10.15 文件已损坏

```shell 
xattr -r -d com.apple.quarantine
```

## SIP

### 查看SIP状态

```shell 
csrutil status
```

### 关闭SIP

> 重启 Command + R 进入恢复模式

```shell
csrutil disable
```

### 开启 SIP

```shell 
csrutil enable
```

## 解决 无法打开应用，应该移到废纸篓

```shell 
sudo spctl --master-disable
```

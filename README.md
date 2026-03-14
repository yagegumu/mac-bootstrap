# Mac Bootstrap

一个用于 **快速初始化 Mac 开发环境** 的脚本。

当你更换新电脑或重装系统时，只需运行一条命令，即可自动安装常用开发工具和效率软件。

---

# 🚀 快速开始

在终端运行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/yagegumu/mac-bootstrap/main/setup_mac.sh)

---

## 📦 脚本会安装的内容

### 系统环境

- Homebrew
- Xcode Command Line Tools

### 终端环境

- iTerm2
- Oh My Zsh
- zsh-autosuggestions
- zsh-syntax-highlighting

### 开发工具

- Git
- Python + pyenv
- Visual Studio Code
- OrbStack (Docker)

### 常用软件

- Google Chrome
- Maccy（剪贴板管理）
- Snipaste（截图工具）
- AltTab（窗口切换）
- Stats（系统监控）
- AppCleaner（软件卸载工具）

---

## ⚙️ 安装完成后的操作

由于 macOS 的安全机制，部分软件需要手动授权。

请在 **系统设置 → 隐私与安全性** 中授权：

| 软件 | 权限 |
|-----|-----|
| Maccy | 辅助功能 |
| Snipaste | 屏幕录制 |
| AltTab | 辅助功能 |

部分软件需要 **首次打开一次完成初始化**。

---

## 🔧 常用维护命令

更新 Homebrew 软件：

```bash
brew update
brew upgrade
brew cleanup

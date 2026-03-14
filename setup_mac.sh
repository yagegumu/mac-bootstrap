#!/usr/bin/env bash
set -euo pipefail

echo "==> 开始初始化 Mac 开发环境..."

# -----------------------------
# 1. 检测芯片架构和 Homebrew 路径
# -----------------------------
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

BREW_BIN="$BREW_PREFIX/bin/brew"

# -----------------------------
# 2. 安装 Xcode Command Line Tools（如果缺失）
# -----------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> 安装 Xcode Command Line Tools..."
  xcode-select --install || true
  echo "==> 请先完成 Command Line Tools 安装后，再重新执行本脚本。"
  exit 1
fi

# -----------------------------
# 3. 安装 Homebrew
# -----------------------------
if [[ ! -x "$BREW_BIN" ]]; then
  echo "==> 安装 Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> 配置 Homebrew 环境..."
eval "$("$BREW_BIN" shellenv)"

if ! grep -qs 'brew shellenv' "$HOME/.zprofile"; then
  if [[ "$ARCH" == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
  fi
fi

# -----------------------------
# 4. 更新 Homebrew
# -----------------------------
echo "==> 更新 Homebrew..."
brew update

# -----------------------------
# 5. 安装 CLI 工具
# -----------------------------
echo "==> 安装命令行工具..."
brew install \
  git \
  wget \
  curl \
  htop \
  tmux \
  pyenv \
  python \
  zsh-autosuggestions \
  zsh-syntax-highlighting

# -----------------------------
# 6. 安装 GUI 软件
# -----------------------------
echo "==> 安装 GUI 软件..."
brew install --cask \
  iterm2 \
  google-chrome \
  visual-studio-code \
  orbstack \
  maccy \
  snipaste \
  alt-tab \
  stats \
  appcleaner

# -----------------------------
# 7. 安装 Oh My Zsh
# -----------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> 安装 Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# -----------------------------
# 8. 确保默认 shell 为 zsh
# -----------------------------
CURRENT_SHELL="$(dscl . -read /Users/"$USER" UserShell | awk '{print $2}')"
ZSH_PATH="$(command -v zsh)"
if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  echo "==> 设置默认 shell 为 zsh..."
  chsh -s "$ZSH_PATH" || true
fi

# -----------------------------
# 9. 配置 ~/.zshrc
# -----------------------------
touch "$HOME/.zshrc"

# plugins 改成最小配置
if grep -q '^plugins=' "$HOME/.zshrc"; then
  perl -0pi -e 's/^plugins=\([^\)]*\)/plugins=(git)/m' "$HOME/.zshrc"
else
  echo 'plugins=(git)' >> "$HOME/.zshrc"
fi

# pyenv 配置
if ! grep -qs 'export PYENV_ROOT="$HOME/.pyenv"' "$HOME/.zshrc"; then
  cat >> "$HOME/.zshrc" <<'EOF'

# >>> pyenv >>>
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# <<< pyenv <<<
EOF
fi

# brew 安装的 zsh 插件
if ! grep -qs 'zsh-autosuggestions.zsh' "$HOME/.zshrc"; then
  cat >> "$HOME/.zshrc" <<EOF

# >>> zsh plugins via Homebrew >>>
source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# <<< zsh plugins via Homebrew <<<
EOF
fi

# syntax-highlighting 兼容配置
touch "$HOME/.zshenv"
if ! grep -qs 'ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR' "$HOME/.zshenv"; then
  echo "export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=$BREW_PREFIX/share/zsh-syntax-highlighting/highlighters" >> "$HOME/.zshenv"
fi

# -----------------------------
# 10. 安装 Python 3.12 并设为全局版本
# -----------------------------
echo "==> 安装并配置 Python 3.12..."
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

if ! pyenv versions --bare | grep -qx '3.12.13'; then
  pyenv install 3.12.13
fi
pyenv global 3.12.13

# -----------------------------
# 11. 配置 VSCode code 命令
# -----------------------------
echo "==> 配置 VSCode code 命令..."
mkdir -p "$BREW_PREFIX/bin"
if [[ -d "/Applications/Visual Studio Code.app" ]]; then
  ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "$BREW_PREFIX/bin/code"
fi

# -----------------------------
# 12. 基础检查
# -----------------------------
echo "==> 基础检查..."
brew --version
git --version
python --version || true
python3 --version || true
pyenv --version
code --version || true

echo ""
echo "==> 安装完成。"
echo "==> 请手动完成以下权限授权："
echo "    1. Maccy -> 辅助功能"
echo "    2. Snipaste -> 屏幕录制"
echo "    3. AltTab -> 辅助功能"
echo "    4. OrbStack -> 首次启动初始化"
echo "    5. VSCode -> 首次打开"
echo ""
echo "==> 最后建议执行："
echo "    source ~/.zshrc"
echo "    open -a OrbStack"
echo "    open -a Maccy"
echo "    open -a Snipaste"
echo "    open -a AltTab"
echo "    open -a Stats"
echo "    open -a 'Visual Studio Code'"
echo ""
echo "==> 全部完成。"

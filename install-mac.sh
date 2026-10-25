#!/bin/bash
# Ставит на Mac: ffmpeg, whisper, Headroom, MemPalace, Remotion, Playwright, Figma
set -e

# 1. Homebrew (магазин программ)
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi

# 2. Основные программы
# Python 3.13: на нём всё проверено, на самых новых версиях может не встать
brew install node python@3.13 ffmpeg

# 3. whisper, Headroom и MemPalace (в отдельной "коробке" ~/ai-tools)
if [ -x ~/ai-tools/bin/python ] && ! ~/ai-tools/bin/python -V | grep -q " 3\.13\."; then
  rm -rf ~/ai-tools
fi
"$(brew --prefix python@3.13)/bin/python3.13" -m venv ~/ai-tools
source ~/ai-tools/bin/activate
pip install --upgrade pip
pip install faster-whisper "headroom-ai[proxy]" mempalace

# 4. Remotion и Playwright (в папке ~/remotion-app)
mkdir -p ~/remotion-app
cd ~/remotion-app
[ -f package.json ] || npm init -y
npm i remotion @remotion/cli react react-dom playwright
npx playwright install chromium

# 5. Чтобы всё включалось само
grep -q 'ai-tools/bin/activate' ~/.zshrc 2>/dev/null || echo 'source ~/ai-tools/bin/activate' >> ~/.zshrc
grep -q 'HEADROOM_BEACON' ~/.zshrc 2>/dev/null || echo 'export HEADROOM_BEACON=off' >> ~/.zshrc

# 6. Приложение Figma
[ -d /Applications/Figma.app ] || brew install --cask figma

# 7. Claude Code
command -v claude >/dev/null 2>&1 || npm install -g @anthropic-ai/claude-code

# 8. Подключить MemPalace и Figma к Claude Code
if command -v claude >/dev/null 2>&1; then
  claude mcp add --scope user mempalace -- ~/ai-tools/bin/mempalace-mcp || true
  claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp || true
else
  echo "Claude Code не найден. Потом выполните:"
  echo "  claude mcp add --scope user mempalace -- ~/ai-tools/bin/mempalace-mcp"
  echo "  claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp"
fi

echo ""
echo "Готово! Закройте Терминал и откройте снова."

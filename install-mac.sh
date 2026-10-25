#!/bin/bash
# Ставит на Mac: ffmpeg, whisper, Headroom, MemPalace, Remotion, Playwright, Figma, Claude Code.
# Работает и на новых Mac (Apple M1/M2/M3...), и на старых Mac с процессором Intel.
set -e

# Весь отчёт пишется ещё и в файл ~/install-log.txt
exec > >(tee ~/install-log.txt) 2>&1
trap 'echo ""; echo "❌ ОШИБКА на строке $LINENO: $BASH_COMMAND"; echo "Пришлите Claude файл ~/install-log.txt"' ERR

echo "▶ Начинаю установку..."
if [ "$(uname -m)" = "x86_64" ]; then
  echo "  Mac с процессором Intel: ставлю версии, которые на нём работают."
fi

mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# 1. uv: ставит Python и программы на Python. Работает и на Intel, без Homebrew.
echo "▶ 1/7 uv"
command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. whisper, Headroom, MemPalace и ffmpeg в отдельной "коробке" ~/ai-tools
# Python 3.13: на нём всё проверено. Старые версии onnxruntime и av нужны,
# потому что новые больше не выходят для Mac на Intel.
echo "▶ 2/7 whisper, Headroom, MemPalace, ffmpeg"
if [ -x ~/ai-tools/bin/python ] && ! ~/ai-tools/bin/python -V | grep -q " 3\.13\."; then
  rm -rf ~/ai-tools
fi
[ -x ~/ai-tools/bin/python ] || uv venv --python 3.13 ~/ai-tools
uv pip install --python ~/ai-tools/bin/python \
  faster-whisper "headroom-ai[proxy]" mempalace imageio-ffmpeg \
  "onnxruntime==1.23.2" "av<16"

# ffmpeg: готовая программа из imageio-ffmpeg, собирать не нужно
if ! command -v ffmpeg >/dev/null 2>&1; then
  FF=$(~/ai-tools/bin/python -c "import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())")
  ln -sf "$FF" ~/ai-tools/bin/ffmpeg
fi

# 3. Node.js нужен для Remotion и Playwright
echo "▶ 3/7 Node.js"
if ! command -v node >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1 && [ "$(uname -m)" = "arm64" ]; then
    brew install node
  else
    echo "❌ Нет Node.js. Скачайте его с https://nodejs.org (кнопка LTS), поставьте и запустите этот файл снова."
    exit 1
  fi
fi

# 4. Remotion и Playwright (в папке ~/remotion-app)
echo "▶ 4/7 Remotion и Playwright"
mkdir -p ~/remotion-app
cd ~/remotion-app
[ -f package.json ] || npm init -y >/dev/null
npm i remotion @remotion/cli react react-dom playwright
npx playwright install chromium || echo "⚠️ Браузер для Playwright не скачался, остальное работает."
cd ~

# 5. Чтобы всё включалось само
echo "▶ 5/7 Настройка Терминала"
grep -q '.local/bin' ~/.zshrc 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
grep -q 'ai-tools/bin/activate' ~/.zshrc 2>/dev/null || echo 'source ~/ai-tools/bin/activate' >> ~/.zshrc
grep -q 'HEADROOM_BEACON' ~/.zshrc 2>/dev/null || echo 'export HEADROOM_BEACON=off' >> ~/.zshrc

# 6. Приложение Figma
echo "▶ 6/7 Figma"
if [ ! -d /Applications/Figma.app ]; then
  if command -v brew >/dev/null 2>&1; then
    brew install --cask figma || echo "⚠️ Figma не поставилась. Скачайте её с https://www.figma.com/downloads/"
  else
    echo "⚠️ Скачайте Figma с https://www.figma.com/downloads/"
  fi
fi

# 7. Claude Code и подключения к нему
echo "▶ 7/7 Claude Code"
command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
if command -v claude >/dev/null 2>&1; then
  claude mcp add --scope user mempalace -- ~/ai-tools/bin/mempalace-mcp || true
  claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp || true
else
  echo "⚠️ Claude Code не поставился. Потом выполните:"
  echo "  claude mcp add --scope user mempalace -- ~/ai-tools/bin/mempalace-mcp"
  echo "  claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp"
fi

echo ""
echo "✅ Готово! Закройте Терминал и откройте снова."

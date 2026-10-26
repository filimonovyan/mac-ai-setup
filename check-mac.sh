#!/bin/bash
# Проверяет, что всё из набора стоит и работает на Mac.
# Ничего не ставит и не меняет.

[ -f ~/ai-tools/bin/activate ] && source ~/ai-tools/bin/activate
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$PATH"

OK=0; BAD=0
good() { echo "✅ $1"; OK=$((OK+1)); }
bad()  { echo "❌ $1"; echo "   → $2"; BAD=$((BAD+1)); }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "ℹ️  Процессор: $(uname -m)  (x86_64 = Intel, arm64 = Apple M)"
command -v node >/dev/null && good "Node.js $(node -v)" || bad "Node.js" "скачайте с https://nodejs.org"
[ -x ~/ai-tools/bin/python ] && good "Python $(~/ai-tools/bin/python -V | cut -d' ' -f2) в ~/ai-tools" || bad "Python в ~/ai-tools" "запустите install-mac.sh"

# ffmpeg: делает 1 секунду звука
if ffmpeg -y -loglevel error -f lavfi -i "sine=frequency=440:duration=1" "$TMP/t.wav" 2>/dev/null; then
  good "ffmpeg"
else
  bad "ffmpeg" "запустите install-mac.sh"
fi

# whisper: загружает самую маленькую модель
if python3 -c "
from faster_whisper import WhisperModel
m = WhisperModel('tiny', device='cpu', compute_type='int8')
list(m.transcribe('$TMP/t.wav')[0])
" >/dev/null 2>"$TMP/w.err"; then
  good "whisper"
else
  if grep -q metadata_errors "$TMP/w.err"; then
    bad "whisper" "pip install \"av<16\""
  else
    bad "whisper" "запустите install-mac.sh"
  fi
fi

command -v headroom >/dev/null && good "Headroom $(headroom --version 2>/dev/null | awk '{print $NF}')" \
  || bad "Headroom" "запустите install-mac.sh"

command -v mempalace >/dev/null && good "MemPalace" || bad "MemPalace" "запустите install-mac.sh"

# Remotion и Playwright в ~/remotion-app
if [ -d ~/remotion-app/node_modules/remotion ]; then good "Remotion"; else bad "Remotion" "запустите install-mac.sh"; fi
if (cd ~/remotion-app 2>/dev/null && node -e "
const {chromium}=require('playwright');
chromium.launch().then(b=>b.close()).catch(()=>process.exit(1))" 2>/dev/null); then
  good "Playwright"
else
  bad "Playwright" "cd ~/remotion-app && npx playwright install chromium"
fi

[ -d /Applications/Figma.app ] && good "Приложение Figma" || bad "Приложение Figma" "скачайте с https://www.figma.com/downloads/"

# Подключения к Claude Code
if command -v claude >/dev/null; then
  good "Claude Code"
  MCP=$(claude mcp list 2>/dev/null)
  echo "$MCP" | grep -q "^mempalace" && good "MemPalace подключён к Claude" \
    || bad "MemPalace не подключён к Claude" "claude mcp add --scope user mempalace -- ~/ai-tools/bin/mempalace-mcp"
  echo "$MCP" | grep -q "^figma" && good "Figma подключена к Claude" \
    || bad "Figma не подключена к Claude" "claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp"
else
  bad "Claude Code" "поставьте Claude Code: https://claude.com/claude-code"
fi

# Агенты Claude Code
for a in daily-checker researcher mail-calendar writer vk-ads; do
  [ -f ~/.claude/agents/$a.md ] && good "Агент $a" \
    || bad "Агент $a" "bash <(curl -fsSL https://raw.githubusercontent.com/filimonovyan/mac-ai-setup/main/install-agents.sh)"
done

echo ""
echo "Работает: $OK   Не работает: $BAD"

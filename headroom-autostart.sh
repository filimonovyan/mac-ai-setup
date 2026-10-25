#!/bin/bash
# Headroom сам запускается при включении Mac, а Claude ходит через него.
#
#   bash headroom-autostart.sh on      включить
#   bash headroom-autostart.sh off     выключить и вернуть всё как было
#   bash headroom-autostart.sh status  проверить, работает ли

LABEL="com.claude-creator-kit.headroom"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
HEADROOM="$HOME/ai-tools/bin/headroom"
PY="$HOME/ai-tools/bin/python"
LOG="$HOME/Library/Logs/headroom.log"
URL="http://127.0.0.1:8787"

# Записывает или убирает адрес Headroom в настройках Claude
set_claude_url() {
  "$PY" - "$1" <<'EOF'
import json, os, sys
p = os.path.expanduser("~/.claude/settings.json")
os.makedirs(os.path.dirname(p), exist_ok=True)
d = json.load(open(p)) if os.path.exists(p) else {}
env = d.setdefault("env", {})
if sys.argv[1] == "on":
    env["ANTHROPIC_BASE_URL"] = "http://127.0.0.1:8787"
else:
    env.pop("ANTHROPIC_BASE_URL", None)
    if not env:
        d.pop("env")
json.dump(d, open(p, "w"), indent=2)
EOF
}

healthy() { curl -s -m 2 "$URL/health" | grep -q '"healthy"'; }

case "$1" in
  on)
    if [ ! -x "$HEADROOM" ]; then
      echo "❌ Headroom не найден. Сначала запустите install-mac.sh"; exit 1
    fi
    mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
    cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$HEADROOM</string><string>proxy</string><string>--port</string><string>8787</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>HEADROOM_BEACON</key><string>off</string>
    <key>DO_NOT_TRACK</key><string>1</string>
  </dict>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
EOF
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null
    launchctl bootstrap "gui/$(id -u)" "$PLIST"
    echo "▶ Запускаю Headroom..."
    for i in $(seq 1 60); do healthy && break; sleep 1; done
    if healthy; then
      set_claude_url on
      echo "✅ Headroom работает и будет сам запускаться при включении Mac."
      echo "   Полностью закройте приложение Claude (Cmd + Q) и откройте снова."
    else
      launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null
      rm -f "$PLIST"
      echo "❌ Headroom не запустился. Настройки Claude я не трогал."
      echo "   Последние строки отчёта:"; tail -15 "$LOG"
      exit 1
    fi
    ;;
  off)
    set_claude_url off
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null
    rm -f "$PLIST"
    echo "✅ Headroom выключен. Claude снова ходит напрямую."
    echo "   Полностью закройте приложение Claude (Cmd + Q) и откройте снова."
    ;;
  status)
    if healthy; then echo "✅ Headroom работает"; else echo "❌ Headroom не работает"; fi
    grep -q 8787 ~/.claude/settings.json 2>/dev/null \
      && echo "✅ Claude настроен ходить через Headroom" \
      || echo "ℹ️  Claude ходит напрямую, без Headroom"
    ;;
  *)
    echo "Напишите: on (включить), off (выключить) или status (проверить)"
    ;;
esac

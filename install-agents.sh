#!/bin/bash
# Ставит агентов Claude Code в ~/.claude/agents.
# Можно запускать сколько угодно раз: файлы просто обновятся.
set -e
URL="https://raw.githubusercontent.com/filimonovyan/mac-ai-setup/main/.claude/agents"
mkdir -p ~/.claude/agents
for a in daily-checker researcher mail-calendar writer vk-ads; do
  curl -fsSL "$URL/$a.md" -o ~/.claude/agents/$a.md && echo "✅ $a"
done
echo "Готово. Откройте Claude Code и спросите: «Какие у тебя есть агенты?»"

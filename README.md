# Claude Creator Kit 🎬🎙️🎨

**Набор для Claude Code на Mac: видео, речь в текст, дизайн, память и экономия токенов. Ставится одной командой.**

*Claude Code toolkit for macOS: video (Remotion, ffmpeg), speech-to-text (Whisper), design (Figma MCP), memory (MemPalace MCP), token saving (Headroom), browser automation (Playwright). One-command install.*

Для кого: блогеры, дизайнеры, авторы видео, все, кто хочет, чтобы Claude делал больше, чем просто писал текст.

**Что можно делать с этим набором:**
- 🎬 делать видео из кода и монтировать их;
- 🎙️ превращать речь из видео и подкастов в текст и субтитры;
- 🎨 по макету из Figma получать готовый код;
- 🧠 сделать, чтобы Claude помнил ваши заметки;
- 💸 тратить меньше токенов;
- 🌐 автоматически открывать сайты и делать их снимки.

`#ClaudeCode` `#Claude` `#Anthropic` `#MCP` `#AI` `#ИИ` `#нейросети` `#macOS` `#Mac` `#Figma` `#FigmaMCP` `#Remotion` `#Whisper` `#ffmpeg` `#Playwright` `#MemPalace` `#Headroom` `#видео` `#монтаж` `#субтитры` `#транскрибация` `#дизайн` `#автоматизация` `#AIvideo` `#speechtotext` `#designtocode`

## Что внутри

| Программа | Что делает | Зачем нужна |
|---|---|---|
| **ffmpeg** | Режет, склеивает и переделывает видео и звук | Нужна почти всем программам для видео и звука |
| **Playwright** | Сам открывает браузер и нажимает кнопки | Проверять сайты, делать снимки страниц |
| **Remotion** | Делает видео из кода | Ролики с текстом, графиками, анимацией |
| **whisper** (faster-whisper) | Превращает речь в текст | Субтитры, расшифровка записей |
| **Headroom** | Сжимает текст, который уходит к ИИ | Тратить меньше токенов (дешевле) |
| **MemPalace** | Память для ИИ: хранит заметки и ищет в них | Чтобы Claude помнил ваши заметки и прошлую работу |
| **Figma** | Программа для дизайна: макеты сайтов и приложений | Чтобы Claude смотрел ваши макеты и делал по ним код |

## Как поставить всё сразу

Самый простой способ: откройте Терминал и вставьте одну строку:
```
bash <(curl -fsSL https://raw.githubusercontent.com/filimonovyan/mac-ai-setup/main/install-mac.sh)
```

Или скачайте файл и запустите его сами:

1. Скачайте этот репозиторий: зелёная кнопка **Code**, потом **Download ZIP**, потом распакуйте архив.
2. Откройте Терминал: нажмите **Cmd + Пробел**, напишите «Терминал» и нажмите Enter.
3. Напишите `bash ` (с пробелом в конце) и перетащите в окно Терминала файл `install-mac.sh`. Нажмите Enter.
4. Если попросит пароль, введите пароль от Mac. Буквы при этом не видны, так и должно быть.
5. В конце закройте Терминал и откройте его снова.

Установка займёт 10–20 минут.

### Проверить, что всё работает
```
bash <(curl -fsSL https://raw.githubusercontent.com/filimonovyan/mac-ai-setup/main/check-mac.sh)
```
Покажет ✅ или ❌ у каждой программы, а рядом с ❌ подскажет, как исправить. Ничего не ставит и не меняет.

### Что делает `install-mac.sh`

1. Ставит **Homebrew** (магазин программ для Mac), если его ещё нет.
2. Ставит **Node.js**, **Python 3.13** и **ffmpeg**. Python нужен именно 3.13: на нём всё проверено, а на самых новых версиях whisper и MemPalace могут не поставиться.
3. Делает отдельную «коробку» для программ на Python (`~/ai-tools`) и ставит туда whisper, Headroom и MemPalace. Коробка нужна, потому что Mac не даёт ставить такие программы прямо в систему.
4. Ставит Remotion и Playwright в папку `~/remotion-app`.
5. Настраивает Терминал: коробка `~/ai-tools` включается сама, а отправка отчётов в компанию Headroom выключена.
6. Ставит приложение **Figma**, если его ещё нет.
7. Ставит **Claude Code**, если его ещё нет.
8. Подключает к Claude Code MemPalace (память) и Figma.

## Как пользоваться

### whisper: речь в текст
```
python examples/whisper/transcribe.py запись.mp3
```
Модель скачается сама при первом запуске.

### Remotion: видео из кода
```
cd examples/remotion
npm install
npm run studio    # открыть редактор в браузере
npm run render    # сделать видео out/hello.mp4
```

### MemPalace: память для Claude
```
mempalace mine ~/Documents/заметки    # положить заметки в память
claude                                # спросить: «найди в памяти …»
```
Очень короткие заметки, в одну строку, MemPalace может пропустить.

### Figma: макеты для Claude
Один раз надо войти в Figma:
1. Запустите `claude`.
2. Напишите `/mcp`, выберите **figma** и нажмите **Authenticate**.
3. Откроется браузер: войдите в Figma и нажмите «Разрешить».

Потом скопируйте в Figma ссылку на макет (правый клик по рамке → **Copy link**) и скажите Claude: «сделай код по этому макету: <ссылка>».

Подключить Figma можно и на claude.ai: **Настройки → Коннекторы → Figma**.

### Headroom: экономия токенов
```
headroom wrap claude
```
Эта команда запускает Claude Code через Headroom.

## Поставить что-то одно

Сначала Homebrew, если его ещё нет:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

| Что | Команда |
|---|---|
| ffmpeg | `brew install ffmpeg` |
| Python-коробка (нужна для 3 строк ниже) | `brew install python@3.13 && $(brew --prefix python@3.13)/bin/python3.13 -m venv ~/ai-tools` |
| whisper | `~/ai-tools/bin/pip install faster-whisper` |
| Headroom | `~/ai-tools/bin/pip install "headroom-ai[proxy]"` |
| MemPalace | `~/ai-tools/bin/pip install mempalace` |
| MemPalace → Claude | `claude mcp add --scope user mempalace -- ~/ai-tools/bin/mempalace-mcp` |
| Claude Code | `brew install node && npm install -g @anthropic-ai/claude-code` |
| Remotion | `brew install node && npm i remotion @remotion/cli react react-dom` |
| Playwright | `brew install node && npm i playwright && npx playwright install chromium` |
| Figma (приложение) | `brew install --cask figma` |
| Figma → Claude | `claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp` |

## Если что-то не так

- **whisper пишет ошибку про `metadata_errors`**: введите `~/ai-tools/bin/pip install "av<16"`.
- **MemPalace не нашёл заметку**: сделайте её длиннее. Короткие он пропускает.
- **Другая ошибка**: скопируйте её текст и спросите Claude.

## Что проверено

Всё проверено в облачной сессии Claude на Linux: каждая программа поставилась и сработала. Figma проверена через коннектор на claude.ai: Claude увидел аккаунт Figma. Приложение Figma бывает только для Mac и Windows, поэтому его там не ставили. На настоящем Mac файл `install-mac.sh` пока не запускался.

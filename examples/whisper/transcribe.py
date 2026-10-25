"""Превращает речь из аудио или видео в текст.

Запуск:  python transcribe.py запись.mp3
Модель скачается сама при первом запуске.
"""
import sys

from faster_whisper import WhisperModel

if len(sys.argv) < 2:
    sys.exit("Укажите файл: python transcribe.py запись.mp3")

# Размеры модели: tiny, base, small, medium, large-v3.
# Чем больше, тем точнее, но медленнее.
model = WhisperModel("small", device="cpu", compute_type="int8")
segments, info = model.transcribe(sys.argv[1])

print(f"Язык: {info.language}")
for s in segments:
    print(f"[{s.start:6.1f} - {s.end:6.1f}] {s.text.strip()}")

#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/Build/Products/Debug/PrayerTimes.app"
EXEC="$APP/Contents/MacOS/PrayerTimes"

cd "$ROOT"

# Quit running debug instance so the new binary is loaded.
if pgrep -f "$EXEC" >/dev/null 2>&1; then
  pkill -f "$EXEC" || true
  sleep 0.5
fi

xcodebuild -scheme PrayerTimes -destination 'platform=macOS' -derivedDataPath build build

open "$APP"

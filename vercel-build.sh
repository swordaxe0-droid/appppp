#!/usr/bin/env bash
set -euo pipefail
export FLUTTER_HOME="$HOME/flutter"
if [ ! -d "$FLUTTER_HOME" ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"
flutter config --enable-web
flutter --version
flutter pub get

# Some older Flutter builds on CI may not support --web-renderer.
# Detect availability and fall back to default renderer if absent.
if flutter build web -h | grep -q -- '--web-renderer'; then
  echo "Using CanvasKit renderer"
  flutter build web --release --web-renderer canvaskit
else
  echo "Building without explicit web renderer flag"
  flutter build web --release
fi

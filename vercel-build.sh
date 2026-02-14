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
flutter build web --release --web-renderer canvaskit

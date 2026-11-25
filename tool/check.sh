#!/usr/bin/env bash
set -euo pipefail
export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true
flutter pub get
flutter gen-l10n
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
npm ci
npm run test:db

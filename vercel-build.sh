#!/bin/bash
set -e

FLUTTER_VERSION="3.38.7"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo "=== Installing Flutter SDK ${FLUTTER_VERSION} ==="
curl -sL "$FLUTTER_URL" -o flutter.tar.xz
tar xf flutter.tar.xz
export PATH="$PWD/flutter/bin:$PATH"

echo "=== Flutter version ==="
flutter --version

echo "=== Getting dependencies ==="
flutter pub get

echo "=== Building for web ==="
flutter build web --release

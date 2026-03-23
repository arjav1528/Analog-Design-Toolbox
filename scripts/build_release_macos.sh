#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-1.0.0}"

if ! command -v flutter_distributor >/dev/null 2>&1; then
  echo "flutter_distributor not found. Install with: dart pub global activate flutter_distributor"
  exit 1
fi

flutter_distributor package \
  --platform macos \
  --targets dmg \
  --artifact-name "adt-${VERSION}"

echo "Done. DMG available under dist/"

#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
APP="dist/WorldClockMenuBar.app"
if [[ ! -d "$APP" ]]; then
  echo "App bundle not found. Build it first: ./build.sh"
  exit 1
fi
open "$APP"

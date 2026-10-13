#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="WorldClockMenuBar"
BUILD_DIR=".build"
DIST_DIR="dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
BIN_DIR="$APP_BUNDLE/Contents/MacOS"
RES_DIR="$APP_BUNDLE/Contents/Resources"

if ! command -v swiftc >/dev/null 2>&1; then
  echo "ERROR: swiftc was not found. Install Xcode Command Line Tools with:"
  echo "  xcode-select --install"
  exit 1
fi

rm -rf "$BUILD_DIR" "$APP_BUNDLE"
mkdir -p "$BUILD_DIR" "$BIN_DIR" "$RES_DIR"

echo "Compiling Swift sources..."
swiftc -parse-as-library \
  -target "$(uname -m)-apple-macosx13.0" \
  -framework SwiftUI \
  -framework AppKit \
  -framework Foundation \
  WorldClockMenuBar/*.swift \
  -o "$BIN_DIR/$APP_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>WorldClockMenuBar</string>
  <key>CFBundleDisplayName</key><string>WorldClockMenuBar</string>
  <key>CFBundleIdentifier</key><string>com.local.worldclockmenubar</string>
  <key>CFBundleExecutable</key><string>WorldClockMenuBar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

echo "Built: $APP_BUNDLE"
echo "Run it with: open \"$APP_BUNDLE\""

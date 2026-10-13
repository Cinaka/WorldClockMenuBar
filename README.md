# WorldClockMenuBar

A native macOS menu-bar world clock built with SwiftUI. It is designed to show **only the selected city's time in the menu bar**, regardless of the Mac's configured time zone.

## Features

- Menu-bar title shows the selected city and current time, e.g. `Los Angeles 08:30`.
- Click the menu-bar item to see a dropdown list of clocks.
- Each city shows its current time, date, and UTC offset.
- Click any city to select it for the menu bar.
- Automatically uses the IANA time-zone database, including daylight-saving changes.
- Settings window supports adding suggested time zones, removing clocks, reordering, and 12/24-hour time.
- Saves selected city and clock list locally in macOS `UserDefaults`.
- No network access, account, or third-party package is required.

## Requirements

- macOS 13 Ventura or later (uses SwiftUI `MenuBarExtra`).
- Xcode Command Line Tools or full Xcode, including `swift` and `swiftc`.
- Apple Silicon and Intel Macs are supported by Swift; build on the Mac where you will run it.

## Quick start

1. Unzip the archive.
2. Open Terminal and `cd` into the unzipped `WorldClockMenuBar` folder.
3. Run:

   ```bash
   chmod +x build.sh run.sh
   ./build.sh
   ./run.sh
   ```

The build script creates `dist/WorldClockMenuBar.app`. The run script launches it.

## Build an app bundle

```bash
./build.sh
```

To install it into your user Applications folder:

```bash
mkdir -p "$HOME/Applications"
ditto "dist/WorldClockMenuBar.app" "$HOME/Applications/WorldClockMenuBar.app"
open "$HOME/Applications/WorldClockMenuBar.app"
```

## First launch / security

This is a locally built app and is not signed or notarized by an Apple Developer ID. macOS may show a first-launch warning depending on your security settings. Build the source yourself and inspect it; do not disable Gatekeeper globally. If macOS blocks the locally built app, use **System Settings → Privacy & Security** to review the specific app's warning and allow it only if you trust the source you built.

## Notes

- The app displays time in the selected city; it does not change macOS's system time zone.
- All displayed clocks use the Mac's system clock. If the system clock itself is wrong, every clock will be wrong.
- `UTC−07:00` is a date-specific offset, not a permanent rule for Los Angeles. The app calculates the offset for the current date, so it changes automatically when daylight-saving time changes.
- The app's menu-bar label is intentionally limited to city and time. If the label is too long for your menu bar, choose a shorter display name in Settings.

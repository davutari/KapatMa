<p align="center">
  <img src="screenshots/active-session.png" width="380" alt="Kapat.ma Active Session">
</p>

<h1 align="center">Kapat.ma</h1>

<p align="center">
  <strong>Keep your Mac awake. Control your display.</strong><br>
  A lightweight macOS menu bar app that prevents screen sleep and controls external monitor brightness.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-black?style=flat-square&logo=apple&logoColor=white" alt="macOS 13+">
  <img src="https://img.shields.io/badge/Swift-5.0-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5">
  <img src="https://img.shields.io/badge/SwiftUI-blue?style=flat-square&logo=swift&logoColor=white" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">
</p>

---

## Screenshots

<p align="center">
  <img src="screenshots/main-view.png" width="320" alt="Main View">
  &nbsp;&nbsp;
  <img src="screenshots/settings-view.png" width="320" alt="Settings">
  &nbsp;&nbsp;
  <img src="screenshots/active-session.png" width="320" alt="Active Session">
</p>

<p align="center">
  <em>Main View &bull; Settings & Themes &bull; Active Session with Countdown</em>
</p>

---

## Features

### Menu Bar Integration
- Lives in your menu bar with a clean lock icon
- **Locked** when inactive, **Unlocked + countdown** when active
- Zero dock clutter &mdash; no dock icon, no windows

### External Monitor Brightness Control
- Automatically detects connected external monitors
- Per-display brightness slider with real-time adjustment
- **DDC/CI** hardware control for supported monitors (HDMI / DisplayPort)
- **Gamma overlay** fallback for monitors without DDC support
- Auto-hides when no external monitor is connected
- Polls every 5 seconds for hotplug detection

### 5 Built-in Profiles

| Profile | Duration | Use Case |
|---------|----------|----------|
| Toplantı | 1 hour | Quick calls & meetings |
| Derin Çalışma | 4 hours | Focused coding sessions |
| Uzun Hesaplama | 8 hours | Builds, renders, ML training |
| Gece Boyu | 12 hours | Long-running overnight tasks |
| Sınırsız | Infinite | Until you say stop |

### Quick Start Presets
One-click duration buttons: **30dk, 1sa, 2sa, 4sa, 8sa, 12sa**

### Custom Duration
Slider-based picker from **30 minutes to 24 hours** with half-hour steps.

### Theme System
- **3 Modes:** System (auto), Light, Dark
- **6 Color Palettes:** Espresso, Ocean, Sunset, Forest, Lavender, Cherry
- All UI elements adapt to the selected theme
- Automatically follows macOS appearance

### Motivational Quotes
- Rotating quotes every 10 seconds
- 12 built-in quotes (Turkish & English)
- Add your own custom quotes
- Tap to skip to the next quote

### Smart Notifications
- **5-minute warning** before session ends
- **Completion notification** when time is up

### Session Stats
- Daily session count
- Total active minutes today
- Resets automatically each day

### Keyboard Shortcut
Toggle the popover from anywhere with **`Cmd + Shift + K`**

---

## How It Works

Kapat.ma uses the native macOS `caffeinate` command to prevent your Mac from sleeping. For external monitor brightness, it communicates over **DDC/CI** (Display Data Channel) via IOKit's I2C interface to send hardware brightness commands. On monitors that don't support DDC, it falls back to **CoreGraphics gamma table** manipulation for software-level brightness control.

---

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 15.0+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/davutari/KapatMa.git
   ```

2. Open the project in Xcode:
   ```bash
   cd KapatMa
   open KapatMa.xcodeproj
   ```

3. Build and run with **`Cmd + R`**

4. Look for the lock icon in your menu bar

> **Note:** App Sandbox is disabled for `caffeinate` and IOKit I2C access to work. This is already configured in the project settings.

---

## Project Structure

```
KapatMa/
├── KapatMaApp.swift              # App entry point + menu bar setup
├── CaffeineManager.swift         # caffeinate process management
├── BrightnessManager.swift       # External display brightness control
├── DDCHelper.h                   # DDC/CI C API header
├── DDCHelper.c                   # IOKit I2C DDC/CI implementation
├── KapatMa-Bridging-Header.h     # C → Swift bridge
├── QuotesManager.swift           # Motivational quotes engine
├── ThemeManager.swift            # Theme & color palette system
├── MainPopoverView.swift         # All UI views (main, settings, quotes editor)
├── Info.plist                    # App configuration (LSUIElement = true)
├── KapatMa.entitlements          # Sandbox disabled
└── Assets.xcassets/              # App icons & colors
```

---

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| **SwiftUI** | User interface |
| **AppKit** | Menu bar integration (NSStatusItem, NSPopover) |
| **caffeinate** | Native macOS sleep prevention |
| **IOKit / I2C** | DDC/CI hardware brightness control |
| **CoreGraphics** | Gamma-based software brightness fallback |
| **UserDefaults** | Settings & stats persistence |
| **UNUserNotificationCenter** | Timer notifications |

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with <strong>Swift</strong> on macOS
</p>

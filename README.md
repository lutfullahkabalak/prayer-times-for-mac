<div align="center">

<img src="docs/screenshots/app-icon.png" width="120" alt="Prayer Times app icon" />

# Prayer Times

**A native macOS menu bar app for Islamic prayer times, using official Diyanet data.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 languages](https://img.shields.io/badge/languages-14-34C759)

<img src="docs/screenshots/menubar.png" width="620" alt="Prayer Times in the macOS menu bar" />

</div>

<div align="center">

**English** ·
[Türkçe](docs/README.tr.md) ·
[العربية](docs/README.ar.md) ·
[فارسی](docs/README.fa.md) ·
[اردو](docs/README.ur.md) ·
[Bahasa Indonesia](docs/README.id.md) ·
[Bahasa Melayu](docs/README.ms.md) ·
[Bosanski](docs/README.bs.md) ·
[Shqip](docs/README.sq.md) ·
[Azərbaycan](docs/README.az.md) ·
[Deutsch](docs/README.de.md) ·
[Français](docs/README.fr.md) ·
[Nederlands](docs/README.nl.md) ·
[Русский](docs/README.ru.md)

</div>

---

## Overview

Prayer Times lives in your menu bar and always shows the prayer you are currently in, together with a live countdown until it ends. Clicking the menu bar item opens a panel with all six daily times for your location, rendered as sky-themed cards that change with the time of day.

## Screenshots

### Panel views

Four layouts are available, switchable in Settings.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="docs/screenshots/panel-cards.png" width="330" alt="Cards view" /><br />
      <b>Cards</b> — full-width sky cards
    </td>
    <td align="center" width="50%">
      <img src="docs/screenshots/panel-grid.png" width="330" alt="Sky view" /><br />
      <b>Sky</b> — 3×2 illustrated grid
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="docs/screenshots/panel-list.png" width="270" alt="List view" /><br />
      <b>List</b> — compact rows with icons
    </td>
    <td align="center">
      <img src="docs/screenshots/panel-tiles.png" width="330" alt="Boxes view" /><br />
      <b>Boxes</b> — single tight row
    </td>
  </tr>
</table>

### Settings

<table>
  <tr>
    <td align="center" width="50%">
      <img src="docs/screenshots/settings.png" width="300" alt="Location and notification settings" /><br />
      Location and per-prayer notifications
    </td>
    <td align="center" width="50%">
      <img src="docs/screenshots/settings-general.png" width="300" alt="General settings" /><br />
      View style, menu bar and language
    </td>
  </tr>
</table>

### Right-to-left languages

<div align="center">
  <img src="docs/screenshots/panel-rtl.png" width="330" alt="Arabic interface with right-to-left layout" />
</div>

Arabic, Persian and Urdu flip the whole interface to right-to-left.

## Features

- **Menu bar at a glance** — current prayer name and countdown until it ends, updated every second
- **Configurable menu bar** — choose the icon (prayer icon, app icon or none), show or hide the prayer name, and display the remaining time, the next prayer time or nothing at all
- **Four panel layouts** — Cards, List, Boxes and Sky
- **Location** — automatic detection via CoreLocation, or manual country / province / district selection
- **Per-prayer notifications** — enable each prayer separately, notify at the exact time and/or 5–60 minutes before
- **Works offline** — a full month of times is cached in Application Support
- **Hijri date** in the panel header
- **Launch at login**
- **14 languages** with full right-to-left support

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 15 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen) to build from source

## Build from source

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Then build and run the `PrayerTimes` scheme. From the command line:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Tests

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## How it works

The app is an `LSUIElement` agent app, so it has no Dock icon and no window. The menu bar label is an `NSStatusItem` drawn with AppKit, and the panel is an `NSPopover` hosting a SwiftUI view. The active prayer is the period you are currently in — not the next one — so the countdown tells you how much time is left in that period. Between midnight and Imsak the app still shows Isha.

Times are fetched a month at a time and stored as JSON in `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes`, so the app keeps working without a network connection.

## Languages

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

The language follows your system setting by default and can be overridden in Settings → General.

## Data source

Prayer times come from the [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com), which serves the official times published by **Diyanet İşleri Başkanlığı** (Presidency of Religious Affairs of Türkiye).

# Prayer Times — Project Context

## Overview
Native macOS menu bar app showing current prayer time and countdown. Tap opens a panel with 6 prayer times in one of three views: sky-themed cards (default), plain list, or 3×2 sky grid.

## Tech Stack
- Swift 6, SwiftUI panel + AppKit NSStatusItem (menu bar label)
- Target: macOS 14+
- Build: XcodeGen (`project.yml`)
- Data: ezanvakti.imsakiyem.com (Diyanet official times)
- Cache: Application Support JSON (31-day monthly fetch)

## Key Decisions
- Active prayer = current period (not next); countdown = time until period ends
- Midnight–Imsak = still Isha (yesterday's Yatsi boundary)
- District API: use `?stateId=` only (not `countryId&stateId`)
- Menu bar label via NSStatusItem (AppKit); updates every second with prayer name + countdown
- Menu bar display configurable: icon (none / prayer / app mono / app color), prayer name toggle, time (remaining / next prayer time / none); all-off falls back to prayer icon; app icon options use `Mosque` asset (`mosque.png`)
- Panel via `NSPopover` (transient, animates) + NSHostingController; native system arrow; `windowBackgroundColor` (matches Settings)
- Popover size synced from SwiftUI via `MenuBarController.syncPopoverSize()` (`preferredContentSize`); called on open and when view style/settings changes — not a fixed 580×380
- Settings auto-save on change (no Save button); Back button returns to main panel
- `showSettings` lives in `PanelLayout.shared`; reset in `popoverDidClose` so reopen shows prayer times
- Esc via SwiftUI `.onExitCommand` (settings → back, main → close); key window via `makeKey()` after show
- Popover closes on outside-app clicks (global mouse monitor) so other menu-bar menus dismiss it
- Settings use adaptive `windowBackgroundColor` surface, `.primary` text, accent-tinted switch toggles
- Header dates use `L10n.effectiveLanguageCode` locale, not system locale
- First launch: seed `SavedLocation.istanbul`, load times, then request location permission and upgrade if resolved
- Location auth waits on `locationManagerDidChangeAuthorization` (no fixed sleep)
- `State` model renamed to `Province` to avoid SwiftUI `@State` conflict
- Prayer cards use a fixed three-column layout: name left, countdown center (active only), time right
- Card text color (`textInk` / `textShadow`) derived from `SkyPalette` average sky luminance (WCAG 4.5:1 threshold), not fixed white
- Dhuhr, Sunrise (Güneş), and Asr (İkindi) use forced white text with dark shadow; other cards follow palette luminance
- Settings header uses ZStack for true title centering; Form inset aligned with main panel padding
- Location detect applies immediately and shows readable `fullDisplayName` card
- 14 languages via embedded L10n tables; manual language override in Settings (System + 14 langs)
- RTL for ar/fa/ur based on selected language
- Panel view style selectable in Settings > General: Cards, List, Tiles (single tight horizontal row with dividers), Grid/Sky (3×2 SkyScene)
- Panel width by view: list 300pt, others 420pt; height: tiles ~170pt, list ~300pt, cards 500pt, grid 360pt, settings 580pt
- `PanelViewStyle` stored in UserDefaults (`panelViewStyle`); `PanelLayout.viewStyle` for live UI updates

## Structure
```
Sources/PrayerTimes/
  Models/     Prayer, PrayerTimeCalculator, LocationModels, PanelViewStyle, MenuBarDisplayStyle
  Services/   DiyanetAPI, PrayerStore, PrayerCache, LocationResolver,
              CountryNameMapper, NotificationService, LaunchAtLogin,
              AppCoordinator, MenuBarController, PanelLayout, RTLHelper
  Views/      MenuBarLabel, PanelView (incl. SettingsView, PrayerCard),
              PrayerStyleViews (PrayerListRow, PrayerSimpleTile, PrayerGridCell)
  Art/        SkyScene (SkyPalette, Skyline, Canvas scenes)
Resources/    CountryAliases.json (ISO + English → Diyanet country names)
Tests/PrayerTimesTests/  API decode + active prayer logic tests
docs/         README.<lang>.md (13 translations) + screenshots/
```

## Build & Run
```bash
xcodegen generate
open PrayerTimes.xcodeproj
# Scheme: PrayerTimes
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build test
```

**Agent workflow:** After meaningful code changes, rebuild and relaunch without being asked:
```bash
./scripts/restart-app.sh
```
Script kills the running debug instance first, then builds and opens (plain `open` does not reload an already-running app).

## Docs
- `README.md` (English) at root; 13 translations in `docs/README.<lang>.md`, one per supported language
- Language nav bar at the top of every README; root uses `docs/screenshots/…`, translations use `screenshots/…`
- Screenshots in `docs/screenshots/`: `menubar`, `panel-cards`, `panel-list`, `panel-tiles`, `panel-grid`,
  `panel-rtl` (Arabic), `settings`, `settings-general`, `app-icon`
- Captured in English (except `panel-rtl`) by scripting the status item click and `screencapture -l <windowID>`;
  a `kCGEventMouseMoved` hover event is required before a synthetic click lands on popover controls

## Status (2026-08-02)
- Build: succeeds
- Tests: 11 passing
- Panel UX: NSPopover with `syncPopoverSize()`; four view styles; per-style width/height; compact list/tiles without vertical stretch
- Settings: adaptive surface, clear toggles, panel resets to prayer view on close; Esc backs out of settings then closes popover
- First launch: Istanbul default then automatic location prompt
- Features: menu bar label, 3 panel view styles, Diyanet API + cache, location auto/manual,
  per-prayer notifications, launch at login, hijri date, 14-language localization
- Notifications: master toggle + per-prayer prefs (`PrayerNotificationPreference`: enabled,
  notifyAtTime, preAlertEnabled, preAlertMinutes 5…60); includes Sunrise via `notifiablePrayers`.
  Stored as JSON in UserDefaults (`notificationPreferences`); migrates legacy global `preAlertMinutes`.
  `UNTimeIntervalNotificationTrigger` (exact fire); `.timeSensitive`; title = prayer name

## Known Issues / Investigation
- 2026-08-02: Fixed country match failure (`Turkey` vs `TÜRKİYE`) via `Resources/CountryAliases.json` + `CountryNameMapper` (ISO code first, then English aliases, then fuzzy `name`/`nameEn`). Covers ~200 ISO codes and common English aliases for Diyanet Turkish country names.

## Recent Changes
- 2026-08-02: GitHub README with screenshots + 13 translated READMEs in `docs/`; repo pushed to
  `github.com/lutfullahkabalak/prayer-times-for-mac`
- 2026-08-02: Menu bar app icon options use `Resources/Assets.xcassets/Mosque.imageset` (`mosque.png`) instead of dock AppIcon
- 2026-08-02: Menu bar display config — Settings > General: icon source (none/prayer/app mono/app color), show prayer name toggle, time display (remaining/next time/none); defaults preserve prior behavior
- 2026-08-02: Popover size fix — `syncPopoverSize()` from hosting `preferredContentSize`; list 300pt wide; tiles ~170pt tall; compact views no longer stretch vertically
- 2026-08-02: Panel view styles — Cards, List, Tiles (horizontal row), Grid/Sky; segmented picker in Settings > General
- 2026-08-02: Country geocode→Diyanet mapping (`CountryAliases.json`, ISO + English aliases); LocationResolver uses CountryNameMapper
- 2026-08-02: Include Sunrise (Güneş) in notifiable prayers / notification settings
- 2026-08-02: Notification prefs UI as horizontal rows (prayer name + side-by-side toggles/minutes); panel width 420
- 2026-08-02: Per-prayer notification settings (enable, at-time, pre-alert minutes per prayer)
- 2026-08-02: Close popover when another menu-bar item is clicked (global mouse monitor)
- 2026-08-02: Set App Icon — gradient mosque/crescent outline on black; all macOS sizes in `Resources/Assets.xcassets/AppIcon.appiconset`; Assets.xcassets + Localizable.xcstrings via sources `buildPhase: resources` (actool → AppIcon.icns)
- 2026-08-02: Explored original App Icon concepts (visual): crescent+sun+prayer dots; 6-band sky timeline + mihrab arch; twilight prayer-clock needle; Maghrib horizon crescent with pulse rings
- 2026-08-02: Unified panel/settings background to `windowBackgroundColor`
- 2026-08-02: Aligned menu open/close with Volume Control — NSPopover (animates, transient, native arrow, Esc via onExitCommand)
- 2026-08-02: Fixed late prayer notifications; restructured notification copy across all 14 languages

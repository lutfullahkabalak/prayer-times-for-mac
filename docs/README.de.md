<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Prayer Times App-Symbol" />

# Prayer Times

**Native macOS-Menüleisten-App für islamische Gebetszeiten – mit offiziellen Daten der Diyanet.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 Sprachen](https://img.shields.io/badge/Sprachen-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="Prayer Times in der macOS-Menüleiste" />

</div>

<div align="center">

[English](../README.md) ·
[Türkçe](README.tr.md) ·
[العربية](README.ar.md) ·
[فارسی](README.fa.md) ·
[اردو](README.ur.md) ·
[Bahasa Indonesia](README.id.md) ·
[Bahasa Melayu](README.ms.md) ·
[Bosanski](README.bs.md) ·
[Shqip](README.sq.md) ·
[Azərbaycan](README.az.md) ·
**Deutsch** ·
[Français](README.fr.md) ·
[Nederlands](README.nl.md) ·
[Русский](README.ru.md)

</div>

---

## Überblick

Prayer Times sitzt in der Menüleiste und zeigt immer das Gebet an, in dessen Zeitraum Sie sich gerade befinden – zusammen mit einem laufenden Countdown bis zu dessen Ende. Ein Klick auf das Menüleisten-Symbol öffnet ein Panel mit allen sechs Tageszeiten für Ihren Standort, dargestellt als Karten mit einem Himmel, der sich mit der Tageszeit verändert.

## Screenshots

### Panel-Ansichten

Vier Layouts stehen zur Verfügung und lassen sich in den Einstellungen wechseln.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="Kartenansicht" /><br />
      <b>Karten</b> — Himmelskarten über die volle Breite
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="Himmelsansicht" /><br />
      <b>Himmel</b> — illustriertes 3×2-Raster
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="Listenansicht" /><br />
      <b>Liste</b> — kompakte Zeilen mit Symbolen
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="Kästchenansicht" /><br />
      <b>Kästchen</b> — eine einzige kompakte Zeile
    </td>
  </tr>
</table>

### Einstellungen

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="Standort- und Benachrichtigungseinstellungen" /><br />
      Standort und Benachrichtigungen pro Gebet
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="Allgemeine Einstellungen" /><br />
      Ansicht, Menüleiste und Sprache
    </td>
  </tr>
</table>

### Sprachen von rechts nach links

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="Arabische Oberfläche mit Rechts-nach-links-Layout" />
</div>

Arabisch, Persisch und Urdu spiegeln die gesamte Oberfläche nach rechts-nach-links.

## Funktionen

- **Auf einen Blick in der Menüleiste** — Name des aktuellen Gebets und Countdown bis zu dessen Ende, sekündlich aktualisiert
- **Konfigurierbare Menüleiste** — Symbol wählen (Gebetssymbol, App-Symbol oder keines), Gebetsnamen ein- oder ausblenden und wahlweise Restzeit, nächste Gebetszeit oder gar nichts anzeigen
- **Vier Panel-Layouts** — Karten, Liste, Kästchen und Himmel
- **Standort** — automatische Erkennung über CoreLocation oder manuelle Auswahl von Land / Provinz / Bezirk
- **Benachrichtigungen pro Gebet** — jedes Gebet einzeln aktivieren, pünktlich zur Zeit und/oder 5–60 Minuten vorher benachrichtigen
- **Funktioniert offline** — ein ganzer Monat wird im Application Support zwischengespeichert
- **Hidschri-Datum** in der Panel-Kopfzeile
- **Beim Anmelden starten**
- **14 Sprachen** mit vollständiger Rechts-nach-links-Unterstützung

## Voraussetzungen

- macOS 14 (Sonoma) oder neuer
- Xcode 15 oder neuer und [XcodeGen](https://github.com/yonaskolb/XcodeGen), um aus dem Quellcode zu bauen

## Aus dem Quellcode bauen

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Anschließend das Schema `PrayerTimes` bauen und starten. Über die Kommandozeile:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Tests

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## Funktionsweise

Die App ist eine `LSUIElement`-Agent-App, hat also weder ein Dock-Symbol noch ein Fenster. Die Menüleisten-Beschriftung ist ein mit AppKit gezeichnetes `NSStatusItem`, das Panel ein `NSPopover` mit einer SwiftUI-Ansicht. Das aktive Gebet ist der Zeitraum, in dem Sie sich **gerade befinden** – nicht der nächste. Der Countdown zeigt also, wie viel von diesem Zeitraum noch übrig ist. Zwischen Mitternacht und Imsak zeigt die App weiterhin Isha an.

Die Zeiten werden monatsweise geladen und als JSON unter `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes` gespeichert, sodass die App auch ohne Netzverbindung funktioniert.

## Sprachen

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

Die Sprache folgt standardmäßig der Systemeinstellung und lässt sich unter Einstellungen → Allgemein ändern.

## Datenquelle

Die Gebetszeiten stammen von der [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com), die die offiziellen Zeiten der **Diyanet İşleri Başkanlığı** (Präsidium für Religionsangelegenheiten der Türkei) bereitstellt.

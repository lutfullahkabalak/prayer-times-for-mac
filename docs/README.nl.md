<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Prayer Times app-symbool" />

# Prayer Times

**Native macOS-menubalk-app voor islamitische gebedstijden, op basis van officiële Diyanet-gegevens.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 talen](https://img.shields.io/badge/talen-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="Prayer Times in de macOS-menubalk" />

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
[Deutsch](README.de.md) ·
[Français](README.fr.md) ·
**Nederlands** ·
[Русский](README.ru.md)

</div>

---

## Overzicht

Prayer Times staat in je menubalk en toont altijd het gebed waarvan de tijd nu loopt, met een aftelling tot het einde ervan. Klik op het item in de menubalk en er verschijnt een paneel met alle zes dagelijkse tijden voor je locatie, weergegeven als kaarten met een lucht die verandert met het uur van de dag.

## Schermafbeeldingen

### Paneelweergaven

Er zijn vier indelingen beschikbaar, te wisselen in Instellingen.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="Kaartenweergave" /><br />
      <b>Kaarten</b> — luchtkaarten over de volle breedte
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="Luchtweergave" /><br />
      <b>Lucht</b> — geïllustreerd 3×2-raster
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="Lijstweergave" /><br />
      <b>Lijst</b> — compacte rijen met symbolen
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="Vakjesweergave" /><br />
      <b>Vakjes</b> — één compacte rij
    </td>
  </tr>
</table>

### Instellingen

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="Locatie- en meldingsinstellingen" /><br />
      Locatie en meldingen per gebed
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="Algemene instellingen" /><br />
      Weergavestijl, menubalk en taal
    </td>
  </tr>
</table>

### Talen van rechts naar links

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="Arabische interface met indeling van rechts naar links" />
</div>

Arabisch, Perzisch en Urdu draaien de hele interface om naar rechts-naar-links.

## Functies

- **In één oogopslag in de menubalk** — naam van het huidige gebed en de resterende tijd tot het einde ervan, elke seconde bijgewerkt
- **Instelbare menubalk** — kies het symbool (gebedssymbool, app-symbool of geen), toon of verberg de gebedsnaam en laat de resterende tijd, de volgende gebedstijd of niets zien
- **Vier paneelindelingen** — Kaarten, Lijst, Vakjes en Lucht
- **Locatie** — automatische detectie via CoreLocation, of handmatig land / provincie / district kiezen
- **Meldingen per gebed** — zet elk gebed apart aan, met een melding precies op tijd en/of 5–60 minuten van tevoren
- **Werkt offline** — een volledige maand aan tijden wordt bewaard in Application Support
- **Hidjri-datum** in de paneelkop
- **Starten bij inloggen**
- **14 talen** met volledige ondersteuning voor rechts-naar-links

## Vereisten

- macOS 14 (Sonoma) of nieuwer
- Xcode 15 of nieuwer en [XcodeGen](https://github.com/yonaskolb/XcodeGen) om vanaf de broncode te bouwen

## Bouwen vanaf de broncode

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Bouw en start vervolgens het schema `PrayerTimes`. Vanaf de opdrachtregel:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Tests

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## Hoe het werkt

De app is een `LSUIElement`-agent en heeft dus geen Dock-symbool en geen venster. Het label in de menubalk is een met AppKit getekend `NSStatusItem` en het paneel is een `NSPopover` met een SwiftUI-weergave. Het actieve gebed is de periode waarin je je **nu bevindt**, niet de volgende, dus de aftelling laat zien hoeveel tijd er nog rest in die periode. Tussen middernacht en imsak toont de app nog steeds isha.

De tijden worden per maand opgehaald en als JSON opgeslagen in `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes`, zodat de app blijft werken zonder netwerkverbinding.

## Talen

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

De taal volgt standaard je systeeminstelling en kan worden aangepast via Instellingen → Algemeen.

## Gegevensbron

De gebedstijden komen van de [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com), die de officiële tijden van de **Diyanet İşleri Başkanlığı** (Presidium voor Religieuze Zaken van Turkije) publiceert.

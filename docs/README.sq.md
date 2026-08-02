<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Ikona e aplikacionit Prayer Times" />

# Prayer Times

**Aplikacion nativ për shiritin e menysë së macOS që tregon kohët e namazit sipas të dhënave zyrtare të Dijanetit.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 gjuhë](https://img.shields.io/badge/gjuh%C3%AB-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="Prayer Times në shiritin e menysë së macOS" />

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
**Shqip** ·
[Azərbaycan](README.az.md) ·
[Deutsch](README.de.md) ·
[Français](README.fr.md) ·
[Nederlands](README.nl.md) ·
[Русский](README.ru.md)

</div>

---

## Përmbledhje

Prayer Times qëndron në shiritin e menysë dhe tregon gjithmonë namazin në kohën e të cilit ndodheni, bashkë me numërimin mbrapsht deri në mbarimin e asaj kohe. Me një klikim mbi të hapet një panel me të gjashtë kohët e ditës për vendndodhjen tuaj, të paraqitura si karta me qiell që ndryshon sipas orës së ditës.

## Pamje nga ekrani

### Pamjet e panelit

Janë të disponueshme katër paraqitje, të ndërrueshme te Cilësimet.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="Pamja me karta" /><br />
      <b>Karta</b> — karta qielli në tërë gjerësinë
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="Pamja e qiellit" /><br />
      <b>Qielli</b> — rrjetë e ilustruar 3×2
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="Pamja e listës" /><br />
      <b>Lista</b> — rreshta kompaktë me ikona
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="Pamja me kuti" /><br />
      <b>Kutitë</b> — një rresht i vetëm kompakt
    </td>
  </tr>
</table>

### Cilësimet

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="Cilësimet e vendndodhjes dhe njoftimeve" /><br />
      Vendndodhja dhe njoftimet për çdo namaz
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="Cilësimet e përgjithshme" /><br />
      Stili i pamjes, shiriti i menysë dhe gjuha
    </td>
  </tr>
</table>

### Gjuhët nga e djathta në të majtë

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="Ndërfaqja në arabisht me paraqitje nga e djathta në të majtë" />
</div>

Arabishtja, persishtja dhe urduja e kthejnë tërë ndërfaqen nga e djathta në të majtë.

## Veçoritë

- **Një vështrim te shiriti i menysë** — emri i namazit aktual dhe koha e mbetur deri në mbarimin e tij, e përditësuar çdo sekondë
- **Shirit menyje i konfigurueshëm** — zgjidhni ikonën (ikona e namazit, ikona e aplikacionit ose asnjë), shfaqni ose fshihni emrin e namazit dhe shfaqni kohën e mbetur, orën e namazit të radhës ose asgjë
- **Katër paraqitje paneli** — Karta, Listë, Kuti dhe Qiell
- **Vendndodhja** — zbulim automatik me CoreLocation ose zgjedhje manuale e shtetit / qarkut / rrethit
- **Njoftime për çdo namaz** — aktivizoni secilin namaz veç e veç, me njoftim pikërisht në kohë dhe/ose 5–60 minuta para
- **Punon pa internet** — kohët e një muaji të plotë ruhen në Application Support
- **Data hixhrie** në krye të panelit
- **Nisje në hyrje**
- **14 gjuhë** me mbështetje të plotë nga e djathta në të majtë

## Kërkesat

- macOS 14 (Sonoma) ose më i ri
- Xcode 15 ose më i ri dhe [XcodeGen](https://github.com/yonaskolb/XcodeGen) për ndërtim nga burimi

## Ndërtimi nga burimi

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Pastaj ndërtoni dhe nisni skemën `PrayerTimes`. Nga rreshti i komandës:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Testet

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## Si funksionon

Aplikacioni është agjent `LSUIElement`, prandaj nuk ka ikonë në Dock dhe as dritare. Etiketa në shiritin e menysë është një `NSStatusItem` i vizatuar me AppKit, ndërsa paneli është një `NSPopover` që përmban një pamje SwiftUI. Namazi aktiv është periudha në të cilën **ndodheni tani**, jo ai i radhës, prandaj numërimi mbrapsht tregon sa kohë ka mbetur nga ajo periudhë. Midis mesnatës dhe imsakut aplikacioni vazhdon të shfaqë jacinë.

Kohët merren muaj pas muaji dhe ruhen si JSON te `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes`, kështu që aplikacioni punon edhe pa lidhje interneti.

## Gjuhët

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

Gjuha ndjek si parazgjedhje cilësimin e sistemit dhe mund të ndryshohet te Cilësimet → Të përgjithshme.

## Burimi i të dhënave

Kohët e namazit vijnë nga [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com), i cili publikon kohët zyrtare të **Diyanet İşleri Başkanlığı** (Presidenca e Çështjeve Fetare e Turqisë).

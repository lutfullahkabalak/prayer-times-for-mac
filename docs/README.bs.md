<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Ikona aplikacije Prayer Times" />

# Prayer Times

**Nativna macOS aplikacija u traci izbornika za namaska vremena, sa zvaničnim podacima Dijaneta.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 jezika](https://img.shields.io/badge/jezika-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="Prayer Times u macOS traci izbornika" />

</div>

<div align="center">

[English](../README.md) ·
[Türkçe](README.tr.md) ·
[العربية](README.ar.md) ·
[فارسی](README.fa.md) ·
[اردو](README.ur.md) ·
[Bahasa Indonesia](README.id.md) ·
[Bahasa Melayu](README.ms.md) ·
**Bosanski** ·
[Shqip](README.sq.md) ·
[Azərbaycan](README.az.md) ·
[Deutsch](README.de.md) ·
[Français](README.fr.md) ·
[Nederlands](README.nl.md) ·
[Русский](README.ru.md)

</div>

---

## Pregled

Prayer Times stoji u traci izbornika i uvijek pokazuje namaz u čijem se vaktu trenutno nalazite, zajedno sa odbrojavanjem do njegovog isteka. Klikom na stavku u traci otvara se panel sa svih šest dnevnih vremena za vašu lokaciju, prikazanih kao kartice sa nebom koje se mijenja ovisno o dobu dana.

## Snimci ekrana

### Prikazi panela

Dostupna su četiri rasporeda koja se biraju u Postavkama.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="Prikaz kartica" /><br />
      <b>Kartice</b> — kartice neba pune širine
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="Prikaz neba" /><br />
      <b>Nebo</b> — ilustrovana mreža 3×2
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="Prikaz liste" /><br />
      <b>Lista</b> — kompaktni redovi sa ikonama
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="Prikaz kutija" /><br />
      <b>Kutije</b> — jedan zbijeni red
    </td>
  </tr>
</table>

### Postavke

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="Postavke lokacije i obavještenja" /><br />
      Lokacija i obavještenja po namazu
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="Opšte postavke" /><br />
      Stil prikaza, traka izbornika i jezik
    </td>
  </tr>
</table>

### Jezici zdesna nalijevo

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="Arapski interfejs sa rasporedom zdesna nalijevo" />
</div>

Arapski, perzijski i urdu okreću cijeli interfejs zdesna nalijevo.

## Mogućnosti

- **Sve na jednom pogledu u traci** — naziv trenutnog namaza i odbrojavanje do isteka vakta, osvježeno svake sekunde
- **Podesiva traka izbornika** — odaberite ikonu (ikona namaza, ikona aplikacije ili bez nje), prikažite ili sakrijte naziv namaza i prikažite preostalo vrijeme, vrijeme narednog namaza ili ništa
- **Četiri rasporeda panela** — Kartice, Lista, Kutije i Nebo
- **Lokacija** — automatsko određivanje putem CoreLocationa ili ručni izbor države / regije / općine
- **Obavještenja po namazu** — uključite svaki namaz zasebno, uz obavještenje tačno u vaktu i/ili 5–60 minuta ranije
- **Radi offline** — vremena za cijeli mjesec čuvaju se u Application Supportu
- **Hidžretski datum** u zaglavlju panela
- **Pokretanje pri prijavi**
- **14 jezika** uz punu podršku za pisanje zdesna nalijevo

## Zahtjevi

- macOS 14 (Sonoma) ili noviji
- Xcode 15 ili noviji i [XcodeGen](https://github.com/yonaskolb/XcodeGen) za build iz izvornog koda

## Build iz izvornog koda

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Zatim izgradite i pokrenite shemu `PrayerTimes`. Iz komandne linije:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Testovi

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## Kako radi

Aplikacija je `LSUIElement` agent, pa nema ikonu u Docku ni prozor. Oznaka u traci izbornika je `NSStatusItem` iscrtan pomoću AppKita, a panel je `NSPopover` koji sadrži SwiftUI prikaz. Aktivan namaz je period u kojem se **trenutno nalazite**, a ne naredni, pa odbrojavanje pokazuje koliko je vremena ostalo do kraja tog perioda. Između ponoći i imsaka aplikacija i dalje prikazuje jaciju.

Vremena se preuzimaju na mjesečnom nivou i čuvaju kao JSON u `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes`, tako da aplikacija radi i bez internetske veze.

## Jezici

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

Jezik podrazumijevano prati sistemsku postavku, a može se promijeniti u Postavke → Opšte.

## Izvor podataka

Namaska vremena dolaze sa [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com), koji objavljuje zvanična vremena **Diyanet İşleri Başkanlığı** (Uprava za vjerska pitanja Turske).

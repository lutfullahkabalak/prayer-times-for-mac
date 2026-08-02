<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Ikon aplikasi Prayer Times" />

# Prayer Times

**Aplikasi bar menu macOS asli untuk waktu solat, menggunakan data rasmi Diyanet.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 bahasa](https://img.shields.io/badge/bahasa-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="Prayer Times pada bar menu macOS" />

</div>

<div align="center">

[English](../README.md) ·
[Türkçe](README.tr.md) ·
[العربية](README.ar.md) ·
[فارسی](README.fa.md) ·
[اردو](README.ur.md) ·
[Bahasa Indonesia](README.id.md) ·
**Bahasa Melayu** ·
[Bosanski](README.bs.md) ·
[Shqip](README.sq.md) ·
[Azərbaycan](README.az.md) ·
[Deutsch](README.de.md) ·
[Français](README.fr.md) ·
[Nederlands](README.nl.md) ·
[Русский](README.ru.md)

</div>

---

## Gambaran keseluruhan

Prayer Times berada di bar menu anda dan sentiasa memaparkan waktu solat yang sedang berlangsung, bersama kiraan detik sehingga waktu itu tamat. Klik pada item bar menu untuk membuka panel yang memaparkan kesemua enam waktu bagi lokasi anda, dilukis sebagai kad bertemakan langit yang berubah mengikut waktu siang dan malam.

## Tangkapan skrin

### Paparan panel

Empat susun atur tersedia dan boleh ditukar dalam Tetapan.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="Paparan kad" /><br />
      <b>Kad</b> — kad langit selebar panel
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="Paparan langit" /><br />
      <b>Langit</b> — grid berilustrasi 3×2
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="Paparan senarai" /><br />
      <b>Senarai</b> — baris padat dengan ikon
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="Paparan kotak" /><br />
      <b>Kotak</b> — satu baris padat
    </td>
  </tr>
</table>

### Tetapan

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="Tetapan lokasi dan pemberitahuan" /><br />
      Lokasi dan pemberitahuan bagi setiap waktu
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="Tetapan am" /><br />
      Gaya paparan, bar menu dan bahasa
    </td>
  </tr>
</table>

### Bahasa kanan ke kiri

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="Antara muka bahasa Arab dengan susun atur kanan ke kiri" />
</div>

Bahasa Arab, Parsi dan Urdu menukar keseluruhan antara muka kepada kanan ke kiri.

## Ciri-ciri

- **Sekali pandang di bar menu** — nama waktu semasa dan baki masa sehingga ia tamat, dikemas kini setiap saat
- **Bar menu boleh ditetapkan** — pilih ikon (ikon solat, ikon aplikasi atau tiada), papar atau sembunyikan nama waktu, dan papar baki masa, waktu solat seterusnya atau tiada langsung
- **Empat susun atur panel** — Kad, Senarai, Kotak dan Langit
- **Lokasi** — pengesanan automatik melalui CoreLocation, atau pilihan manual negara / negeri / daerah
- **Pemberitahuan setiap waktu** — hidupkan setiap waktu secara berasingan, beritahu tepat pada masanya dan/atau 5–60 minit lebih awal
- **Berfungsi luar talian** — waktu untuk sebulan penuh disimpan dalam Application Support
- **Tarikh Hijrah** pada pengepala panel
- **Mula semasa log masuk**
- **14 bahasa** dengan sokongan kanan ke kiri sepenuhnya

## Keperluan

- macOS 14 (Sonoma) atau lebih baharu
- Xcode 15 atau lebih baharu dan [XcodeGen](https://github.com/yonaskolb/XcodeGen) untuk membina daripada sumber

## Bina daripada sumber

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Kemudian bina dan jalankan skema `PrayerTimes`. Melalui baris perintah:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Ujian

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## Cara ia berfungsi

Aplikasi ini ialah ejen `LSUIElement`, jadi ia tiada ikon Dock dan tiada tetingkap. Label bar menu ialah `NSStatusItem` yang dilukis dengan AppKit, manakala panelnya ialah `NSPopover` yang memuatkan paparan SwiftUI. Waktu aktif ialah tempoh yang **sedang anda lalui**, bukan yang seterusnya, jadi kiraan detik memberitahu berapa banyak masa berbaki dalam tempoh itu. Antara tengah malam dan imsak, aplikasi masih memaparkan Isyak.

Waktu diambil sebulan sekali dan disimpan sebagai JSON di `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes`, supaya aplikasi terus berfungsi tanpa sambungan rangkaian.

## Bahasa

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

Bahasa mengikut tetapan sistem secara lalai dan boleh ditukar dalam Tetapan → Am.

## Sumber data

Waktu solat diperoleh daripada [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com), yang menyediakan waktu rasmi terbitan **Diyanet İşleri Başkanlığı** (Presidensi Hal Ehwal Agama Türkiye).

<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Ikon aplikasi Prayer Times" />

# Prayer Times

**Aplikasi menu bar macOS asli untuk jadwal salat, memakai data resmi Diyanet.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 bahasa](https://img.shields.io/badge/bahasa-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="Prayer Times di menu bar macOS" />

</div>

<div align="center">

[English](../README.md) ·
[Türkçe](README.tr.md) ·
[العربية](README.ar.md) ·
[فارسی](README.fa.md) ·
[اردو](README.ur.md) ·
**Bahasa Indonesia** ·
[Bahasa Melayu](README.ms.md) ·
[Bosanski](README.bs.md) ·
[Shqip](README.sq.md) ·
[Azərbaycan](README.az.md) ·
[Deutsch](README.de.md) ·
[Français](README.fr.md) ·
[Nederlands](README.nl.md) ·
[Русский](README.ru.md)

</div>

---

## Ringkasan

Prayer Times berada di menu bar dan selalu menampilkan waktu salat yang sedang berlangsung beserta hitung mundur sampai waktu itu berakhir. Mengklik item di menu bar akan membuka panel berisi enam waktu salat untuk lokasi Anda, ditampilkan sebagai kartu bertema langit yang berubah mengikuti waktu dalam sehari.

## Tangkapan layar

### Tampilan panel

Tersedia empat tata letak yang dapat diganti di Pengaturan.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="Tampilan kartu" /><br />
      <b>Kartu</b> — kartu langit selebar panel
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="Tampilan langit" /><br />
      <b>Langit</b> — kisi bergambar 3×2
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="Tampilan daftar" /><br />
      <b>Daftar</b> — baris ringkas dengan ikon
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="Tampilan kotak" /><br />
      <b>Kotak</b> — satu baris rapat
    </td>
  </tr>
</table>

### Pengaturan

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="Pengaturan lokasi dan notifikasi" /><br />
      Lokasi dan notifikasi per waktu salat
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="Pengaturan umum" /><br />
      Gaya tampilan, menu bar, dan bahasa
    </td>
  </tr>
</table>

### Bahasa kanan-ke-kiri

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="Antarmuka bahasa Arab dengan tata letak kanan ke kiri" />
</div>

Bahasa Arab, Persia, dan Urdu membalik seluruh antarmuka menjadi kanan-ke-kiri.

## Fitur

- **Sekilas di menu bar** — nama waktu salat saat ini dan hitung mundur hingga berakhir, diperbarui setiap detik
- **Menu bar yang dapat diatur** — pilih ikon (ikon salat, ikon aplikasi, atau tanpa ikon), tampilkan atau sembunyikan nama salat, dan tampilkan sisa waktu, jam salat berikutnya, atau tidak sama sekali
- **Empat tata letak panel** — Kartu, Daftar, Kotak, dan Langit
- **Lokasi** — deteksi otomatis lewat CoreLocation, atau pilih negara / provinsi / distrik secara manual
- **Notifikasi per waktu salat** — aktifkan tiap salat secara terpisah, beri tahu tepat pada waktunya dan/atau 5–60 menit sebelumnya
- **Bisa offline** — jadwal satu bulan penuh disimpan di Application Support
- **Tanggal Hijriah** di kepala panel
- **Jalan otomatis saat masuk**
- **14 bahasa** dengan dukungan kanan-ke-kiri penuh

## Kebutuhan

- macOS 14 (Sonoma) atau lebih baru
- Xcode 15 atau lebih baru dan [XcodeGen](https://github.com/yonaskolb/XcodeGen) untuk membangun dari sumber

## Membangun dari sumber

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Lalu bangun dan jalankan skema `PrayerTimes`. Dari baris perintah:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Pengujian

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## Cara kerja

Aplikasi ini adalah agen `LSUIElement`, jadi tidak punya ikon Dock maupun jendela. Label di menu bar adalah `NSStatusItem` yang digambar dengan AppKit, dan panelnya adalah `NSPopover` yang memuat tampilan SwiftUI. Waktu yang aktif adalah periode yang **sedang Anda jalani**, bukan yang berikutnya, sehingga hitung mundur menunjukkan sisa waktu periode tersebut. Antara tengah malam dan imsak, aplikasi tetap menampilkan Isya.

Jadwal diambil per bulan dan disimpan sebagai JSON di `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes`, sehingga aplikasi tetap berfungsi tanpa koneksi internet.

## Bahasa

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

Bahasa mengikuti pengaturan sistem secara bawaan dan dapat diganti di Pengaturan → Umum.

## Sumber data

Jadwal salat berasal dari [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com), yang menyajikan jadwal resmi dari **Diyanet İşleri Başkanlığı** (Kepresidenan Urusan Agama Türkiye).

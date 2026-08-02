<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Prayer Times proqram nişanı" />

# Prayer Times

**Diyanətin rəsmi məlumatlarına əsaslanan, macOS menyu zolağı üçün namaz vaxtları proqramı.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 dil](https://img.shields.io/badge/dil-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="macOS menyu zolağında Prayer Times" />

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
**Azərbaycan** ·
[Deutsch](README.de.md) ·
[Français](README.fr.md) ·
[Nederlands](README.nl.md) ·
[Русский](README.ru.md)

</div>

---

## Ümumi baxış

Prayer Times menyu zolağında dayanır və hazırda içində olduğunuz namaz vaxtını, həmin vaxtın bitməsinə qalan geri sayımla birlikdə göstərir. Menyu zolağındakı elementə klikləyəndə məkanınız üzrə hər altı vaxtı göstərən panel açılır; kartlar günün saatına görə dəyişən səma fonu ilə çəkilir.

## Ekran görüntüləri

### Panel görünüşləri

Ayarlardan dəyişdirilə bilən dörd düzülüş mövcuddur.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="Kartlar görünüşü" /><br />
      <b>Kartlar</b> — tam enli səma kartları
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="Səma görünüşü" /><br />
      <b>Səma</b> — 3×2 illüstrasiyalı şəbəkə
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="Siyahı görünüşü" /><br />
      <b>Siyahı</b> — nişanlı yığcam sətirlər
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="Qutular görünüşü" /><br />
      <b>Qutular</b> — tək sıxılmış sıra
    </td>
  </tr>
</table>

### Ayarlar

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="Məkan və bildiriş ayarları" /><br />
      Məkan və hər vaxt üçün ayrıca bildirişlər
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="Ümumi ayarlar" /><br />
      Görünüş stili, menyu zolağı və dil
    </td>
  </tr>
</table>

### Sağdan sola dillər

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="Sağdan sola düzülüşlü ərəb interfeysi" />
</div>

Ərəb, fars və urdu dilləri bütün interfeysi sağdan sola çevirir.

## Xüsusiyyətlər

- **Menyu zolağında bir baxışda** — cari namazın adı və bitməsinə qalan vaxt, hər saniyə yenilənir
- **Tənzimlənə bilən menyu zolağı** — nişanı seçin (namaz nişanı, proqram nişanı və ya heç biri), namaz adını göstərin ya gizlədin, qalan vaxtı, növbəti namazın saatını və ya heç nə göstərməyin
- **Dörd panel düzülüşü** — Kartlar, Siyahı, Qutular və Səma
- **Məkan** — CoreLocation ilə avtomatik təyin və ya ölkə / vilayət / rayon üzrə əl ilə seçim
- **Hər vaxt üçün bildirişlər** — hər namazı ayrıca aktivləşdirin, dəqiq vaxtında və/və ya 5–60 dəqiqə əvvəl xəbərdarlıq alın
- **Oflayn işləyir** — bir aylıq vaxtlar Application Support-da saxlanılır
- **Hicri tarix** panel başlığında
- **Girişdə avtomatik başlatma**
- **14 dil** və tam sağdan sola dəstəyi

## Tələblər

- macOS 14 (Sonoma) və ya daha yenisi
- Mənbədən qurmaq üçün Xcode 15+ və [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Mənbədən qurma

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Sonra `PrayerTimes` sxemini qurub işə salın. Komanda sətrindən:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Testlər

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## Necə işləyir

Proqram `LSUIElement` agentidir, ona görə də nə Dock nişanı, nə də pəncərəsi var. Menyu zolağındakı etiket AppKit ilə çəkilən `NSStatusItem`, panel isə SwiftUI görünüşünü saxlayan `NSPopover`-dur. Aktiv namaz növbəti deyil, **hazırda içində olduğunuz** vaxtdır; geri sayım da həmin vaxtın bitməsinə nə qədər qaldığını göstərir. Gecə yarısı ilə imsak arasında proqram hələ də işanı göstərir.

Vaxtlar aylıq olaraq yüklənir və `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes` altında JSON kimi saxlanılır; beləliklə internet olmadan da işləməyə davam edir.

## Dillər

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

Dil susmaya görə sistem ayarını izləyir və Ayarlar → Ümumi bölməsindən dəyişdirilə bilər.

## Məlumat mənbəyi

Namaz vaxtları **Diyanet İşleri Başkanlığı**-nın (Türkiyə Dini İşlər İdarəsi) dərc etdiyi rəsmi vaxtları təqdim edən [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com) vasitəsilə alınır.

<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Prayer Times ایپ آئیکن" />

# Prayer Times

**macOS مینو بار کے لیے ایک نیٹو ایپ جو دیانت کے سرکاری اعداد و شمار سے نماز کے اوقات دکھاتی ہے۔**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 زبانیں](https://img.shields.io/badge/languages-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="macOS مینو بار میں Prayer Times" />

</div>

<div align="center">

[English](../README.md) ·
[Türkçe](README.tr.md) ·
[العربية](README.ar.md) ·
[فارسی](README.fa.md) ·
**اردو** ·
[Bahasa Indonesia](README.id.md) ·
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

## تعارف

Prayer Times آپ کے مینو بار میں رہتی ہے اور ہمیشہ وہ نماز دکھاتی ہے جس کا وقت اس وقت جاری ہے، ساتھ ہی اس وقت کے ختم ہونے تک کی الٹی گنتی بھی۔ مینو بار آئٹم پر کلک کرنے سے ایک پینل کھلتا ہے جس میں آپ کے مقام کے چھ اوقات دکھائے جاتے ہیں — ایسے کارڈز کی صورت میں جن کا آسمانی پس منظر دن کے وقت کے ساتھ بدلتا ہے۔

## اسکرین شاٹس

### پینل کے انداز

چار لے آؤٹ دستیاب ہیں جنہیں ترتیبات سے تبدیل کیا جا سکتا ہے۔

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="کارڈز انداز" /><br />
      <b>کارڈز</b> — پوری چوڑائی کے آسمانی کارڈ
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="آسمان انداز" /><br />
      <b>آسمان</b> — 3×2 تصویری گرڈ
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="فہرست انداز" /><br />
      <b>فہرست</b> — آئیکن کے ساتھ مختصر قطاریں
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="خانے انداز" /><br />
      <b>خانے</b> — ایک ہی مختصر قطار
    </td>
  </tr>
</table>

### ترتیبات

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="مقام اور اطلاعات کی ترتیبات" /><br />
      مقام اور ہر نماز کی الگ اطلاعات
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="عمومی ترتیبات" /><br />
      نمائش کا انداز، مینو بار اور زبان
    </td>
  </tr>
</table>

### دائیں سے بائیں زبانیں

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="دائیں سے بائیں ترتیب کے ساتھ عربی انٹرفیس" />
</div>

عربی، فارسی اور اردو منتخب کرنے پر پورا انٹرفیس دائیں سے بائیں ہو جاتا ہے۔

## خصوصیات

- **مینو بار پر ایک نظر** — جاری نماز کا نام اور اس کے ختم ہونے میں باقی وقت، ہر سیکنڈ اپ ڈیٹ
- **قابلِ ترتیب مینو بار** — آئیکن منتخب کریں (نماز کا آئیکن، ایپ آئیکن یا کوئی نہیں)، نماز کا نام دکھائیں یا چھپائیں، اور باقی وقت، اگلی نماز کا وقت یا کچھ بھی نہ دکھائیں
- **چار پینل لے آؤٹ** — کارڈز، فہرست، خانے اور آسمان
- **مقام** — CoreLocation کے ذریعے خودکار تعین یا ملک / صوبہ / ضلع کا دستی انتخاب
- **ہر نماز کے لیے اطلاعات** — ہر نماز الگ سے فعال کریں، عین وقت پر اور/یا 5 تا 60 منٹ پہلے اطلاع
- **آف لائن کام کرتی ہے** — پورے مہینے کے اوقات Application Support میں محفوظ ہوتے ہیں
- **ہجری تاریخ** پینل کے سرنامے میں
- **لاگ اِن پر خودکار آغاز**
- **14 زبانیں** مکمل دائیں سے بائیں سپورٹ کے ساتھ

## تقاضے

- macOS 14 (Sonoma) یا اس سے نیا
- سورس سے بنانے کے لیے Xcode 15 یا نیا اور [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## سورس سے بنائیں

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

پھر `PrayerTimes` اسکیم کو بنائیں اور چلائیں۔ کمانڈ لائن سے:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## ٹیسٹ

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## یہ کیسے کام کرتی ہے

ایپ ایک `LSUIElement` ایجنٹ ہے، اس لیے نہ Dock آئیکن ہے نہ کوئی ونڈو۔ مینو بار لیبل AppKit سے بنایا گیا `NSStatusItem` ہے اور پینل ایک `NSPopover` ہے جس میں SwiftUI ویو ہے۔ فعال نماز وہی ہے جس کے وقت میں آپ **اِس وقت ہیں**، اگلی نہیں؛ اس لیے الٹی گنتی بتاتی ہے کہ اس وقت میں کتنا حصہ باقی ہے۔ آدھی رات سے سحری تک ایپ عشاء ہی دکھاتی رہتی ہے۔

اوقات ماہانہ بنیاد پر حاصل کیے جاتے ہیں اور `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes` میں JSON کے طور پر محفوظ ہوتے ہیں، تاکہ انٹرنیٹ کے بغیر بھی ایپ کام کرتی رہے۔

## زبانیں

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский۔

زبان بطورِ طے شدہ سسٹم کی ترتیب کے مطابق ہوتی ہے اور ترتیبات ← عمومی سے تبدیل کی جا سکتی ہے۔

## ڈیٹا کا ماخذ

نماز کے اوقات [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com) سے آتے ہیں، جو **دیانت اِشلری باشقانلیغی (Diyanet İşleri Başkanlığı)** یعنی ترکی کی مذہبی امور کی صدارت کے شائع کردہ سرکاری اوقات فراہم کرتا ہے۔

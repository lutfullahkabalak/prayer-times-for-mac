<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="نماد برنامه Prayer Times" />

# Prayer Times

**یک برنامهٔ بومی برای نوار منوی macOS که اوقات شرعی را بر پایهٔ داده‌های رسمی دیانت نشان می‌دهد.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![۱۴ زبان](https://img.shields.io/badge/languages-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="Prayer Times در نوار منوی macOS" />

</div>

<div align="center">

[English](../README.md) ·
[Türkçe](README.tr.md) ·
[العربية](README.ar.md) ·
**فارسی** ·
[اردو](README.ur.md) ·
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

## مرور کلی

Prayer Times در نوار منو می‌ماند و همیشه نمازی را که اکنون در وقت آن هستید به همراه شمارش معکوس تا پایان آن نشان می‌دهد. با کلیک روی آن، پنلی باز می‌شود که هر شش وقت شرعی موقعیت شما را در قالب کارت‌هایی با پس‌زمینهٔ آسمان نمایش می‌دهد؛ آسمانی که با ساعت روز تغییر می‌کند.

## تصاویر

### نماهای پنل

چهار چیدمان در دسترس است که از تنظیمات قابل تعویض‌اند.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="نمای کارت‌ها" /><br />
      <b>کارت‌ها</b> — کارت‌های آسمان با عرض کامل
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="نمای آسمان" /><br />
      <b>آسمان</b> — شبکهٔ تصویری ۳×۲
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="نمای فهرست" /><br />
      <b>فهرست</b> — ردیف‌های فشرده با نماد
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="نمای جعبه‌ها" /><br />
      <b>جعبه‌ها</b> — یک ردیف فشرده
    </td>
  </tr>
</table>

### تنظیمات

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="تنظیمات موقعیت و اعلان‌ها" /><br />
      موقعیت و اعلان جداگانه برای هر وقت
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="تنظیمات عمومی" /><br />
      نوع نما، نوار منو و زبان
    </td>
  </tr>
</table>

### زبان‌های راست‌به‌چپ

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="رابط عربی با چیدمان راست‌به‌چپ" />
</div>

با انتخاب عربی، فارسی یا اردو کل رابط کاربری راست‌به‌چپ می‌شود.

## ویژگی‌ها

- **یک نگاه به نوار منو** — نام وقت جاری و زمان باقی‌مانده تا پایان آن، با به‌روزرسانی هر ثانیه
- **نوار منوی قابل تنظیم** — انتخاب نماد (نماد نماز، نماد برنامه یا بدون نماد)، نمایش یا پنهان‌کردن نام وقت، و نمایش زمان باقی‌مانده، وقت بعدی یا هیچ‌کدام
- **چهار چیدمان پنل** — کارت‌ها، فهرست، جعبه‌ها و آسمان
- **موقعیت** — تشخیص خودکار با CoreLocation یا انتخاب دستی کشور / استان / شهرستان
- **اعلان برای هر وقت** — فعال‌سازی جداگانهٔ هر وقت، اعلان در زمان دقیق و/یا ۵ تا ۶۰ دقیقه پیش از آن
- **کار در حالت آفلاین** — اوقات یک ماه کامل در Application Support ذخیره می‌شود
- **تاریخ هجری قمری** در سربرگ پنل
- **اجرا هنگام ورود به سیستم**
- **۱۴ زبان** با پشتیبانی کامل راست‌به‌چپ

## پیش‌نیازها

- macOS 14 (Sonoma) یا بالاتر
- برای ساخت از منبع: Xcode 15 یا بالاتر و [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## ساخت از منبع

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

سپس اسکیم `PrayerTimes` را بسازید و اجرا کنید. از خط فرمان:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## آزمون‌ها

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## نحوهٔ کار

برنامه از نوع `LSUIElement` است، بنابراین نه نماد Dock دارد و نه پنجره. برچسب نوار منو یک `NSStatusItem` است که با AppKit رسم می‌شود و پنل یک `NSPopover` است که نمای SwiftUI را در خود دارد. وقت فعال، وقتی است که هم‌اکنون **در آن هستید** نه وقت بعدی؛ پس شمارش معکوس، باقی‌ماندهٔ همان وقت را نشان می‌دهد. میان نیمه‌شب تا اذان صبح، برنامه همچنان عشاء را نشان می‌دهد.

اوقات به‌صورت ماهانه دریافت و در قالب JSON در مسیر `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes` ذخیره می‌شوند تا برنامه بدون اینترنت هم کار کند.

## زبان‌ها

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

زبان به‌طور پیش‌فرض از تنظیمات سیستم پیروی می‌کند و از مسیر تنظیمات ← عمومی قابل تغییر است.

## منبع داده

اوقات شرعی از [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com) گرفته می‌شود که اوقات رسمی منتشرشده توسط **ریاست امور دینی ترکیه (Diyanet İşleri Başkanlığı)** را ارائه می‌دهد.

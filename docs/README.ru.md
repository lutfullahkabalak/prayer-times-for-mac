<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Значок приложения Prayer Times" />

# Prayer Times

**Нативное приложение для строки меню macOS: время намаза по официальным данным Диянета.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 языков](https://img.shields.io/badge/%D1%8F%D0%B7%D1%8B%D0%BA%D0%BE%D0%B2-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="Prayer Times в строке меню macOS" />

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
[Nederlands](README.nl.md) ·
**Русский**

</div>

---

## Обзор

Prayer Times живёт в строке меню и всегда показывает намаз, время которого идёт сейчас, вместе с обратным отсчётом до его окончания. По клику открывается панель со всеми шестью временами для вашего местоположения — карточки с небом, которое меняется в зависимости от времени суток.

## Снимки экрана

### Виды панели

Доступны четыре варианта оформления, переключаются в настройках.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="Вид «Карточки»" /><br />
      <b>Карточки</b> — карточки неба во всю ширину
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="Вид «Небо»" /><br />
      <b>Небо</b> — иллюстрированная сетка 3×2
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="Вид «Список»" /><br />
      <b>Список</b> — компактные строки со значками
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="Вид «Ячейки»" /><br />
      <b>Ячейки</b> — один плотный ряд
    </td>
  </tr>
</table>

### Настройки

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="Настройки местоположения и уведомлений" /><br />
      Местоположение и уведомления для каждого намаза
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="Общие настройки" /><br />
      Вид панели, строка меню и язык
    </td>
  </tr>
</table>

### Языки с письмом справа налево

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="Арабский интерфейс с раскладкой справа налево" />
</div>

При выборе арабского, персидского или урду весь интерфейс разворачивается справа налево.

## Возможности

- **Всё видно в строке меню** — название текущего намаза и время до его окончания, обновляется каждую секунду
- **Настраиваемая строка меню** — выберите значок (значок намаза, значок приложения или без него), покажите или скройте название намаза и выводите оставшееся время, время следующего намаза либо ничего
- **Четыре вида панели** — Карточки, Список, Ячейки и Небо
- **Местоположение** — автоопределение через CoreLocation либо ручной выбор страны / региона / района
- **Уведомления по каждому намазу** — включайте каждый намаз отдельно, с уведомлением точно во время и/или за 5–60 минут
- **Работает офлайн** — расписание на целый месяц кэшируется в Application Support
- **Дата по хиджре** в заголовке панели
- **Запуск при входе в систему**
- **14 языков** с полной поддержкой письма справа налево

## Требования

- macOS 14 (Sonoma) или новее
- Xcode 15 или новее и [XcodeGen](https://github.com/yonaskolb/XcodeGen) для сборки из исходников

## Сборка из исходников

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Затем соберите и запустите схему `PrayerTimes`. Из командной строки:

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Тесты

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## Как это работает

Приложение — агент `LSUIElement`, поэтому у него нет ни значка в Dock, ни окна. Надпись в строке меню — это `NSStatusItem`, отрисованный средствами AppKit, а панель — `NSPopover` с представлением SwiftUI. Активный намаз — это период, в котором вы **находитесь сейчас**, а не следующий, поэтому обратный отсчёт показывает, сколько осталось до конца этого периода. Между полуночью и имсаком приложение по-прежнему показывает иша.

Расписание загружается помесячно и хранится в виде JSON в `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes`, поэтому приложение работает и без подключения к сети.

## Языки

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

По умолчанию язык следует системной настройке, изменить его можно в «Настройки → Общие».

## Источник данных

Время намаза берётся из [Ezan Vakti İmsakiyem API](https://ezanvakti.imsakiyem.com), который публикует официальное расписание **Diyanet İşleri Başkanlığı** (Управление по делам религии Турции).

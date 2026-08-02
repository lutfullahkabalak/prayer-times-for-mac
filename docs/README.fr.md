<div align="center">

<img src="screenshots/app-icon.png" width="120" alt="Icône de l'application Prayer Times" />

# Prayer Times

**Application native pour la barre de menus macOS affichant les horaires de prière, à partir des données officielles de la Diyanet.**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-AppKit-0A84FF)
![14 langues](https://img.shields.io/badge/langues-14-34C759)

<img src="screenshots/menubar.png" width="620" alt="Prayer Times dans la barre de menus macOS" />

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
**Français** ·
[Nederlands](README.nl.md) ·
[Русский](README.ru.md)

</div>

---

## Présentation

Prayer Times reste dans votre barre de menus et affiche toujours la prière dont le créneau est en cours, accompagnée d'un compte à rebours jusqu'à sa fin. Un clic sur l'élément ouvre un panneau présentant les six horaires du jour pour votre position, sous forme de cartes dont le ciel change au fil de la journée.

## Captures d'écran

### Vues du panneau

Quatre dispositions sont disponibles et se changent dans les Réglages.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/panel-cards.png" width="330" alt="Vue cartes" /><br />
      <b>Cartes</b> — cartes de ciel pleine largeur
    </td>
    <td align="center" width="50%">
      <img src="screenshots/panel-grid.png" width="330" alt="Vue ciel" /><br />
      <b>Ciel</b> — grille illustrée 3×2
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/panel-list.png" width="270" alt="Vue liste" /><br />
      <b>Liste</b> — lignes compactes avec icônes
    </td>
    <td align="center">
      <img src="screenshots/panel-tiles.png" width="330" alt="Vue cases" /><br />
      <b>Cases</b> — une seule rangée compacte
    </td>
  </tr>
</table>

### Réglages

<table>
  <tr>
    <td align="center" width="50%">
      <img src="screenshots/settings.png" width="300" alt="Réglages de localisation et de notifications" /><br />
      Localisation et notifications par prière
    </td>
    <td align="center" width="50%">
      <img src="screenshots/settings-general.png" width="300" alt="Réglages généraux" /><br />
      Style d'affichage, barre de menus et langue
    </td>
  </tr>
</table>

### Langues de droite à gauche

<div align="center">
  <img src="screenshots/panel-rtl.png" width="330" alt="Interface en arabe avec disposition de droite à gauche" />
</div>

L'arabe, le persan et l'ourdou inversent toute l'interface de droite à gauche.

## Fonctionnalités

- **Un coup d'œil dans la barre de menus** — nom de la prière en cours et temps restant avant la fin du créneau, actualisé chaque seconde
- **Barre de menus configurable** — choisissez l'icône (icône de prière, icône de l'app ou aucune), affichez ou masquez le nom de la prière, et affichez le temps restant, l'heure de la prochaine prière ou rien du tout
- **Quatre dispositions de panneau** — Cartes, Liste, Cases et Ciel
- **Localisation** — détection automatique via CoreLocation, ou choix manuel du pays / de la province / du district
- **Notifications par prière** — activez chaque prière séparément, avec alerte à l'heure exacte et/ou 5 à 60 minutes avant
- **Fonctionne hors ligne** — un mois complet d'horaires est mis en cache dans Application Support
- **Date hégirienne** dans l'en-tête du panneau
- **Lancement à l'ouverture de session**
- **14 langues** avec prise en charge complète de la lecture de droite à gauche

## Prérequis

- macOS 14 (Sonoma) ou version ultérieure
- Xcode 15 ou version ultérieure et [XcodeGen](https://github.com/yonaskolb/XcodeGen) pour compiler depuis les sources

## Compiler depuis les sources

```bash
git clone https://github.com/lutfullahkabalak/prayer-times-for-mac.git
cd prayer-times-for-mac
xcodegen generate
open PrayerTimes.xcodeproj
```

Compilez et lancez ensuite le schéma `PrayerTimes`. En ligne de commande :

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' build
```

## Tests

```bash
xcodebuild -scheme PrayerTimes -destination 'platform=macOS' test
```

## Fonctionnement

L'application est un agent `LSUIElement` : elle n'a ni icône dans le Dock ni fenêtre. L'étiquette de la barre de menus est un `NSStatusItem` dessiné avec AppKit, et le panneau est un `NSPopover` hébergeant une vue SwiftUI. La prière active est le créneau dans lequel vous vous trouvez **actuellement**, et non le suivant : le compte à rebours indique donc le temps restant dans ce créneau. Entre minuit et l'imsak, l'application affiche toujours l'icha.

Les horaires sont récupérés mois par mois et stockés au format JSON dans `~/Library/Containers/com.lutfullahkabalak.prayertimes/Data/Library/Application Support/PrayerTimes`, ce qui permet à l'application de fonctionner sans connexion réseau.

## Langues

English, Türkçe, العربية, فارسی, اردو, Bahasa Indonesia, Bahasa Melayu, Bosanski, Shqip, Azərbaycan, Deutsch, Français, Nederlands, Русский.

La langue suit par défaut le réglage du système et peut être modifiée dans Réglages → Général.

## Source des données

Les horaires proviennent de l'[API Ezan Vakti İmsakiyem](https://ezanvakti.imsakiyem.com), qui diffuse les horaires officiels publiés par la **Diyanet İşleri Başkanlığı** (Présidence des affaires religieuses de Türkiye).

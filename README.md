# locale_switcher

A widget for switching the locale of your application.

[![codecov](https://codecov.io/gh/Alexqwesa/locale_switcher/graph/badge.svg?token=2F9HPWGCQE)](https://codecov.io/gh/Alexqwesa/locale_switcher)


<img align="right" src="https://raw.githubusercontent.com/alexqwesa/locale_switcher/master/screenshot.gif" width="262" height="540">

## Content

- [About](#about)
- [Features](#features)
- [Usage](#usage)
- [Example](#example)
- [Todo](#todo)
- [FAQ](#faq)

## About

This package allows you to add locale-switching functionality to your app with just a few lines of code.

It depends on [intl](https://pub.dev/packages/intl) package (not tested with other localization packages).

## Features

- Contains widget to switch locale - [LocaleSwitcher](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher-class.html):
    - which includes a list of locales for you app with additional option to use system locale,
    - it offers several constructors:  [LocaleSwitcher.toggle](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher/LocaleSwitcher.toggle.html), [LocaleSwitcher.menu](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher/LocaleSwitcher.menu.html) or [LocaleSwitcher.custom](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher/LocaleSwitcher.custom.html),
- Contains a button [SelectLocaleButton](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/SelectLocaleButton-class.html) to open popup window,
- Optionally stores the last selected locale in  [SharedPreferences],
- Provides a [LocaleManager.realLocaleNotifier](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleManager/realLocaleNotifier.html) to dynamically change the app's locale (and notifier [LocaleManager.locale](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleManager/locale.html) to listen to locale changes).
- Observes changes in the system locale.

## Usage

1) Wrap `MaterialApp` or `CupertinoApp` with [LocaleManager](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleManager-class.html):

```dart
  @override
Widget build(BuildContext context, WidgetRef ref) {
  return LocaleManager(
      child: MaterialApp(
        locale: LocaleManager.locale.value,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
  //...
```

2) Add [LocaleSwitcher](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher-class.html) widget anywhere into your app.
3) Or use [SelectLocaleButton](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/SelectLocaleButton-class.html) or just use `showSelectLocaleDialog`.

Note: localization should be set up before you start to use this package,
if there some problems - please, check next section and/or [intl](https://pub.dev/packages/intl) documentation,
before reporting bug.

## Troubleshooting

### Check that intl package is setup correctly:

The following instructions are  from [intl](https://pub.dev/packages/intl) package, so you probably already did them:

In `pubspec.yaml`:

```yaml  

dependencies: # in this section
  intl: 
  flutter_localizations:
    sdk: flutter
dev_dependencies: # in this section 
  build_runner:  
flutter: # in this section 
  generate: true  
```

Optionally - in [l10n.yaml](example/l10n.yaml):

```yaml
arb-dir: lib/src/l10n
template-arb-file: intl_en.arb
output-dir: lib/src/l10n/generated
output-localization-file: app_localizations.dart
untranslated-messages-file: desiredFileName.txt
preferred-supported-locales: [ "en", "vi", "de" ]
nullable-getter: false
```
## Example

[Online Example here](https://alexqwesa.github.io/locale_switcher/)

[Example Code](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart)

## TODO:

- [ ] Test with other localization system

## FAQ

#### - How to change order of languages?

Languages are shown in the same order as they listed in [l10n.yaml](example/l10n.yaml).

#### - How to change flag of language?

Use [LocaleManager](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleManager-class.html).`reassign` parameter like this:
```dart
LocaleManager(
  reassign: {'en': ['GB', 'English', <Your_icon_optional>]}
  // (first two options are required, third is optional)
  // first option is the code of country which flag you want to use
...
)
```


#### - How to use localization outside of `MaterialApp`(or CupertinoApp)?

Here is a useful example, although it is not depend on this package:

```dart

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Access localization through locale
extension LocaleWithDelegate on Locale {
  /// Get class with translation strings for this locale.
  AppLocalizations get tr => lookupAppLocalizations(this);
}

Locale("en").tr.example
// or 
LocaleManager.locale.value.tr.example
```

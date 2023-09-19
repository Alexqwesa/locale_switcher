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

- contains nice a widget to switch locale,
    - which provide list of locales of you app with additional option to use system locale,
- Store last selected locale in [SharedPreferences] (optional),
- Provides a [ValueNotifier] to dynamically change the app's locale.
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

### Checking that intl package is setup correctly:

The following instruction is from [intl](https://pub.dev/packages/intl) package, so you probably already did them:

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
- [ ] Customize switcher
- [ ] Allow to change language-flag assignment
- [ ] Finish showOtherLocales button

## FAQ
#### - How to use localization outside of `MaterialApp`(or CupertinoApp):
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

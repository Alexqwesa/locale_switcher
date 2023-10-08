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

This package allows you to add **locale-switching** functionality to your app **with just 2 lines** of code.

This is NOT a localization package, it is just a few useful widgets that extend 
functionality of localization systems, such as: [intl](https://pub.dev/packages/intl), 
[easy_localization](https://pub.dev/packages/easy_localization), etc...

Note: This package is already small, but if you still want to further reduce its size,
you can use [locale_switcher_dev](https://pub.dev/packages/locale_switcher_dev) package,
which allow you to control what flags are included (or none) 
and which packages it depend on (or none).

## Features

- [LocaleManager](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleManager-class.html) widget:
    - optionally: load/stores the last selected locale in `SharedPreferences`,
    - update locale of app (listen to `notifier` and rebuild `MaterialApp`),
    - observes changes in the system locale,

- [LocaleSwitcher](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher-class.html) - 
a widget to switch locale:
    - show a list of locales and special option to use system locale,
    - constructor [LocaleSwitcher.segmentedButton](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher/LocaleSwitcher.segmentedButton.html),
    - constructor [LocaleSwitcher.menu](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher/LocaleSwitcher.menu.html),
    - constructor [LocaleSwitcher.custom](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher/LocaleSwitcher.custom.html),
    - constructor [LocaleSwitcher.iconButton](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher/LocaleSwitcher.iconButton.html) - button/indicator which open popup window to select locale,

- Some other helpers:
    - [LangIconWithToolTip](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher-class.html)
      class with additional constructor [forIconBuilder](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LangIconWithToolTip/LangIconWithToolTip.forIconBuilder.html) ,
    - [showSelectLocaleDialog](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/showSelectLocaleDialog.html).
    - Extension for Locale which return flag - [Locale.flag](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleFlag.html) 

- Can be generated via [locale_switcher_dev](https://pub.dev/packages/locale_switcher_dev) 
package, in this case you control:
  - what flags are included (or none),
  - which packages it depend on (or none).

## Usage

1) Wrap `MaterialApp` or `CupertinoApp`
   with [LocaleManager](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleManager-class.html)
   (example for `intl` package):

```dart
  @override
Widget build(BuildContext context, WidgetRef ref) {
  return LocaleManager(
      child: MaterialApp(
          locale: LocaleSwitcher.localeBestMatch,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
  //...
```

2) Add [LocaleSwitcher](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher-class.html)
   widget anywhere into your app.

## Troubleshooting

Note: localization should be set up before you start to use this package,
if there some problems - please, check next section and/or documentation of localization system you use,
before reporting bug.

### Check that intl package is setup correctly:

The following instructions are from [intl](https://pub.dev/packages/intl) package, so you probably already did them:

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

### With [intl](https://pub.dev/packages/intl) package:

[Online Example here](https://alexqwesa.github.io/locale_switcher/)

- [Example Code (recommended)](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart).

Another example code: [LocaleSwitcher used without
LocaleManager(not recommended)](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main_without_locale_manager.dart).

Example with dynamic option switch:
[here](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main_with_dynamic_options.dart).

### With [easy_localization](https://pub.dev/packages/easy_localization) package:

[locale_switcher_dev](https://pub.dev/packages/locale_switcher) + easy_localization:
[https://github.com/Alexqwesa/locale_switcher/tree/builder/examples/easy_localization](https://github.com/Alexqwesa/locale_switcher/tree/builder/examples/easy_localization) (recommended)

[locale_switcher](https://pub.dev/packages/locale_switcher) + easy_localization:
[https://github.com/Alexqwesa/locale_switcher/tree/main/examples/easy_localization](https://github.com/Alexqwesa/locale_switcher/tree/main/examples/easy_localization)

## TODO:

- [ ] Test with other localization system (currently: tested intl and easy_localization)
- [ ] Support slang
- [ ] Rectangle and oval flags, not just square and circle

[//]: # (- [ ] compose listenable into one class)

[//]: # (- [ ] detect cupertino/material in dev package)

## FAQ

#### - How to change order of languages?

Languages are shown in the same order as they listed in [l10n.yaml](example/l10n.yaml), 
or dynamically via  [LocaleSwitcher.custom](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleSwitcher/LocaleSwitcher.custom.html).

#### - How to change flag of language?

Use [LocaleManager](https://pub.dev/documentation/locale_switcher/latest/locale_switcher/LocaleManager-class.html).`reassign`
parameter like this:

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

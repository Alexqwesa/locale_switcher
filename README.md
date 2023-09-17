# locale_switcher

A widget for switching the locale of your application.

## About

This package allows you to add locale-switching functionality to your app with just a few lines of code.

It depends on [intl](https://pub.dev/packages/intl) package (not tested with other localization packages).

**Functionality:**

- contains nice a widget to switch locale,
    - which provide list of locales of you app with additional option to use system locale,
- Store last selected locale in [SharedPreferences] (optional),
- Provides a [ValueNotifier] to dynamically change the app's locale.
- Observes changes in the system locale.

## Usage

Wrap `MaterialApp` or `CupertinoApp` with `LocaleManager`:

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

Add `LocaleSwitcher` widget into your app.

Note: localization should be setup before you start to use this package,
if there some problems - please, check next section and/or [intl](https://pub.dev/packages/intl) documentation,
before reporting bug.

## Checking that intl package is setup correctly:

The following instruction is from [intl](https://pub.dev/packages/intl) package, so you probably already did them:

In `pubspec.yaml`:

```yaml  

dependencies:
  intl:
  flutter_localizations:
    sdk: flutter
dev_dependencies: # in this section
  build_runner:   # add this line - REQUIRED   
flutter: # in this section
  generate: true  # add this line - REQUIRED   
```

Optionally - in [l10n.yaml](example/l10n.yaml):

```yaml
arb-dir: lib/src/l10n
template-arb-file: intl_en.arb
output-dir: lib/src/l10n/generated
output-localization-file: app_localizations.dart
untranslated-messages-file: desiredFileName.txt
preferred-supported-locales: [ "en", "ru", "de" ]
nullable-getter: false
```

## TODO:

- [ ] Test with other localization system
# Changelog

## 1.2.9

* fix [LocaleManager] always update parents.

## 1.2.7

* fix: [LocaleSwitcher].iconButton now also respect multiLang* options.

## 1.2.2

In [LocaleSwitcher]:

* rename [forceMulti] -> [multiLangForceAll]
* added: [multiLangWidget] (default to [MultiLangFlag])

## 1.2.1

* Added a lot of languages.

* Added graceful ways to display Locales for countries with multiple languages,
  for this purpose added these parameters to [LocaleSwitcher]:

- [MultiLangCountries] - enum to select how to display countries with multiple languages,
- [countriesWithMulti] - list of such countries, add you own here,
- [popularInCountry] - for [MultiLangCountries.auto] - country's most popular language.

## 1.1.1

* LocaleSwitch support emoji,
* improve sizes calculation,
* width option for LocaleSwitch menu and segmentedButton constructors,
* fix minor bug in LocaleSwitch.menu,
* map languageToCountry now public.

## 1.0.0

* no breaking changes - v1.0 just to indication what it is stable,
* all major localization system tested (intl, easy_localization, slang),
  and have examples.

## 0.12.2

* update docs.

## 0.12.1

* Extension Locale.flag,
* helper TitleForLocaleSwitch,
* LocaleMatcher,
* hide CurrentLocale use LocaleSwitcher instead,
* MIT LICENSE.

## 0.11.4

* LocaleSwitcher.setLocaleCallBack - your callBack after selecting locale,
* LocaleSwitcher.localeBestMatch - return best match in supportedLocales for LocaleSwitcher.locale,
* easy_localization status: tested,
* docs update.

## 0.10.2

* LocaleSwitcher.localeNameFlag - is list generated from supportedLocales,
* CurrentLocale class - notifiers and helpers to work with LocaleNameFlagList,
* move static methods to LocaleSwitcher from LocaleManager,
* extensions: LocaleFlag on Locale, StringToLocale on String,
* findFlagFor helper function.

## 0.9.8

* update docs.

## 0.9.7

* fix docs,
* sync with `locale_switcher_dev`.

## 0.9.6

* created package `locale_switcher_dev` which can generate this package dynamically.
  which required a few more lines to set up, but allow you to control
  what flags are included (or none) and which packages it depend on (or none).

## 0.9.5

* remove `LocaleSwitcher.toggle` and it dependency`animated_toggle_switch`,
* instead of `LocaleSwitcher.toggle` use `LocaleSwitcher.custom` with `animated_toggle_switch` as shown in example,
* new option `shape` for `LocaleSwitcher`,
* use generated icon resources, preparing to use build_runner.

## 0.9.4

* new LocaleSwitcher.segmentedButton,
* added `showLeading` for LocaleSwitch.menu,
* fix docs.

## 0.9.3

* allow to use letters instead of country's flags

## 0.9.2

* rename `LocaleManager.realLocaleNotifier` to `LocaleManager.languageCode`.

## 0.9.1

* update documentation,
* cleanup dependencies.

## 0.8.4

* use `LocaleSwitcher.iconButton` instead of `SelectLocaleButton`.

## 0.8.1

* update documentation,
* new tests.

## 0.7.2

* provides a `LocaleManager.realLocaleNotifier` to dynamically change locale (and `LocaleManager.localeNotifier` to
  listen to locale changes),
* factory constructors for `LocaleSwitcher`: `LocaleSwitcher.toggle`, `LocaleSwitcher.menu` or `LocaleSwitcher.custom`,
* various...

## 0.6.4

* added a lot of parameters,
* update icons.

## 0.5.0

* added tooltips,
* update docs and icons.

## 0.4.3

* added `SelectLocaleButton`,
* added function `showSelectLocaleDialog`.

## 0.3.3

* added new parameter: reassignFlags (to change what language had what flag).

## 0.2.2

* Update docs, added example.

## 0.1.0

* Initial release.

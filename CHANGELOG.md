# Changelog

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

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_system_locale.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/preference_repository.dart';

enum IfLocaleNotFound {
  doNothing,
  useFirst,
  useSystem,
}

/// An indexes and notifiers to work with [CurrentLocale.supported].
///
/// [current] and [index] - are pointed at current active entry in
/// [LocaleSwitcher.localeNameFlags], have setters, correspond notifier - [notifier].
///
/// And other useful static methods and properties...
abstract class CurrentLocale extends CurrentSystemLocale {
  /// Global storage of [LocaleNameFlag] - instance of [LocaleNameFlagList].
  ///
  /// [LocaleNameFlag] are wrappers around [Locale]s in supportedLocales list.
  static LocaleNameFlagList get supported => LocaleStore.localeNameFlags;

  static late final ValueNotifier<int> _allNotifiers;
  static final _index = ValueNotifier(0);
  static late final ValueNotifier<Locale> _locale;

  /// Listen on both system locale and currently selected [LocaleNameFlag].
  ///
  /// In case [LocaleStore.systemLocale] is selected: it didn't try to guess
  /// which [LocaleNameFlag] is best match, and just return OS locale.
  /// (You localization system should select best match).
  static ValueNotifier<Locale> get locale {
    try {
      return _locale;
    } catch (e) {
      _locale = ValueNotifier<Locale>(const Locale('en'));
      _locale.value = current.locale!;
      allNotifiers.addListener(() => _locale.value = current.locale!);
      CurrentSystemLocale.currentSystemLocale
          .addListener(() => _allNotifiers.value++);
      return _locale;
    }
  }

  /// Listen on system locale.
  static ValueNotifier<int> get allNotifiers {
    try {
      return _allNotifiers;
    } catch (e) {
      _allNotifiers = ValueNotifier<int>(0);
      notifier.addListener(() => _allNotifiers.value++);
      CurrentSystemLocale.currentSystemLocale
          .addListener(() => _allNotifiers.value++);
      return _allNotifiers;
    }
  }

  /// ValueNotifier of [index] of selected [CurrentLocale.supported].
  static ValueNotifier<int> get notifier => _index;

  /// Index of selected [CurrentLocale.supported].
  ///
  /// Can be set here.
  static int get index => _index.value;

  static set index(int value) {
    if (value < LocaleStore.localeNameFlags.length && value >= 0) {
      if (LocaleStore.localeNameFlags[value].name != showOtherLocales) {
        // just double check
        _index.value = value;

        PreferenceRepository.write(
            LocaleStore.innerSharedPreferenceName, current.name);
      }
    }
  }

  /// Current [LocaleNameFlag] what contains current locale.
  ///
  /// You can update this value directly, or
  /// if you are not sure that your locale exist in list of supportedLocales:
  /// use [CurrentLocale.trySetLocale].
  static LocaleNameFlag get current => LocaleStore.localeNameFlags[index];

  static set current(LocaleNameFlag value) {
    var idx = LocaleStore.localeNameFlags.indexOf(value);
    if (idx >= 0 && idx < LocaleStore.localeNameFlags.length) {
      index = idx;
    } else {
      idx = LocaleStore.localeNameFlags.indexOf(byName(value.name));
      if (idx >= 0 && idx < LocaleStore.localeNameFlags.length) {
        index = idx;
      }
    }
  }

  static LocaleNameFlag? byName(String name) {
    if (supported.names.contains(name)) {
      return supported.entries[supported.names.indexOf(name)];
    }
    return null;
  }

  /// Search by first 2 letter, return first found or null.
  static LocaleNameFlag? byLanguage(String name) {
    final pattern = name.substring(0, 2);
    final String langName = supported.names.firstWhere(
      (element) => element.startsWith(pattern),
      orElse: () => '',
    );
    if (supported.names.contains(langName)) {
      return supported.entries[supported.names.indexOf(langName)];
    }
    return null;
  }

  /// Search by [Locale], return exact match or null.
  static LocaleNameFlag? byLocale(Locale locale) {
    if (supported.locales.contains(locale)) {
      return supported.entries[supported.locales.indexOf(locale)];
    }
    return null;
  }

  /// Will try to find [Locale] by string in [CurrentLocale.supported].
  ///
  /// Just wrapper around: [tryFindLocale] and [CurrentLocale.current] = newValue;
  ///
  /// If not found: do [ifLocaleNotFound]
  static void trySetLocale(String langCode,
      {IfLocaleNotFound ifLocaleNotFound = IfLocaleNotFound.doNothing}) {
    var loc = tryFindLocale(langCode, ifLocaleNotFound: ifLocaleNotFound);
    if (loc != null) {
      CurrentLocale.current = loc;
    }
  }

  /// Will try to find [Locale] by string in [CurrentLocale.supported].
  ///
  /// If not found: do [ifLocaleNotFound]
  // todo: similarity check?
  static LocaleNameFlag? tryFindLocale(String langCode,
      {IfLocaleNotFound ifLocaleNotFound = IfLocaleNotFound.doNothing}) {
    var loc = byName(langCode) ?? byLanguage(langCode);
    if (loc != null) {
      return loc;
    }
    switch (ifLocaleNotFound) {
      case IfLocaleNotFound.doNothing:
        return null;
      case IfLocaleNotFound.useSystem:
        if (byName(LocaleStore.systemLocale) != null) {
          current = byName(LocaleStore.systemLocale)!;
        }
        return null;
      case IfLocaleNotFound.useFirst:
        if (supported.names.first != LocaleStore.systemLocale) {
          current = supported.entries.first;
        } else if (supported.names.length > 2) {
          current = supported.entries[1];
        }
        return null;
    }
  }

  static Widget get buttonFlagForOtherLocales => LocaleSwitcher.iconButton(
        useStaticIcon:
            ((LocaleStore.languageToCountry[showOtherLocales]?.length ?? 0) > 2)
                ? LocaleStore.languageToCountry[showOtherLocales]![2]
                : const Icon(Icons.expand_more),
      );
}

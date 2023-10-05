import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_observable.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/preference_repository.dart';

class CurrentSystemLocale {
  static LocaleObserver? __observer;

  /// Listen on system locale.
  static ValueNotifier<Locale> get currentSystemLocale {
    initSystemLocaleObserver();
    return __currentSystemLocale;
  }

  static final __currentSystemLocale = ValueNotifier(const Locale('en'));

  static void initSystemLocaleObserver() {
    if (__observer == null) {
      WidgetsFlutterBinding.ensureInitialized();
      __observer = LocaleObserver(onChanged: (_) {
        __currentSystemLocale.value =
            TestablePlatformDispatcher.platformDispatcher.locale;
      });
      WidgetsBinding.instance.addObserver(
        __observer!,
      );
    }
  }
}

abstract class CurrentLocale extends CurrentSystemLocale {
  static late final ValueNotifier<int> _allNotifiers;

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

  static LocaleNameFlagList get store => LocaleStore.localeNameFlags;

  static ValueNotifier<int> get notifier => _index;
  static final _index = ValueNotifier(0);

  static int get index => _index.value;

  static set index(int value) {
    if (value < LocaleStore.localeNameFlags.length && value >= 0) {
      _index.value = value;

      PreferenceRepository.write(
          LocaleStore.innerSharedPreferenceName, current.name);
    }
  }

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
    if (store.names.contains(name)) {
      return store.entries[store.names.indexOf(name)];
    }
    return null;
  }

  /// Search by first 2 letter, return first found or null.
  static LocaleNameFlag? byLanguage(String name) {
    final pattern = name.substring(0, 2);
    final String langName = store.names.firstWhere(
      (element) => element.startsWith(pattern),
      orElse: () => '',
    );
    if (store.names.contains(langName)) {
      return store.entries[store.names.indexOf(langName)];
    }
    return null;
  }

  /// Search by [Locale], return exact match or null.
  static LocaleNameFlag? byLocale(Locale locale) {
    if (store.locales.contains(locale)) {
      return store.entries[store.locales.indexOf(locale)];
    }
    return null;
  }

  /// Will try to find [Locale] by string.
  ///
  /// Just wrapper around: [CurrentLocale.current] = newValue;
  ///
  /// If not found: do [ifLocaleNotFound]
  // todo: similarity check?
  static void tryToSetLocale(String langCode,
      {IfLocaleNotFound ifLocaleNotFound = IfLocaleNotFound.doNothing}) {
    var loc = byName(langCode) ?? byLanguage(langCode);
    if (loc != null) {
      current = loc;
      return;
    }
    switch (ifLocaleNotFound) {
      case IfLocaleNotFound.doNothing:
        return;
      case IfLocaleNotFound.useSystem:
        if (byName(LocaleStore.systemLocale) != null) {
          current = byName(LocaleStore.systemLocale)!;
        }
        return;
      case IfLocaleNotFound.useFirst:
        if (store.names.first != LocaleStore.systemLocale) {
          current = store.entries.first;
        } else if (store.names.length > 2) {
          current = store.entries[1];
        }
        return;
    }
  }

  static Widget get flagForOtherLocalesButton => LocaleSwitcher.iconButton(
        useStaticIcon:
            ((LocaleStore.languageToCountry[showOtherLocales]?.length ?? 0) > 2)
                ? LocaleStore.languageToCountry[showOtherLocales]![2]
                : const Icon(Icons.expand_more),
      );
}

enum IfLocaleNotFound {
  doNothing,
  useFirst,
  useSystem,
}

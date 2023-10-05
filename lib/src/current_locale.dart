import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_observable.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/preference_repository.dart';

class CurrentSystemLocale {
  static LocaleObserver? __observer;

  /// Listen on system locale.
  static ValueNotifier<Locale> get currentSystemLocale {
    initSystemLocaleObserverAndLocaleUpdater();
    return __currentSystemLocale;
  }

  static final __currentSystemLocale = ValueNotifier(const Locale('en'));

  static void initSystemLocaleObserverAndLocaleUpdater() {
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

  static LocaleNameFlag? byLocale(Locale locale) {
    if (store.locales.contains(locale)) {
      return store.entries[store.locales.indexOf(locale)];
    }
    return null;
  }

  // todo try more
  // read all user locales? similarity check?
  static void tryToSetLocale(String langCode) {
    var loc = byName(langCode);
    if (loc != null) {
      current = loc; //??  byName(LocaleStore.systemLocale) ;
    }
  }

  static Widget get flagForOtherLocalesButton => LocaleSwitcher.iconButton(
        useStaticIcon:
            ((LocaleStore.languageToCountry[showOtherLocales]?.length ?? 0) > 2)
                ? LocaleStore.languageToCountry[showOtherLocales]![2]
                : const Icon(Icons.expand_more),
      );
}

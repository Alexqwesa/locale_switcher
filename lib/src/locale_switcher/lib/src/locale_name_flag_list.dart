import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_observable.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/preference_repository.dart';

class _CurrentSystemLocale {
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

abstract class CurrentLocale extends _CurrentSystemLocale {
  static late final ValueNotifier<int> _allNotifiers;

  /// Listen on system locale.
  static ValueNotifier<int> get allNotifiers {
    try {
      return _allNotifiers;
    } catch (e) {
      _allNotifiers = ValueNotifier<int>(0);
      notifier.addListener(() => _allNotifiers.value++);
      _CurrentSystemLocale.currentSystemLocale
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

// supportedLocalesWithFlags
// current locale
// with Notifier?
/// A list of generated [LocaleNameFlag]s for supportedLocales.
///
/// [supportedLocales] should be the same as [MaterialApp].supportedLocales
class LocaleNameFlagList with ListMixin<LocaleNameFlag> {
  final List<Locale> supportedLocales;
  final locales = <Locale?>[];
  final names = <String>[];

// final flags = <Widget?>[];

  final entries = <LocaleNameFlag>[];

  LocaleNameFlagList(this.supportedLocales, {bool showOsLocale = true}) {
    if (showOsLocale) {
      locales.add(null);
      names.add(LocaleStore.systemLocale);
      entries.add(
        SystemLocaleNameFlag(flag: findFlagFor(LocaleStore.systemLocale)),
      );
    }

    for (final loc in supportedLocales) {
      locales.add(loc);
      names.add(loc.toString());
      entries.add(
        LocaleNameFlag(name: names.last, locale: locales.last),
      );
    }
  }

  LocaleNameFlagList.fromEntries(
    Iterable<LocaleNameFlag> list, {
    this.supportedLocales = const <Locale>[],
    bool addOsLocale = false,
  }) {
    if (addOsLocale) {
      locales.add(null);
      names.add(LocaleStore.systemLocale);
      entries.add(
        LocaleNameFlag(
            name: names.last,
            locale: locales.last,
            flag: findFlagFor(LocaleStore.systemLocale)),
      );
    }
    entries.addAll(list);
    for (final e in entries) {
      locales.add(e.locale);
      names.add(e.name);
    }
  }

  bool replaceLast({String? str, LocaleNameFlag? localeName}) {
    LocaleNameFlag? entry = localeName;

    if (str != null) {
      entry ??= CurrentLocale.byName(str);
    }
    if (entry != null) {
      locales.last = entry.locale;
      names.last = entry.name;
      entries.last = entry;
      return true;
    }
    return false;
// final loc = str.toLocale();
// locales.last = loc;
// names.last = loc.toString();
// entries.last = LocaleNameFlag(
//     name: names.last, locale: locales.last, flag: flags.last);
  }

  /// Will search [LocaleStore.localeNameFlags] for name and add it.
  void addName(String str) {
    if (str == showOtherLocales) {
      locales.add(null);
      names.add(showOtherLocales);
      entries.add(
        LocaleNameFlag(
            name: names.last,
            locale: locales.last,
            flag: CurrentLocale.flagForOtherLocalesButton),
      );
    } else {
      final entry = CurrentLocale.byName(str);
      if (entry != null) {
        locales.add(entry.locale);
        names.add(entry.name);
        entries.add(entry);
      }
    }
  }

  @override
  int get length => entries.length;

  @override
  operator [](int index) {
    return entries[index];
  }

  @override
  void operator []=(int index, LocaleNameFlag entry) {
    locales[index] = entry.locale;
    names[index] = entry.name;
    entries[index] = entry;
  }

  @override
  set length(int newLength) {
    entries.length = newLength;
    locales.length = newLength;
    names.length = newLength;
  }
}

/// Just record of [Locale], it's name and flag.
class LocaleNameFlag {
  String? _language;

  Widget? _flag;

  final String name;

  final Locale? locale;

  LocaleNameFlag({
    this.name = '',
    this.locale,
    Widget? flag,
    String? language,
  })  : _flag = flag,
        _language = language;

  Widget? get flag {
    // todo not null
    _flag ??= locale?.flag() ?? findFlagFor(name);
    return _flag;
  }

  String get language {
    _language ??= (LocaleStore.languageToCountry[name]?[1]! ??
            LocaleStore.languageToCountry[name.substring(0, 2)]) ??
        '';
    return _language!;
  }
}

/// Just record of [Locale], it's name and flag.
class SystemLocaleNameFlag extends LocaleNameFlag {
  @override
  Locale get locale => _CurrentSystemLocale.currentSystemLocale.value;

  ValueNotifier<Locale> get notifier =>
      _CurrentSystemLocale.currentSystemLocale;

  SystemLocaleNameFlag({
    super.flag,
    super.language,
  }) : super(name: LocaleStore.systemLocale);
}

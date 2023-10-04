import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

class _LocaleNameList {
  static final _index = ValueNotifier(0);


}

// supportedLocalesWithFlags
// current locale
// with Notifier?
/// Generate [LocaleNameFlag]s for supportedLocales.
///
/// [supportedLocales] should be the same as [MaterialApp].supportedLocales
class LocaleNameFlagList extends _LocaleNameList
    with ListMixin<LocaleNameFlag> {
  final List<Locale> supportedLocales;
  final locales = <Locale?>[];
  final names = <String>[];

// final flags = <Widget?>[];

  final entries = <LocaleNameFlag>[];

  int get index => _LocaleNameList._index.value;

  set index(int value) {
    if (value < length && value >= 0) {
      _LocaleNameList._index.value = value;
    }
  }

  LocaleNameFlag get current => LocaleStore.localeNameFlags[index];

  set current(LocaleNameFlag value) {
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

  LocaleNameFlagList(this.supportedLocales, {bool showOsLocale = true}) {
    if (showOsLocale) {
      locales.add(null);
      names.add(LocaleStore.systemLocale);
      entries.add(
        LocaleNameFlag(
            name: names.last,
            locale: locales.last,
            flag: findFlagFor(LocaleStore.systemLocale)),
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

  LocaleNameFlag? byName(String name) {
    if (names.contains(name)) {
      return entries[names.indexOf(name)];
    }
    return null;
  }

  LocaleNameFlag? byLocale(Locale locale) {
    if (locales.contains(locale)) {
      return entries[locales.indexOf(locale)];
    }
    return null;
  }

  bool replaceLast(String str) {
    final entry = LocaleStore.localeNameFlags.byName(str);
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

  static Widget get flagForOtherLocalesButton => LocaleSwitcher.iconButton(
        useStaticIcon:
            ((LocaleStore.languageToCountry[showOtherLocales]?.length ?? 0) > 2)
                ? LocaleStore.languageToCountry[showOtherLocales]![2]
                : const Icon(Icons.expand_more),
      );

  /// Will search [LocaleStore.localeNameFlags] for name and add it.
  void addName(String str) {
    if (str == showOtherLocales) {
      locales.add(null);
      names.add(showOtherLocales);
      entries.add(
        LocaleNameFlag(
            name: names.last,
            locale: locales.last,
            flag: flagForOtherLocalesButton),
      );
    } else {
      final entry = LocaleStore.localeNameFlags.byName(str);
      if (entry != null) {
        locales.add(entry.locale);
        names.add(entry.name);
        entries.add(entry);
      }
    }
  }

// @override
// Iterable<T> map<T>(T Function(LocaleNameFlag e) f) => entries.map<T>(f);

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

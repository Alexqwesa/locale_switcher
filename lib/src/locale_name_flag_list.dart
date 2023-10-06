import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_system_locale.dart';
import 'package:locale_switcher/src/locale_store.dart';

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
            flag: CurrentLocale.buttonFlagForOtherLocales),
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

  /// Add special entry into [LocaleNameFlagList].
  ///
  /// You should make sure to handle this entry selection in your widget.
  // todo: {Null Function() onTap = ...}
  void addShowOtherLocales({String name = showOtherLocales, Widget? flag}) {
    locales.add(null);
    names.add(showOtherLocales);
    entries.add(
      LocaleNameFlag(
          name: names.last,
          locale: locales.last,
          flag: flag ?? CurrentLocale.buttonFlagForOtherLocales),
    );
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
    _flag ??= locale?.flag(fallBack: null) ??
        (locale == null ? findFlagFor(name) : null);
    return _flag;
  }

  String get language {
    _language ??= (LocaleStore.languageToCountry[name]?[1] ??
            LocaleStore.languageToCountry[name.substring(0, 2)]?[0]) ??
        name;
    return _language!;
  }
}

/// Just record of [Locale], it's name and flag.
class SystemLocaleNameFlag extends LocaleNameFlag {
  @override
  Locale get locale => CurrentSystemLocale.currentSystemLocale.value;

  ValueNotifier<Locale> get notifier => CurrentSystemLocale.currentSystemLocale;

  SystemLocaleNameFlag({
    super.flag,
    super.language,
  }) : super(name: LocaleStore.systemLocale);
}

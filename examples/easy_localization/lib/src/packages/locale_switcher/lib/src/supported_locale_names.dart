import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// A list of generated [LocaleName]s for supportedLocales.
///
/// [supportedLocales] should be the same as [MaterialApp].supportedLocales
class SupportedLocaleNames with ListMixin<LocaleName> {
  final List<Locale> supportedLocales;
  final locales = <Locale?>[];
  final names = <String>[];
  final entries = <LocaleName>[];

  SupportedLocaleNames(this.supportedLocales, {bool showOsLocale = true}) {
    if (showOsLocale) {
      locales.add(null);
      names.add(systemLocale);
      entries.add(
        LocaleName.system(flag: findFlagFor(language: systemLocale)),
      );
    }

    for (final loc in supportedLocales) {
      locales.add(loc);
      names.add(loc.toString().toLowerCase());
      entries.add(
        LocaleName(name: names.last, locale: locales.last),
      );
    }
  }

  SupportedLocaleNames.fromEntries(
    Iterable<LocaleName> list, {
    this.supportedLocales = const <Locale>[],
    bool addOsLocale = false,
  }) {
    if (addOsLocale) {
      locales.add(null);
      names.add(systemLocale);
      entries.add(
        LocaleName.system(flag: findFlagFor(language: systemLocale)),
      );
    }
    entries.addAll(list);
    for (final e in entries) {
      locales.add(e.locale);
      names.add(e.name);
    }
  }

  bool replaceLast({String? str, LocaleName? localeName}) {
    LocaleName? entry = localeName;

    if (str != null) {
      entry ??= LocaleMatcher.byName(str);
    }
    if (entry != null) {
      locales.last = entry.locale;
      names.last = entry.name;
      entries.last = entry;
      return true;
    }
    return false;
  }

  /// Will search [LocaleStore.supportedLocaleNames] for name and add it.
  bool addName(String str) {
    if (str == showOtherLocales) {
      addShowOtherLocales();
      return true;
    } else {
      final entry = LocaleMatcher.byName(str);
      if (entry != null && !entries.contains(entry)) {
        locales.add(entry.locale);
        names.add(entry.name);
        entries.add(entry);
        return true;
      }
    }
    return false;
  }

  @override
  int get length => entries.length;

  @override
  operator [](int index) {
    return entries[index];
  }

  @override
  void operator []=(int index, LocaleName entry) {
    locales[index] = entry.name == systemLocale ? null : entry.locale;
    names[index] = entry.name;
    entries[index] = entry;
  }

  @override
  set length(int newLength) {
    entries.length = newLength;
    locales.length = newLength;
    names.length = newLength;
  }

  /// Add special entry into [SupportedLocaleNames].
  ///
  /// You should make sure to handle this entry selection in your widget.
  // todo: {Null Function() onTap = ...}
  void addShowOtherLocales({
    String name = showOtherLocales,
    Widget? flag,
    // Function(BuildContext)? setLocaleCallBack,
  }) {
    locales.add(null);
    names.add(showOtherLocales);
    entries.add(
      LocaleName(
          name: names.last,
          locale: locales.last,
          flag: flag ?? flagForOtherLocales),
      // setLocaleCallBack: setLocaleCallBack
    );
  }

  /// Just flag for [showOtherLocales].
  static Widget get flagForOtherLocales =>
      ((languageToCountry[showOtherLocales]?.length ?? 0) > 2)
          ? languageToCountry[showOtherLocales]![2]
          : const Icon(Icons.expand_more);
}

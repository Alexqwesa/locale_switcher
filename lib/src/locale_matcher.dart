import 'dart:ui';

import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// Parameter for [LocaleMatcher.trySetLocale] and [LocaleMatcher.tryfindLocale].
enum IfLocaleNotFound {
  doNothing,
  useFirst,
  useSystem,
}

/// Helper, allow to find [LocaleName] in [LocaleSwitcher.supportedLocaleNames].
class LocaleMatcher {
  /// Global storage of [LocaleName] - instance of [SupportedLocaleNames].
  static SupportedLocaleNames get supported => LocaleStore.supportedLocaleNames;

  static LocaleName? byName(String name) {
    if (supported.names.contains(name.toLowerCase())) {
      return supported.entries[supported.names.indexOf(name.toLowerCase())];
    }
    return null;
  }

  /// Search by first 2 letter, return first found or null.
  static LocaleName? byLanguage(String name) {
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
  static LocaleName? byLocale(Locale locale) {
    if (supported.locales.contains(locale)) {
      return supported.entries[supported.locales.indexOf(locale)];
    }
    return null;
  }

  /// Try to set [Locale] by string in [LocaleSwitcher.supportedLocaleNames].
  ///
  /// Just wrapper around: [tryFindLocale] and [LocaleSwitcher.current] = newValue;
  ///
  /// If not found: do [ifLocaleNotFound]
  static void trySetLocale(String langCode,
      {IfLocaleNotFound ifLocaleNotFound = IfLocaleNotFound.doNothing}) {
    var loc = tryFindLocale(langCode, ifLocaleNotFound: ifLocaleNotFound);
    if (loc != null) {
      LocaleSwitcher.current = loc;
    }
  }

  /// Try to find [Locale] by string in [LocaleSwitcher.supportedLocaleNames].
  ///
  /// If not found: do [ifLocaleNotFound]
  // todo: similarity check?
  static LocaleName? tryFindLocale(String langCode,
      {IfLocaleNotFound ifLocaleNotFound = IfLocaleNotFound.doNothing}) {
    var loc = byName(langCode) ?? byLanguage(langCode);
    if (loc != null) {
      return loc;
    }
    switch (ifLocaleNotFound) {
      case IfLocaleNotFound.doNothing:
        return null;
      case IfLocaleNotFound.useSystem:
        if (byName(systemLocale) != null) {
          return byName(systemLocale)!;
        }
        return null;
      case IfLocaleNotFound.useFirst:
        if (supported.names.first != systemLocale) {
          return supported.entries.first;
        } else if (supported.names.length > 2) {
          return supported.entries[1];
        }
        return null;
    }
  }
}

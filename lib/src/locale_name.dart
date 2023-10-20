import 'package:flutter/widgets.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/system_locale_name.dart';

/// Wrapper around [Locale], it's name, flag, language and few helpers.
///
/// Created to allow special names, like: [showOtherLocales] and [systemLocale].
///
/// A [bestMatch] is either locale itself OR - for system locale - closest match.
class LocaleName {
  /// cache
  String? _language;

  /// cache
  Widget? _flag;

  /// Either [Locale].toString() or one of special names, like: [systemLocale] or [showOtherLocales].
  final String name;

  /// Is [Locale] for ordinary locales, null for [showOtherLocales], dynamic for [systemLocale].
  ///
  /// For [systemLocale] it can return unsupported locale,
  /// use [bestMatch] to be sure that returned locale is in [supportedLocales] list.
  final Locale? locale;

  @override
  String toString() {
    return '$name|${locale?.languageCode}';
  }

  /// Exact [Locale] for regular locales, and guess for [systemLocale].
  ///
  /// Unlike [locale] properties, it try to find matching locale in [supportedLocales].
  Locale get bestMatch {
    // exact
    if (name != systemLocale &&
        name != showOtherLocales &&
        LocaleStore.supportedLocaleNames.names.contains(name)) {
      return LocaleSwitcher.current.locale!;
    }
    // guess
    switch (name) {
      case showOtherLocales:
        if (LocaleStore.supportedLocaleNames.length > 2) {
          return LocaleStore.supportedLocaleNames[1].locale ??
              const Locale('en');
        } else {
          return const Locale('en');
        }
      case systemLocale:
        return LocaleMatcher.tryFindLocale(locale!.toString())?.locale ??
            const Locale('en');
      default:
        return locale ?? const Locale('en');
    }
  }

  LocaleName({
    this.name = '',
    this.locale,
    Widget? flag,
    String? language,
  })  : _flag = flag,
        _language = language;

  /// Find flag for [name].
  ///
  /// Search in [LocaleManager.reassignFlags] for locale first, then [Flags.instance].
  ///
  /// For systemLocale or [showOtherLocales] only look into [LocaleManager.reassignFlags].
  Widget? get flag {
    if (name == showOtherLocales || name == systemLocale) {
      if (languageToCountry[name] != null &&
          languageToCountry[name]!.length > 2) {
        _flag = languageToCountry[name]?[2];
      }
    }
    _flag ??= locale?.flag(fallBack: null);
    if (_flag == null && locale?.toString() != name) {
      _flag = findFlagFor(language: name);
    }
    return _flag;
  }

  /// Search in [LocaleManager.reassignFlags] first, and if not found return [name].
  String get language {
    _language ??= (languageToCountry[name.toLowerCase()]?[1] ??
            languageToCountry[name.substring(0, 2).toLowerCase()]?[1]) ??
        name;
    return _language!;
  }

  /// A special [LocaleName] for [systemLocale].
  factory LocaleName.system({Widget? flag}) {
    return SystemLocaleName(flag: flag);
  }
}

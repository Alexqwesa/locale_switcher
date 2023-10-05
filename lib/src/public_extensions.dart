import 'package:flutter/widgets.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';
import 'package:locale_switcher/src/locale_store.dart';

extension StringToLocale on String {
  /// Convert string to [Locale] object
  Locale toLocale({String separator = '_'}) {
    final localeList = split(separator);
    switch (localeList.length) {
      case 2:
        return localeList.last.length == 4 // scriptCode length is 4
            ? Locale.fromSubtags(
                languageCode: localeList.first,
                scriptCode: localeList.last,
              )
            : Locale(localeList.first, localeList.last);
      case 3:
        return Locale.fromSubtags(
          languageCode: localeList.first,
          scriptCode: localeList[1],
          countryCode: localeList.last,
        );
      default:
        return Locale(localeList.first);
    }
  }
}

enum LocaleNotFoundFallBack {
  full,
  countryCodeThenFull,
  countryCodeThenNull,
}

Widget? findFlagFor(String str) {
  final value = LocaleStore.languageToCountry[str] ?? const [];
  if (value.length > 2 && value[2] != null) return value[2];
  if (countryCodeToContent.containsKey((value[0] as String).toLowerCase())) {
    return Flags.instance[value[0]]?.svg;
  }
  return null;
}

extension LocaleFlag on Locale {
  /// Search for flag for given locale
  Widget? flag(
      {LocaleNotFoundFallBack? fallBack = LocaleNotFoundFallBack.full}) {
    final str = toString();
    // check full
    final flag = findFlagFor(str);
    if (flag != null) return flag;

    final localeList = str.split('_');
    // create fallback
    Widget? fb;
    if (fallBack != null) {
      if (fallBack == LocaleNotFoundFallBack.full) {
        fb = Text(str);
      } else if (fallBack == LocaleNotFoundFallBack.countryCodeThenFull) {
        if (localeList.length > 1) {
          fb = Text(localeList.last);
        } else {
          fb = Text(str);
        }
      }
      // else {
      //   fb = Text(str.substring(0, 2));
      // }
    }

    switch (localeList.length) {
      case 1:
      // already checked by findFlagFor(str)
      case 2:
        if (localeList.last.length != 4) {
          // second is not scriptCode
          return findFlagFor(localeList.last) ?? fb;
        } else {
          return findFlagFor(localeList.first) ?? fb;
        }
      case 3:
        final flag = findFlagFor(localeList.last);
        if (flag != null) return flag;
        return findFlagFor(localeList.first) ?? fb;
      default:
        return fb;
    }
  }
}

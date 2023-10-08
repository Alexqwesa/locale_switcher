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

enum FlagNotFoundFallBack {
  full,
  countryCodeThenFull,
  countryCodeThenNull,
}

Widget? findFlagFor({String? language, String? country}) {
  if (language != null) {
    final str = language.toLowerCase();
    if (LocaleStore.languageToCountry.containsKey(str)) {
      final value = LocaleStore.languageToCountry[str];
      if (value != null) {
        if (value.length > 2 && value[2] != null) return value[2];
        return findFlagFor(country: value[0]);
      }
    }
  }
  if (country != null) {
    final str = country.toLowerCase();
    if (countryCodeToContent.containsKey(str)) {
      return Flags.instance[str]?.svg;
    }
  }
  return null;
}

extension LocaleFlag on Locale {
  /// Search for flag for given locale
  Widget? flag({FlagNotFoundFallBack? fallBack = FlagNotFoundFallBack.full}) {
    final str = toString();
    // check full
    var flag = findFlagFor(language: str);

    if (flag != null) return flag;

    final localeList = str.split('_');
    // create fallback
    Widget? fb;
    if (fallBack != null) {
      if (fallBack == FlagNotFoundFallBack.full) {
        fb = Text(str);
      } else if (fallBack == FlagNotFoundFallBack.countryCodeThenFull) {
        if (localeList.length > 1) {
          fb = Text(localeList.last);
        } else {
          fb = Text(str);
        }
      }
    }

    if (str.length > 2) {
      fb = findFlagFor(language: str.substring(0, 2)) ?? fb;
    }

    switch (localeList.length) {
      case 1:
      // already checked by findFlagFor(str)
      case 2:
        if (localeList.last.length != 4) {
          // second is not scriptCode
          return findFlagFor(country: localeList.last) ?? fb;
        } else {
          return fb;
        }
      case 3:
        return findFlagFor(country: localeList.last) ?? fb;
      default:
        return fb;
    }
  }
}

// extension AppLocalizationsExt on BuildContext {
//   AppLocalizations get l10n => AppLocalizations.of(this);
// }

// extension LocaleWithDelegate on Locale {
//   /// Get class with translation strings for this locale.
//   AppLocalizations get tr => lookupAppLocalizations(this);
// }

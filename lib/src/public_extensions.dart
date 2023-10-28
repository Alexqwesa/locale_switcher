import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';

/// Map language to country, (and -optionally- a custom flag).
///
/// Keys are in lowerCase!, can be just language or full locale name.
/// Value is a list of: country code, language name and (optionally) flag widget.
///
/// You can also use [LocaleManager.reassignFlags] to update these values.
///
/// Do not remove first two keys!
// https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry
final Map<String, List<dynamic>> languageToCountry = {
  /// special entry name for [LocaleSwitcher.supportedLocaleNames] - OS locale
  systemLocale: [
    'System',
    'OS locale',
    // if (!kIsWeb && Platform.isAndroid) const Icon(Icons.android),
    // if (!kIsWeb && Platform.isIOS) const Icon(Icons.phone_iphone),
    const Icon(Icons.language),
  ],

  /// special entry name for [LocaleSwitcher.supportedLocaleNames]
  showOtherLocales: [
    'Other',
    'Show other locales',
    const Icon(Icons.expand_more)
  ],
  // English
  'en': ['US', 'English'],
  // Spanish
  'es': ['ES', 'Español'],
  // French
  'fr': ['FR', 'Français'],
  // German
  'de': ['DE', 'Deutsch'],
  // Italian
  'it': ['IT', 'Italiano'],
  // Portuguese
  'pt': ['BR', 'Português'],
  // Dutch
  'nl': ['NL', 'Nederlands'],
  // Russian
  'ru': ['RU', 'Русский'],
  // Chinese (Simplified)
  'zh': ['CN', '中文'],
  // Japanese
  'ja': ['JP', '日本語'],
  // Korean
  'ko': ['KR', '한국어'],
  // Arabic
  'ar': ['SA', 'العربية'],
  // Hindi
  'hi': ['IN', 'हिन्दी'],
  // Bengali
  'bn': ['BD', 'বাঙালি'],
  // Turkish
  'tr': ['TR', 'Türkçe'],
  // Vietnamese
  'vi': ['VN', 'Tiếng Việt'],
  // Greek
  'el': ['GR', 'Ελληνικά'],
  // Polish
  'pl': ['PL', 'Polski'],
  // Ukrainian
  'uk': ['UA', 'Українська'],
  // Thai
  'th': ['TH', 'ไทย'],
  // Indonesian
  'id': ['ID', 'Bahasa Indonesia'],
  // Malay
  'ms': ['MY', 'Bahasa Melayu'],
  // Swedish
  'sv': ['SE', 'Svenska'],
  // Finnish
  'fi': ['FI', 'Suomi'],
  // Norwegian
  'no': ['NO', 'Norsk'],
};

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

/// Parameter for [Locale.flag] extension.
enum FlagNotFoundFallBack {
  /// if not found - return [Locale].toString()
  full,

  /// if not found - return emoji or [Locale].toString()
  emojiThenFull,

  /// if not found - return [Locale.countryCode] string or [Locale].toString()
  countryCodeThenFull,

  /// if not found - return emoji or [Locale.countryCode] string or [Locale].toString()
  emojiThenCountryCodeThenFull,

  /// if not found - return [Locale.countryCode] string or null
  countryCodeThenNull,

  // todo: more options
}

/// Try to find a flag by language or country string.
Widget? findFlagFor({String? language, String? country}) {
  if (language != null) {
    final str = language.toLowerCase();
    if (languageToCountry.containsKey(str)) {
      final value = languageToCountry[str];
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

/// Offset of the emoji flags in Unicode table.
const emojiOffset = 127397;

extension LocaleFlag on Locale {
  /// Return Unicode character with flag or languageCode.
  ///
  /// Search by country code first, then by [languageToCountry] map, if not found
  /// return [languageCode]
  ///
  /// Note: flag may look different for different platforms!.
  ///
  /// Note 2: svg images in this package is simplified to look good at small size,
  /// these emoji may not.
  String get emoji {
    // Emoji for country
    if (countryCode?.length == 2) {
      return String.fromCharCodes([
        countryCode!.codeUnitAt(0) + emojiOffset,
        countryCode!.codeUnitAt(1) + emojiOffset
      ]);
    }

    // get country's code from languageToCountry
    final str = languageCode.toLowerCase();
    if (languageToCountry.containsKey(str)) {
      final value = languageToCountry[str];
      if (value != null && value.length > 1) {
        final cc = (value[0] as String).toUpperCase().codeUnits;
        // todo: check range!
        return String.fromCharCodes([cc[0] + emojiOffset, cc[1] + emojiOffset]);
      }
    }

    return countryCode ?? languageCode;
  }

  /// Search for a flag for the given locale
  Widget? flag(
      {FlagNotFoundFallBack? fallBack = FlagNotFoundFallBack.emojiThenFull}) {
    final str = toString();

    // check full
    var flag = findFlagFor(language: str);
    if (flag != null) return flag;

    final localeList = str.split('_');
    // create fallback
    Widget? fb;
    switch (fallBack) {
      case null:
      // nothing
      case FlagNotFoundFallBack.full:
        fb = Text(str);
      case FlagNotFoundFallBack.emojiThenFull:
        final em = emoji;
        if (em != languageCode && em != countryCode) {
          fb = Text(em);
        } else {
          fb = Text(str);
        }
      case FlagNotFoundFallBack.countryCodeThenFull:
        if (localeList.length > 1) {
          fb = Text(localeList.last);
        } else {
          fb = Text(str);
        }
      case FlagNotFoundFallBack.emojiThenCountryCodeThenFull:
        final em = emoji;
        if (em != languageCode && em != countryCode) {
          fb = Text(em);
        } else {
          if (localeList.length > 1) {
            fb = Text(localeList.last);
          } else {
            fb = Text(str);
          }
        }
      case FlagNotFoundFallBack.countryCodeThenNull:
        if (localeList.length > 1) {
          fb = Text(localeList.last);
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

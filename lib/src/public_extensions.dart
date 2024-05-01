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
///
/// Ref: https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry
// todo use record instead of list
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

  // Bengali
  'bn': ['BD', 'বাঙালি'],
  // Greek
  'el': ['GR', 'Ελληνικά'],

  // Afrikaans
  'af': ['ZA', 'Afrikaans'],
  // Akan
  'ak': ['GH', 'Akan'],
  // Amharic
  'am': ['ET', 'Amharic'],
  // Arabic (Iraq)
  'ar_iq': ['IQ', 'Arabic (Iraq)'],
  // Arabic
  'ar': ['SA', 'العربية'],
  // Aymara
  'ay': ['BO', 'Aymara'],
  // Azerbaijani
  'az': ['AZ', 'Azerbaijani'],
  // Belarusian
  'be': ['BY', 'Belarusian'],
  // Bulgarian
  'bg': ['BG', 'Bulgarian'],
  // Bislama
  'bi': ['VU', 'Bislama'],
  // Bambara
  'bm': ['ML', 'Bambara'],
  // Bosnian
  'bs': ['BA', 'Bosnian'],
  // Catalan
  'ca': ['ES', 'Catalan'],
  // Cebuano
  'ceb': ['PH', 'Cebuano'],
  // Chamorro
  'ch': ['GU', 'Chamorro'],
  // Mari
  'chm': ['RU', 'Mari'],
  // Corsican
  'co': ['FR', 'Corsican'],
  // Czech
  'cs': ['CZ', 'Czech'],
  // Welsh
  'cy': ['GB', 'Welsh'],
  // Danish
  'da': ['DK', 'Danish'],
  // German
  'de': ['DE', 'Deutsch'],
  // Divehi
  'dv': ['MV', 'Divehi'],
  // Dzongkha
  'dz': ['BT', 'Dzongkha'],

  // English (Australia)
  'en_au': ['AU', 'English (Australia)'],
  // English (Canada)
  'en_ca': ['CA', 'English (Canada)'],
  // English (India)
  'en_in': ['IN', 'English (India)'],
  // English (Nigeria)
  'en_ng': ['NG', 'English (Nigeria)'],
  // English (New Zealand)
  'en_nz': ['NZ', 'English (New Zealand)'],
  // English (South Africa)
  'en_za': ['ZA', 'English (South Africa)'],
  // English
  'en': ['US', 'English'],
  // English Great Britain
  'en_gb': ['GB', 'English(Britain)'],

  // Hindi
  'hi': ['IN', 'हिन्दी'],
  // Bhojpuri
  'bho': ['IN', 'Bhojpuri'],
  // Assamese
  'as': ['IN', 'Assamese'],
  // Punjabi
  'pa': ['IN', 'Punjabi'],
  // Tamil
  'ta': ['IN', 'Tamil'],
  // Telugu
  'te': ['IN', 'Telugu'],
  // Gujarati
  'gu': ['IN', 'Gujarati'],
  // Kannada
  'kn': ['IN', 'Kannada'],
  // Malayalam
  'ml': ['IN', 'Malayalam'],
  // Marathi
  'mr': ['IN', 'Marathi'],

  // Spanish
  'es': ['ES', 'Español'],
  // Estonian
  'et': ['EE', 'Estonian'],
  // Basque - Spain and France
  'eu': ['ES', 'Basque'],
  // Persian
  'fa': ['IR', 'Persian'],

  // Finnish
  'fi': ['FI', 'Suomi'],
  // Filipino
  'fil': ['PH', 'Filipino'],
  // Fijian
  'fj': ['FJ', 'Fijian'],
  // Faroese
  'fo': ['FO', 'Faroese'],
  // French
  'fr': ['FR', 'Français'],
  // Irish
  'ga': ['IE', 'Irish'],
  // Galician
  'gl': ['ES', 'Galician'],
  // Guarani
  'gn': ['PY', 'Guarani'],
  // Manx
  'gv': ['IM', 'Manx'],
  // Hausa
  'ha': ['NG', 'Hausa'],
  // Hawaiian
  'haw': ['US', 'Hawaiian'],
  // Hebrew
  'he': ['IL', 'Hebrew'],

  // Hiri Motu
  'ho': ['PG', 'Hiri Motu'],
  // Croatian
  'hr': ['HR', 'Croatian'],
  // Haitian
  'ht': ['HT', 'Haitian'],
  // Hungarian
  'hu': ['HU', 'Hungarian'],
  // Armenian
  'hy': ['AM', 'Armenian'],
  // Indonesian
  'id': ['ID', 'Bahasa Indonesia'],
  // Igbo
  'ig': ['NG', 'Igbo'],
  // Iloko
  'ilo': ['PH', 'Iloko'],
  // Icelandic +
  'icl': ['IS', 'Icelandic'],
  // Italian
  'it': ['IT', 'Italiano'],
  // Japanese
  'ja': ['JP', '日本語'],
  // Javanese
  'jv': ['ID', 'Javanese'],
  // Georgian
  'ka': ['GE', 'Georgian'],
  // Kazakh
  'kk': ['KZ', 'Kazakh'],
  // Kalaallisut
  'kl': ['GL', 'Kalaallisut'],
  // Central Khmer
  'km': ['KH', 'Central Khmer'],

  // Korean
  'ko': ['KR', '한국어'],
  // Krio
  'kri': ['SL', 'Krio'],
  // Kurdish
  'ku': ['TR', 'Kurdish'],
  // Kirghiz
  'ky': ['KG', 'Kirghiz'],
  // Latin
  'la': ['VA', 'Latin'],
  // Luxembourgish
  'lb': ['LU', 'Luxembourgish'],
  // Ganda
  'lg': ['UG', 'Ganda'],
  // Lingala
  'ln': ['CD', 'Lingala'],
  // Lao
  'lo': ['LA', 'Lao'],
  // Lithuanian
  'lt': ['LT', 'Lithuanian'],
  // Luba-Katanga
  'lu': ['CD', 'Luba-Katanga'],
  // Latvian
  'lv': ['LV', 'Latvian'],
  // Malagasy
  'mg': ['MG', 'Malagasy'],
  // Marshallese
  'mh': ['MH', 'Marshallese'],
  // Maori
  'mi': ['NZ', 'Maori'],
  // Macedonian
  'mk': ['MK', 'Macedonian'],
  // Mongolian
  'mn': ['MN', 'Mongolian'],
  // Malay
  'ms': ['MY', 'Malay'],
  // Maltese
  'mt': ['MT', 'Maltese'],
  // Burmese
  'my': ['MM', 'Burmese'],
  // Nauru
  'na': ['NR', 'Nauru'],
  // North Ndebele
  'nd': ['ZW', 'North Ndebele'],
  // Nepali
  'ne': ['NP', 'Nepali'],
  // Nederlands
  // Belgium
  // Suriname
  // France (Nord)
  'nl': ['NL', 'Dutch'],

  // Norwegian
  'no': ['NO', 'Norsk'],
  // Norwegian Bokmål
  'nb': ['NO', 'Norwegian Bokmål'],
  // Norwegian Nynorsk
  'nn': ['NO', 'Norwegian Nynorsk'],

  // South Ndebele
  'nr': ['ZA', 'South Ndebele'],
  // Chichewa
  'ny': ['MW', 'Chichewa'],
  // Papiamento
  'pap': ['AW', 'Papiamento'],
  // Polish
  'pl': ['PL', 'Polski'],
  // Pashto
  'ps': ['AF', 'Pashto'],
  // Portuguese (Brazil)
  'pt_br': ['BR', 'Português (Brazil)'],
  // Portuguese
  'pt': ['PT', 'Português'],
  // Rundi
  'rn': ['BI', 'Rundi'],
  // Romanian
  'ro': ['RO', 'Romanian'],

  // Russian
  'ru': ['RU', 'Русский'],
  // Western Mari
  'mrj': ['RU', 'Western Mari'],

  // Kinyarwanda
  'rw': ['RW', 'Kinyarwanda'],
  // Sindhi
  'sd': ['PK', 'Sindhi'],
  // Sango
  'sg': ['CF', 'Sango'],
  // Sinhala
  'si': ['LK', 'Sinhala'],
  // Slovak
  'sk': ['SK', 'Slovak'],
  // Slovenian
  'sl': ['SI', 'Slovenian'],
  // Samoan
  'sm': ['WS', 'Samoan'],
  // Shona
  'sn': ['ZW', 'Shona'],
  // Somali
  'so': ['SO', 'Somali'],
  // Albanian
  'sq': ['AL', 'Albanian'],
  // Serbian
  'sr': ['RS', 'Serbian'],
  // Swati
  'ss': ['SZ', 'Swati'],
  // Southern Sotho
  'st': ['LS', 'Southern Sotho'],
  // Sundanese
  'su': ['ID', 'Sundanese'],
  // Swedish
  'sv': ['SE', 'Svenska'],
  // Swahili
  'sw': ['TZ', 'Swahili'],
  // Tajik
  'tg': ['TJ', 'Tajik'],
  // Thai
  'th': ['TH', 'ไทย'],
  // Turkmen
  'tk': ['TM', 'Turkmen'],
  // Tagalog
  'tl': ['PH', 'Tagalog'],
  // Tswana
  'tn': ['BW', 'Tswana'],
  // Tonga
  'to': ['TO', 'Tonga'],
  // Turkish
  'tr': ['TR', 'Türkçe'],
  // Tahitian
  'ty': ['PF', 'Tahitian'],
  // Ukrainian
  'uk': ['UA', 'Українська'],
  // Urdu
  'ur': ['PK', 'Urdu'],
  // Uzbek
  'uz': ['UZ', 'Uzbek'],
  // Vietnamese
  'vi': ['VN', 'Tiếng Việt'],
  // Xhosa
  'xh': ['ZA', 'Xhosa'],
  // Unknown Language
  'xx': ['XX', 'Unknown Language'],
  // Yiddish
  'yi': ['US', 'Yiddish'],
  // Yoruba
  'yo': ['NG', 'Yoruba'],
  // Yucateco
  'yua': ['MX', 'Yucateco'],
  // Chinese - Traditional
  'zh_tw': ['TW', 'Chinese - Traditional'],
  // Chinese
  'zh': ['CN', '中文'],
  // Zulu
  'zu': ['ZA', 'Zulu']
};

/// For [MultiLangCountries.auto] - country most popular language.
///
/// Note: pairs like 'tr': 'tr' are assumed automatically, you don't need to add them.
final popularInCountry = {'us': 'en', 'in': 'hi', 'zh': 'cn'};

/// A map to connect language to country, only for country with multiple languages.
final countriesWithMulti = <String, String>{
  'lu': 'CD',
  'ln': 'CD',
  'ca': 'ES',
  'es': 'ES',
  'eu': 'ES',
  'gl': 'ES',
  'co': 'FR',
  'fr': 'FR',
  'su': 'ID',
  'id': 'ID',
  'jv': 'ID',
  'kn': 'IN',
  'pa': 'IN',
  'ta': 'IN',
  'te': 'IN',
  'gu': 'IN',
  'ml': 'IN',
  'mr': 'IN',
  'en_in': 'IN',
  'as': 'IN',
  'bho': 'IN',
  'hi': 'IN',
  'yo': 'NG',
  'en_ng': 'NG',
  'ha': 'NG',
  'ig': 'NG',
  'no': 'NO',
  'nn': 'NO',
  'nb': 'NO',
  'en_nz': 'NZ',
  'mi': 'NZ',
  'ceb': 'PH',
  'ilo': 'PH',
  'fil': 'PH',
  'tl': 'PH',
  'ur': 'PK',
  'sd': 'PK',
  'ru': 'RU',
  'mrj': 'RU',
  'chm': 'RU',
  'ku': 'TR',
  'tr': 'TR',
  'en': 'US',
  'yi': 'US',
  'haw': 'US',
  'zu': 'ZA',
  'nr': 'ZA',
  'af': 'ZA',
  'xh': 'ZA',
  'en_za': 'ZA',
  'nd': 'ZW',
  'sn': 'ZW',
};

/// Extension on [String] to convert it to [Locale].
///
/// Only special string are supported, like:
/// LANGCODE, LANGCODE_COUNTRYCODE, LANGCODE_SCRIPT_COUNTRYCODE.
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
///
/// Used by extension [LocaleFlag] on [Locale].emoji.
const emojiOffset = 127397;

/// An extension on [Locale] add [emoji] and [flag] methods.
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
  ///
  /// See [FlagNotFoundFallBack] for fallbacks.
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
      fb = findFlagFor(language: localeList.first) ?? fb;
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

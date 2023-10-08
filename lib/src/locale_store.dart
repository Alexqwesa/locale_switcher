import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_locale.dart';
import 'package:locale_switcher/src/preference_repository.dart';

/// Inner storage.
abstract class LocaleStore {
  /// A special locale name to use system locale.
  static const String systemLocale = 'system';

  /// A ReadOnly [ValueListenable] with current locale.
  ///
  /// Use [LocaleSwitcher.current] to update this notifier.
  // here just for test and backward compatibility
  static ValueNotifier<Locale> get locale => CurrentLocale.locale;

  /// List of supported locales.
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static List<Locale> supportedLocales = [];

  /// List of helpers based on supported locales - [LocaleNameFlag].
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static LocaleNameFlagList localeNameFlags =
      LocaleNameFlagList(<Locale>[const Locale('en')]);

  /// If initialized: locale will be stored in [SharedPreferences].
  static get _pref => PreferenceRepository.pref;

  /// A name of key used to store locale in [SharedPreferences].
  ///
  /// Set it via [LocaleManager].[sharedPreferenceName]
  static String innerSharedPreferenceName = 'LocaleSwitcherCurrentLocale';

  /// Init [LocaleStore] class.
  ///
  /// - It also init and read [SharedPreferences] (if available).
  static Future<void> init({
    List<Locale>? supportedLocales,
    // LocalizationsDelegate? delegate,
    sharedPreferenceName = 'LocaleSwitcherCurrentLocale',
  }) async {
    if (_pref == null) {
      //
      // > init inner vars
      //
      setSupportedLocales(supportedLocales);
      //
      // > init shared preference
      //
      innerSharedPreferenceName = sharedPreferenceName;
      await PreferenceRepository.init();
      //
      // > read locale from sharedPreference
      //
      String langCode = systemLocale;
      if (_pref != null) {
        langCode =
            PreferenceRepository.read(innerSharedPreferenceName) ?? langCode;
        CurrentLocale.trySetLocale(langCode);
      }
    }
  }

  static void setSupportedLocales(
    List<Locale>? supportedLocales,
  ) {
    if (supportedLocales != null) {
      LocaleStore.supportedLocales = supportedLocales;
      LocaleStore.localeNameFlags = LocaleNameFlagList(supportedLocales);
    }
  }

  /// Map flag to country.
  /// https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry
  /// key in lowerCase!
  static Map<String, List<dynamic>> languageToCountry = {
    // use OS locale
    LocaleStore.systemLocale: [
      'System',
      'OS locale',
      // if (!kIsWeb && Platform.isAndroid) const Icon(Icons.android),
      // if (!kIsWeb && Platform.isIOS) const Icon(Icons.phone_iphone),
      const Icon(Icons.language),
    ],
    // if not all locales shown - add this symbol
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
}

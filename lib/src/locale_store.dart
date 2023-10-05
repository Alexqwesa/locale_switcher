import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/preference_repository.dart';

// extension AppLocalizationsExt on BuildContext {
//   AppLocalizations get l10n => AppLocalizations.of(this);
// }

// extension LocaleWithDelegate on Locale {
//   /// Get class with translation strings for this locale.
//   AppLocalizations get tr => lookupAppLocalizations(this);
// }

// todo: use class LocaleNotifier to store supportedLocale in array with additional two slots for
// system and showOther
// store one index
// and provide access to languageCode and locale

abstract class LocaleStore {
  /// A special locale name to use system locale.
  static const String systemLocale = 'system';

  // todo: use ChangeNotifier to check values.
  // todo: store list of recently used locales
  /// Value of this notifier should be either from [supportedLocales] or 'system'.
  // static ValueNotifier<String> get languageCode {
  //   if (__observer == null) {
  //     initSystemLocaleObserverAndLocaleUpdater();
  //     // todo: try to read pref here?
  //   }
  //   return _languageCode;
  // }

  /// Current [Locale], use [LocaleStore.setLocale] to update it.
  ///
  /// [LocaleStore.localeIndex] contains the real value that stored in [SharedPreferences].
  // static ValueNotifier<Locale> get locale {
  //   if (__observer == null) {
  //     initSystemLocaleObserverAndLocaleUpdater();
  //     _locale.value = TestablePlatformDispatcher.platformDispatcher.locale;
  //   }
  //   return _locale;
  // }

  /// List of supported locales.
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static List<Locale> supportedLocales = [];

  /// List of helpers based on supported locales - [LocaleNameFlag].
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static LocaleNameFlagList localeNameFlags =
      LocaleNameFlagList(<Locale>[const Locale('en', 'US')]);

  /// If initialized: locale will be stored in [SharedPreferences].
  static get _pref => PreferenceRepository.pref;

  // static final _locale = ValueNotifier<Locale>(const Locale('en'));
  // static final _languageCode = ValueNotifier<String>(systemLocale);
  //
  // static LocaleObserver? __observer;

  /// Set locale with checks.
  ///
  /// It save locale into [SharedPreferences],
  /// and allow to use [systemLocale].
  // static void _setLocale(String langCode) {
  //   late Locale newLocale;
  //   if (langCode == systemLocale || langCode == '') {
  //     newLocale = TestablePlatformDispatcher.platformDispatcher.locale;
  //     // languageCode.value = systemLocale;
  //   } else if (langCode == showOtherLocales) {
  //     newLocale = locale.value; // on error: leave current
  //     dev.log('Error wrong locale name: $showOtherLocales');
  //   } else {
  //     newLocale = Locale(langCode);
  //     // languageCode.value = newLocale.toString();
  //   }
  //
  //   PreferenceRepository.write(innerSharedPreferenceName, languageCode.value);
  //   locale.value = newLocale;
  // }

  // AppLocalizations get tr => lookupAppLocalizations(locale);

  /// A name of key used to store locale in [SharedPreferences].
  ///
  /// Set it via [LocaleManager].[sharedPreferenceName]
  static String innerSharedPreferenceName = 'LocaleSwitcherCurrentLocale';

  /// Map flag to country.
  /// https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry
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
        CurrentLocale.tryToSetLocale(langCode);
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
}

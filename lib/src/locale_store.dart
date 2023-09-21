import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

// extension AppLocalizationsExt on BuildContext {
//   AppLocalizations get l10n => AppLocalizations.of(this);
// }

// extension LocaleWithDelegate on Locale {
//   /// Get class with translation strings for this locale.
//   AppLocalizations get tr => lookupAppLocalizations(this);
// }

abstract class LocaleStore {
  /// A special locale name - app will use `system` default locale.
  static const String systemLocale = 'system';

  /// Auto-updatable value, auto-update started after first access to [locale].
  static String currentSystemLocale = 'en';

  // todo: use ChangeNotifier to check values.
  // todo: store list of recently used locales
  /// Value of this notifier should be either from [supportedLocales] or 'system'.
  static ValueNotifier<String> get realLocaleNotifier {
    if (__observer == null) {
      initSystemLocaleObserverAndLocaleUpdater();
      // _locale.value = platformDispatcher.locale;
      // todo: try to read pref here?
    }
    return _realLocaleNotifier;
  }

  /// Current [Locale], use [LocaleStore.setLocale] to update it.
  ///
  /// [LocaleStore.realLocaleNotifier] contains the real value that stored in [SharedPreferences].
  static ValueNotifier<Locale> get locale {
    if (__observer == null) {
      initSystemLocaleObserverAndLocaleUpdater();
      _locale.value = TestablePlatformDispatcher.platformDispatcher.locale;
    }
    return _locale;
  }

  /// List of supported locales, setup by [LocaleManager]
  static List<Locale> supportedLocales = [];

  /// A name of key used to store locale in [SharedPreferences].
  ///
  /// Set it via [LocaleManager].[sharedPreferenceName]
  static String innerSharedPreferenceName = 'LocaleSwitcherCurrentLocale';

  /// If initialized: locale will be stored in [SharedPreferences].
  static SharedPreferences? _pref;

  static final _locale = ValueNotifier<Locale>(const Locale('en'));
  static final _realLocaleNotifier = ValueNotifier<String>(systemLocale);

  static _LocaleObserver? __observer;

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

  /// Set locale with checks.
  ///
  /// It save locale into [SharedPreferences],
  /// and allow to use [systemLocale].
  static void _setLocale(String langCode) {
    late Locale newLocale;
    if (langCode == systemLocale || langCode == '') {
      newLocale = TestablePlatformDispatcher.platformDispatcher.locale;
      // realLocaleNotifier.value = systemLocale;
    } else {
      newLocale = Locale(langCode);
      // realLocaleNotifier.value = newLocale.languageCode;
    }

    _pref?.setString(innerSharedPreferenceName, realLocaleNotifier.value);
    locale.value = newLocale;
  }

  // AppLocalizations get tr => lookupAppLocalizations(locale);
  static void initSystemLocaleObserverAndLocaleUpdater() {
    if (__observer == null) {
      WidgetsFlutterBinding.ensureInitialized();
      __observer = _LocaleObserver(onChanged: (_) {
        currentSystemLocale =
            TestablePlatformDispatcher.platformDispatcher.locale.languageCode;
        if (realLocaleNotifier.value == systemLocale) {
          locale.value = TestablePlatformDispatcher.platformDispatcher.locale;
        }
      });
      WidgetsBinding.instance.addObserver(
        __observer!,
      );

      realLocaleNotifier
          .addListener(() => _setLocale(realLocaleNotifier.value));
    }
  }

  /// Create and init [LocaleStore] class.
  ///
  /// - It also add observer for changes in system locale,
  /// - and init [SharedPreferences].
  static Future<void> init({
    List<Locale>? supportedLocales,
    LocalizationsDelegate? delegate,
    sharedPreferenceName = 'LocaleSwitcherCurrentLocale',
  }) async {
    if (_pref != null) {
      throw UnsupportedError('You cannot initialize class LocaleStore twice!');
    }
    //
    // > init inner vars
    //
    setSupportedLocales(supportedLocales);
    //
    // > init shared preference
    //
    innerSharedPreferenceName = sharedPreferenceName;
    _pref = await SharedPreferences.getInstance();
    //
    // > read locale from sharedPreference
    //
    String langCode = systemLocale;
    if (_pref != null) {
      langCode = _pref!.getString(innerSharedPreferenceName) ?? langCode;
    }
    realLocaleNotifier.value = langCode;
  }

  static void setSupportedLocales(
    List<Locale>? supportedLocales,
  ) {
    if (supportedLocales != null) {
      LocaleStore.supportedLocales = supportedLocales;
    }
  }
}

class TestablePlatformDispatcher {
  static PlatformDispatcher? overridePlatformDispatcher;

  static PlatformDispatcher get platformDispatcher {
    if (overridePlatformDispatcher != null) {
      return overridePlatformDispatcher!;
    } else {
      return WidgetsBinding.instance.platformDispatcher;
    }
  }
}

/// Observer used to notify the caller when the locale changes.
class _LocaleObserver extends WidgetsBindingObserver {
  final void Function(List<Locale>? locales) onChanged;

  _LocaleObserver({required this.onChanged});

  @override
  void didChangeLocales(List<Locale>? locales) {
    onChanged(locales);
  }
}

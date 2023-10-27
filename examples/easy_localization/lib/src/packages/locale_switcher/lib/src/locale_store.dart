import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/preference_repository.dart';

/// Inner storage.
abstract class LocaleStore {
  /// List of supported locales.
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static List<Locale> supportedLocales = [];

  /// List of helpers based on supported locales - [LocaleName].
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static SupportedLocaleNames supportedLocaleNames =
      SupportedLocaleNames(<Locale>[const Locale('en')]);

  /// If initialized: locale will be stored in [SharedPreferences].
  static get _pref => PreferenceRepository.pref;

  /// A name of key used to store locale in [SharedPreferences].
  ///
  /// Set it via [LocaleManager].[sharedPreferenceName]
  static String prefName = 'LocaleSwitcherCurrentLocaleName';
  static const defaultPrefName = 'LocaleSwitcherCurrentLocaleName';

  /// Init [LocaleStore] class.
  ///
  /// - It also init and read [SharedPreferences] (if available).
  static Future<void> init({
    List<Locale>? supportedLocales,
    // LocalizationsDelegate? delegate,
    sharedPreferenceName = defaultPrefName,
  }) async {
    if (_pref == null) {
      //
      // > init inner vars
      //
      if (supportedLocales != null) {
        LocaleSwitcher.readLocales(supportedLocales);
      }
      //
      // > init shared preference
      //
      prefName = sharedPreferenceName;
      await PreferenceRepository.init();
      //
      // > read locale from sharedPreference
      //
      String langCode = systemLocale;
      if (_pref != null) {
        langCode = PreferenceRepository.read(prefName) ?? langCode;
        LocaleMatcher.trySetLocale(langCode);
      }
    }
  }
}

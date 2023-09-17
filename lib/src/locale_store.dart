import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
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

  /// List of supported locales, setup by [LocaleManager]
  static List<Locale>? supportedLocales;

  /// A name of key used to store locale in [SharedPreferences].
  ///
  /// Set it via [LocaleManager].[sharedPreferenceName]
  static String _sharedPreferenceName = 'LocaleSwitcherCurrentLocale';
  /// If initialized: locale will be stored in [SharedPreferences].
  static SharedPreferences? _pref;

  static final _locale = ValueNotifier<Locale>(const Locale('en'));
  static final _realLocaleNotifier = ValueNotifier<String>(systemLocale);

  static LocalizationsDelegate? _delegate;

  static _LocaleObserver? __observer;

  static String get realLocale => realLocaleNotifier.value;

  static ValueNotifier<String> get realLocaleNotifier => _realLocaleNotifier;

  /// Current [Locale], use [LocaleStore.setLocale] to update it.
  ///
  /// [LocaleStore.realLocale] is real value that stored in [SharedPreferences].
  static ValueNotifier<Locale> get locale {
    //
    // > add locale observer
    //
    if (__observer == null) {
      initSystemLocaleObserver();
      _locale.value = WidgetsBinding.instance.platformDispatcher.locale;
    }
    return _locale;
  }

  /// Set locale with checks.
  ///
  /// It save locale into [SharedPreferences],
  /// and allow to use [systemLocale].
  static void setLocale(String langCode) {
    late Locale newLocale;
    if (langCode == systemLocale || langCode == '') {
      newLocale = WidgetsBinding.instance.platformDispatcher.locale;
      realLocaleNotifier.value = systemLocale;
    } else {
      newLocale = Locale(langCode);
      realLocaleNotifier.value = newLocale.languageCode;
    }

    if (_delegate != null) {
      if (!_delegate!.isSupported(newLocale)) {
        newLocale = supportedLocales?.first ??
            const Locale('en'); // todo: throw warning?
        dev.log('Unsupported locale: $langCode');
      }
    }

    _pref?.setString(_sharedPreferenceName, realLocaleNotifier.value);
    locale.value = newLocale;
  }

  // AppLocalizations get tr => lookupAppLocalizations(locale);
  static void initSystemLocaleObserver() {
    if (__observer == null) {
      WidgetsFlutterBinding.ensureInitialized();
      __observer = _LocaleObserver(onChanged: (_) {
        currentSystemLocale =
            WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        if (realLocaleNotifier.value == systemLocale) {
          locale.value = WidgetsBinding.instance.platformDispatcher.locale;
        }
      });
      WidgetsBinding.instance.addObserver(
        __observer!,
      );
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
    setLocaleAndDelegate(supportedLocales, delegate);
    //
    // > init shared preference
    //
    _sharedPreferenceName = sharedPreferenceName;
    _pref = await SharedPreferences.getInstance();
    //
    // > read locale from sharedPreference
    //
    String langCode = systemLocale;
    if (_pref != null) {
      langCode = _pref!.getString(_sharedPreferenceName) ?? langCode;
    }
    setLocale(langCode);
  }

  static void setLocaleAndDelegate(
    List<Locale>? supportedLocales,
    LocalizationsDelegate? delegate,
  ) {
    if (supportedLocales != null) {
      LocaleStore.supportedLocales = supportedLocales;
    }
    if (delegate != null) {
      _delegate = delegate;
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

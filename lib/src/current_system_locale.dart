import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_observable.dart';

/// Public access to it notifier via [CurrentLocale.byName(LocaleManager.systemLocale)]
abstract class CurrentSystemLocale {
  static LocaleObserver? __observer;

  /// Listen on system locale.
  static ValueNotifier<Locale> get currentSystemLocale {
    initSystemLocaleObserver();
    return __currentSystemLocale;
  }

  static final __currentSystemLocale = ValueNotifier(const Locale('en'));

  static void initSystemLocaleObserver() {
    if (__observer == null) {
      WidgetsFlutterBinding.ensureInitialized();
      __currentSystemLocale.value =
          TestablePlatformDispatcher.platformDispatcher.locale;
      __observer = LocaleObserver(onChanged: (_) {
        __currentSystemLocale.value =
            TestablePlatformDispatcher.platformDispatcher.locale;
      });
      WidgetsBinding.instance.addObserver(
        __observer!,
      );
    }
  }
}

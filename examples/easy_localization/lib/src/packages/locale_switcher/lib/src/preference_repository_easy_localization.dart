// ignore_for_file: depend_on_referenced_packages

import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_switcher/locale_switcher.dart';

/// This class will try to access easy_localization via context.
class PreferenceRepository {
  /// If initialized: locale will be stored in [SharedPreferences].
  static bool? pref;

  // todo: also store LocaleManager key
  static GlobalKey? _lastUsedKey;

  static Future<void> init() async {
    pref = true;
  }

  static String? read(String innerSharedPreferenceName) {
    final context = _lastUsedKey?.currentState?.context;
    if (context != null) {
      return EasyLocalization.of(context)?.locale.languageCode;
    }

    // dev.log(
    //     "Context of LocaleSwitcher not found! can't get easy_localization locale!");
    return null;
  }

  static Future<bool>? write(
      String innerSharedPreferenceName, languageCode) async {
    final context = _lastUsedKey?.currentState?.context;
    if (context != null && CurrentLocale.current.locale != null) {
      await EasyLocalization.of(context)
          ?.setLocale(CurrentLocale.current.locale!);
      return true;
    }

    dev.log(
        "Context of LocaleSwitcher not found! can't set easy_localization locale!");
    return false;
  }

  // only needed for system like: easy_localization
  static void sendGlobalKeyToRepository(GlobalKey key) {
    _lastUsedKey = key;
  }
}

import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_switcher_dev/src/locale_store.dart';

// easy_localization didn't provide access to it inner notifiers in public api, '
// 'we can use GlobalKey to access context when we need to update Locale - too ugly
// see git branch builder_easy_localization_with_public_api

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
    if (context != null) {
      await EasyLocalization.of(context)?.setLocale(LocaleStore.locale.value);
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

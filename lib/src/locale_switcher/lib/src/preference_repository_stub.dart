import 'package:flutter/widgets.dart';

/// Stub class, in case: shared_preferences: false
class PreferenceRepository {
  /// If initialized: locale will be stored in [SharedPreferences].
  static bool? pref;

  // stub
  static Future<void> init() async {}

  static String? read(String innerSharedPreferenceName) {
    return null;
  }

  static Future<bool>? write(String innerSharedPreferenceName, languageTag) {
    return null;
  }

  // stub, only needed for system like: easy_localization
  static void sendGlobalKeyToRepository(GlobalKey key) {}
}

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceRepository {
  /// If initialized: locale will be stored in [SharedPreferences].
  static SharedPreferences? pref;

  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  static String? read(String innerSharedPreferenceName) {
    return pref?.getString(innerSharedPreferenceName);
  }

  static Future<bool>? write(String innerSharedPreferenceName, languageTag) {
    return pref?.setString(innerSharedPreferenceName, languageTag);
  }

  // stub, only needed for system like: easy_localization
  static void sendGlobalKeyToRepository(GlobalKey key) {}
}

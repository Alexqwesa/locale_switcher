import 'package:shared_preferences/shared_preferences.dart';

/// Separate class to make mocking easy.
class PreferenceRepository {
  /// If initialized: locale will be stored in [SharedPreferences].
  static SharedPreferences? pref;

  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }
}

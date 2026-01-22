import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._(); // private constructor (singleton-style utility)

  static SharedPreferences? _prefs;

  /// Call this once (e.g. in main) before using the class
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /* ===================== BOOL ===================== */

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /* ===================== STRING ===================== */

  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  /* ===================== INT ===================== */

  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  /* ===================== DOUBLE ===================== */

  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  /* ===================== REMOVE / CLEAR ===================== */

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}

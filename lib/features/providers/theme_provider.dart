import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String themeStatusKey = 'THEME_STATUS';

  bool _darkTheme = false;

  /// ✅ Correct, conventional getter
  bool get isDarkTheme => _darkTheme;

  ThemeProvider() {
    unawaited(_loadTheme());
  }

  Future<void> _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _darkTheme = prefs.getBool(themeStatusKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkTheme(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeStatusKey, value);
    _darkTheme = value;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setDarkTheme(!_darkTheme);
  }
}

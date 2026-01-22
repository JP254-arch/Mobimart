import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';


class ThemeProvider extends ChangeNotifier {
ThemeMode _themeMode = ThemeMode.system;


ThemeMode get themeMode => _themeMode;


ThemeData get lightTheme => lightThemeData;
ThemeData get darkTheme => darkThemeData;

  Null get getIsDarkTHeme => null;

  bool? get isDarkTheme => null;


void toggleTheme(bool isDark) {
_themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
notifyListeners();
}

  void setDarkTheme(bool value) {}
}
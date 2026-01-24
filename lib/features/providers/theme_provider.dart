import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String themeStatusKey = 'THEME_STATUS';

  bool _darkTheme = false;

  bool get isDarkTheme => _darkTheme;

  ThemeProvider() {
    _loadTheme();
  }

  // Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _darkTheme = prefs.getBool(themeStatusKey) ?? false;
    notifyListeners();
  }

  // Set theme
  Future<void> setDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeStatusKey, value);
    _darkTheme = value;
    notifyListeners();
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    await setDarkTheme(!_darkTheme);
  }

  // ================= GET THEME =================
  ThemeData get themeData => _darkTheme ? _darkThemeData : _lightThemeData;

  // ================= LIGHT THEME =================
  final ThemeData _lightThemeData = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0A73FF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0A73FF),
      secondary: Color(0xFFFF6B6B),
      surface: Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A73FF),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF0A73FF),
      unselectedItemColor: Colors.black54,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A73FF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  // ================= DARK THEME =================
  final ThemeData _darkThemeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0A73FF),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0A73FF),
      secondary: Color(0xFFFF6B6B),
      surface: Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white70,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A73FF),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF0A73FF),
      unselectedItemColor: Colors.white54,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A73FF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

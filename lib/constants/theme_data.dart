import 'package:flutter/material.dart';
import 'package:mobimart_app/core/constants/app_colors.dart';

class Styles {
  static ThemeData themeData({
    required bool isDarkTheme,
    required BuildContext context,
  }) {
    return ThemeData(
      scaffoldBackgroundColor: isDarkTheme
          ? AppColors.darkScaffoldColor
          : AppColors.lightScaffoldColor,

      cardColor: isDarkTheme
          ? const Color.fromARGB(100, 78, 89, 67)
          : AppColors.lightCardColor,

      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      
    );
  }
}

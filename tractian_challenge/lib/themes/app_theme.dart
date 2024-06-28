import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.headerBackground,
    scaffoldBackgroundColor: AppColors.bodyBackground,
    appBarTheme: const AppBarTheme(
      color: AppColors.headerBackground,
      iconTheme: IconThemeData(color: AppColors.buttonText),
    ),
  );

  //TODO: Dark Theme
  static final darkTheme = ThemeData(
    primaryColor: AppColors.headerBackground,
    scaffoldBackgroundColor: AppColors.bodyBackground,
    appBarTheme: const AppBarTheme(
      color: AppColors.headerBackground,
      iconTheme: IconThemeData(color: AppColors.buttonText),
    ),
  );
}
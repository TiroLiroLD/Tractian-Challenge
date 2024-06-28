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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBackground,
        foregroundColor: AppColors.buttonText,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.bodyText1),
      bodyMedium: TextStyle(color: AppColors.bodyText2),
      labelLarge: TextStyle(color: AppColors.buttonText),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.searchBoxBackground,
      hintStyle: TextStyle(color: AppColors.searchBoxText),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppColors.darkHeaderBackground,
    scaffoldBackgroundColor: AppColors.darkBodyBackground,
    appBarTheme: const AppBarTheme(
      color: AppColors.darkHeaderBackground,
      iconTheme: IconThemeData(color: AppColors.darkButtonText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkButtonBackground,
        foregroundColor: AppColors.darkButtonText,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkBodyText1),
      bodyMedium: TextStyle(color: AppColors.darkBodyText2),
      labelLarge: TextStyle(color: AppColors.darkButtonText),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSearchBoxBackground,
      hintStyle: TextStyle(color: AppColors.darkSearchBoxText),
    ),
  );
}

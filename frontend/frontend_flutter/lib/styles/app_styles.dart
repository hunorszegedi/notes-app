import 'package:flutter/material.dart';

class AppStyle {
  static const Color backgroundColor = Color(0xFF0D0D0D);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color accentRed = Color(0xFFD32F2F);
  static const Color accentWhite = Color(0xFFF5F5F5);
  static const Color greyText = Color(0xFFB0BEC5);

  static const String fontFamily = 'Courier New';

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: accentWhite,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: accentWhite, fontSize: 16),
      titleLarge: TextStyle(
        color: accentWhite,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      labelSmall: TextStyle(color: greyText, fontSize: 12),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentRed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentRed,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

class AppStyle {
  // 🎨 Színek
  static const Color backgroundColor = Color(0xFF0D0D0D);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color accentRed = Color(0xFFD32F2F);
  static const Color accentWhite = Color(0xFFF5F5F5);
  static const Color greyText = Color(0xFFB0BEC5);

  // 🔠 Betűtípus
  static const String fontFamily = 'DotMatrix';

  // 📱 Téma
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
        letterSpacing: 2,
      ),
      iconTheme: IconThemeData(color: accentWhite),
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
      foregroundColor: accentWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentRed,
        foregroundColor: accentWhite,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: greyText),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: greyText),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: accentRed),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
      ),
    ),
  );
}

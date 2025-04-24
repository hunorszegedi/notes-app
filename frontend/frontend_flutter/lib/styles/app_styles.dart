/* lib/styles/app_styles.dart
   – minimal-cyber / retro-terminal dizájn
*/
import 'package:flutter/material.dart';

class AppStyle {
  /* ───────── PALETTA ───────── */
  static const background = Color(0xFF0A0A0C);
  static const surface = Color(0xFF18181B);
  static const accentRed = Color(0xFFE53935);
  static const accentYellow = Color(0xFFFFC400);
  static const accentGreen = Color(0xFF00C853);
  static const textPrimary = Color(0xFFEFEFEF);
  static const textSecondary = Color(0xFF8A8A8E);

  /* ───────── TYPO ───────── */
  static const String fontMain = 'DotMatrix';
  static const String fontMono = 'JetBrainsMono';

  /* ───────── TÉMA ───────── */
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    canvasColor: surface,
    fontFamily: fontMain,

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: fontMain,
        fontSize: 24,
        letterSpacing: 2,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontFamily: fontMain,
        fontSize: 22,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontMono,
        fontSize: 14,
        color: textPrimary,
      ),
      labelSmall: TextStyle(
        fontFamily: fontMono,
        fontSize: 12,
        color: textSecondary,
      ),
    ),

    cardColor: surface,
    cardTheme: CardTheme(
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: surface,
      labelStyle: TextStyle(color: textSecondary),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: accentRed, width: .8),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accentRed, width: 1.2),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentRed,
        foregroundColor: textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: fontMono,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentRed,
      foregroundColor: textPrimary,
      shape: StadiumBorder(),
    ),

    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: MaterialStatePropertyAll(surface),
        elevation: MaterialStatePropertyAll(4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: textPrimary, fontFamily: fontMono),
      actionTextColor: accentRed,
    ),
  );

  /* priority badge színek */
  static Color importanceColor(String? imp) {
    switch (imp) {
      case 'high':
        return accentYellow;
      case 'low':
        return accentGreen;
      default:
        return accentRed; // normal
    }
  }
}

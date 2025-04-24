/* lib/styles/app_styles.dart
   – CYBERPUNK // TERMINAL // RETROFUTURE
*/
import 'package:flutter/material.dart';

class AppStyle {
  /* ───────── COLOR DNA ───────── */
  static const background = Color(0xFF090C10); // mély fekete-kék
  static const surface = Color(0xFF12171C); // sötét felület
  static const accentRed = Color(0xFFFF3D00); // neon narancs-vörös
  static const accentYellow = Color(0xFFFFD600); // savas sárga
  static const accentGreen = Color(0xFF00FFAB); // zöld holografikus
  static const textPrimary = Color(0xFFEBEFF2); // világos text
  static const textSecondary = Color(0xFF6C7380); // tompa szürke

  /* ───────── TYPEFACES ───────── */
  static const String fontMain = 'Orbitron'; // futurisztikus fő font
  static const String fontMono = 'JetBrainsMono'; // kódhoz

  /* ───────── THEMATIC ENGINE ───────── */
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
        fontSize: 22,
        letterSpacing: 2.0,
        color: accentGreen,
      ),
      iconTheme: IconThemeData(color: accentGreen),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontFamily: fontMain,
        fontSize: 20,
        color: accentGreen,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      shadowColor: accentGreen.withOpacity(0.3),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      labelStyle: const TextStyle(color: accentYellow),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: accentGreen, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: accentRed, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,
        foregroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontFamily: fontMono,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentRed,
      foregroundColor: textPrimary,
      shape: CircleBorder(),
    ),

    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: MaterialStateProperty.all(surface),
        elevation: MaterialStateProperty.all(4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: accentYellow, fontFamily: fontMono),
      actionTextColor: accentRed,
    ),
  );

  /* ───────── STATUS COLOR MAPPER ───────── */
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

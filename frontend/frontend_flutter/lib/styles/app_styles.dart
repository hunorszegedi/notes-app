import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  /* ───────── COLOR DNA ───────── */
  static const background = Color(0xFF090C10);
  static const surface = Color(0xFF12171C);
  static const accentRed = Color(0xFFFF3D00);
  static const accentYellow = Color(0xFFFFD600);
  static const accentGreen = Color(0xFF00FFAB);
  static const textPrimary = Color(0xFFEBEFF2);
  static const textSecondary = Color(0xFF6C7380);

  /* ───────── STATUS COLOR MAPPER ───────── */
  static Color importanceColor(String? imp) {
    switch (imp) {
      case 'high':
        return accentRed;
      case 'low':
        return accentGreen;
      default:
        return accentYellow; // normal
    }
  }

  /* ───────── THEMATIC ENGINE ───────── */
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    canvasColor: surface,

    /* ––––––––––––––––– APPBAR ––––––––––––––––– */
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      iconTheme: const IconThemeData(color: accentGreen),
      titleTextStyle: GoogleFonts.orbitron(
        color: accentGreen,
        fontSize: 22,
        letterSpacing: 2.0,
      ),
    ),

    /* ––––––––––––––––– TEXT THEME ––––––––––––––––– */
    textTheme: TextTheme(
      titleLarge: GoogleFonts.orbitron(color: accentGreen, fontSize: 20),
      bodyMedium: GoogleFonts.jetBrainsMono(color: textPrimary, fontSize: 14),
      labelSmall: GoogleFonts.jetBrainsMono(color: textSecondary, fontSize: 12),
    ),

    /* ––––––––––––––––– CARDS ––––––––––––––––– */
    cardColor: surface,
    cardTheme: CardTheme(
      color: surface,
      elevation: 4,
      shadowColor: accentGreen.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),

    /* ––––––––––––––––– INPUT ––––––––––––––––– */
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      labelStyle: const TextStyle(color: accentYellow),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accentGreen, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accentRed, width: 1.5),
      ),
    ),

    /* ––––––––––––––––– BUTTONS ––––––––––––––––– */
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,
        foregroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentRed,
      foregroundColor: textPrimary,
      shape: CircleBorder(),
    ),

    /* ––––––––––––––––– DROPDOWNS ––––––––––––––––– */
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: MaterialStatePropertyAll(surface),
        elevation: MaterialStatePropertyAll(4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    /* ––––––––––––––––– SNACK BARS ––––––––––––––––– */
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: GoogleFonts.jetBrainsMono(color: accentYellow),
      actionTextColor: accentRed,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  // Định nghĩa màu chính xác
  static const Color primaryBlue = Color(0xFF2196F3);

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
          error: const Color(0xFFBA1A1A),
        ).copyWith(
          primary: primaryBlue, // Ghi đè màu primary
          onPrimary: Colors.white,
        ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ).copyWith(
          primary: primaryBlue, // Ghi đè màu primary
          onPrimary: Colors.white,
        ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white12, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}

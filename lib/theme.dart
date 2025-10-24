import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core colors used by the mockups
  // User-provided palette (darkest -> lightest)
  static const Color colorDarkest = Color(0xFF937F71); 
  static const Color colorLightBlue = Color(0xFF7DC0B5); 
  static const Color colorMid = Color(0xFFB6846A); 
  static const Color colorNeutral = Color(0xFFE0CFBD); 
  static const Color colorLight = Color(0xE11F9CA5); 
  static const Color colorLightest = Color(0xFFEEECE6);
  static const Color colorDarkerBrown = Color(0xFF754B0C); 

  // Centralized TextTheme using Plus Jakarta Sans (mockup font)
  static final TextTheme textTheme = GoogleFonts.plusJakartaSansTextTheme();

  // Input decoration used across the app to match mockup text fields
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
  );

  static final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorLightBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
  );

  static final OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Colors.grey.shade300),
      textStyle: textTheme.bodyMedium,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: colorLightBlue),
    primaryColor: colorLightBlue,
    scaffoldBackgroundColor: colorLight,
    textTheme: textTheme,
    inputDecorationTheme: inputDecorationTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorLightBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: outlinedButtonTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorMid,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
  );
}

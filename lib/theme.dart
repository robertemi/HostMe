import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core colors used by the mockups
  // User-provided palette (darkest -> lightest)
  static const Color colorDarkest = Color(0xFF2B1F1A);
  static const Color colorLightBlue = Color(0xFF66E0D6);
  static const Color colorMid = Color(0xFFB6846A);
  static const Color colorNeutral = Color(0xFFD9CCC0);
  static const Color colorLight = Color(0xFF1F9CA5);
  static const Color colorLightest = Color(0xFFEEF2F6);
  static const Color colorDarkerBrown = Color(0xFF5A3E2A);

  // Glass accents and gradient tokens
  static const Color glassAccent1 = Color(0xFF66E0D6); // mint-cyan
  static const Color glassAccent2 = Color(0xFFF7A8D6); // soft pink
  static const Color glassAccent3 = Color(0xFF9AE6FF); // soft sky
  static const Color glassGradientStart = Color.fromARGB(255, 62, 188, 213);
  static const Color glassGradientEnd = Color.fromARGB(255, 51, 130, 137);

  // Centralized TextTheme using Plus Jakarta Sans (mockup font)
  static final TextTheme textTheme = GoogleFonts.plusJakartaSansTextTheme();

  // Input decoration used across the app to match mockup text fields
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    // subtle translucent fill for glass look
    fillColor: Colors.white.withOpacity(0.04),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white70),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white12),
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
    dialogTheme: DialogThemeData(
      // Make dialog cards fully opaque for maximum readability on light theme
      backgroundColor: Colors.white,
      elevation: 6,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.black87),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.black87),
    ),
  );

  // Glassmorphism / liquid-glass themed dark theme
  static final ThemeData glassTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: glassAccent1,
      secondary: glassAccent2,
      surface: Colors.white.withOpacity(0.04),
      error: const Color(0xFFEF4444),
      onPrimary: Colors.black,
      onSurface: Colors.white.withOpacity(0.9),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    primaryColor: glassAccent1,
    textTheme: textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
    inputDecorationTheme: inputDecorationTheme.copyWith(
      fillColor: Colors.white.withOpacity(0.03),
      hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white70),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: glassAccent1.withOpacity(0.18),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
        textStyle: textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    dialogTheme: DialogThemeData(
      // Increase opacity on glass theme dialogs so text is clearer
      backgroundColor: Colors.black.withOpacity(0.90),
      elevation: 4,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white70),
    ),
    cardColor: Colors.white.withOpacity(0.035),
    dividerColor: Colors.white12,
    shadowColor: Colors.black,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Crimson palette
  static const Color primaryCrimson = Color(0xFF86243A);
  static const Color primaryDark = Color(0xFF5B1625);
  static const Color primaryLight = Color(0xFFF9ECEF);

  // Warm Gold palette
  static const Color goldAccent = Color(0xFFDAB15C);
  static const Color goldDark = Color(0xFFB48A37);
  static const Color goldLight = Color(0xFFFBF4E7);

  // Neutral tones
  static const Color backgroundLight = Color(0xFFFAF7F2);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEDE4D8);
  static const Color textDark = Color(0xFF1E1A17);
  static const Color textMuted = Color(0xFF6B635A);
  static const Color textSubtle = Color(0xFF9E968B);

  // Alert/Status colors
  static const Color alertUrgent = Color(0xFFBA2238);
  static const Color alertMaintenance = Color(0xFFD97706);
  static const Color alertNotice = Color(0xFF2563EB);
  static const Color successGreen = Color(0xFF15803D);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryCrimson,
        onPrimary: Colors.white,
        primaryContainer: primaryLight,
        onPrimaryContainer: primaryDark,
        secondary: goldAccent,
        onSecondary: Colors.black,
        secondaryContainer: goldLight,
        onSecondaryContainer: goldDark,
        surface: surfaceWhite,
        onSurface: textDark,
        error: alertUrgent,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: primaryDark),
        titleTextStyle: GoogleFonts.outfit(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCrimson,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryCrimson,
          side: const BorderSide(color: primaryCrimson, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryCrimson, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: alertUrgent, width: 1.2),
        ),
        labelStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: textSubtle, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceWhite,
        selectedColor: primaryLight,
        side: const BorderSide(color: cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 15,
          color: textDark,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 13,
          color: textMuted,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 1,
        space: 24,
      ),
    );
  }

  // Common card box shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primaryCrimson.withValues(alpha: 0.04),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];
}

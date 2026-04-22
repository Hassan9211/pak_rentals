import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const Color bg = Color(0xFF0A0D14);
  static const Color bgCard = Color(0xFF141826);
  static const Color bgElevated = Color(0xFF0F1320);
  static const Color bgInput = Color(0xFF1A1F2E);

  // Brand
  static const Color cyan = Color(0xFF00D4FF);
  static const Color purple = Color(0xFF7B5CFF);
  static const Color pink = Color(0xFFFF3D8A);

  // Text
  static const Color textPrimary = Color(0xFFF0F2F8);
  static const Color textSecondary = Color(0xFF8B91A8);
  static const Color textMuted = Color(0xFF565C74);

  // Status
  static const Color success = Color(0xFF00E5A0);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4D4D);

  // Borders
  static const Color border = Color(0x0FFFFFFF);
  static const Color borderLight = Color(0x14FFFFFF);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyan,
        secondary: AppColors.purple,
        surface: AppColors.bgCard,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.syne(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.syne(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.syne(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.syne(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.dmSans(color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.dmSans(color: AppColors.textSecondary),
        bodySmall: GoogleFonts.dmSans(color: AppColors.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgElevated,
        elevation: 0,
        titleTextStyle: GoogleFonts.syne(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgElevated,
        selectedItemColor: AppColors.cyan,
        unselectedItemColor: AppColors.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cyan),
        ),
        hintStyle: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13),
      ),
      dividerColor: AppColors.borderLight,
      useMaterial3: true,
    );
  }
}

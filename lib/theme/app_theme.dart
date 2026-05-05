import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static bool isDarkMode = true;

  // Brand
  static Color get primary => isDarkMode ? const Color(0xFFD6BAFF) : const Color(0xFF7E3FF2);
  static Color get primaryContainer => isDarkMode ? const Color(0xFFAB73FF) : const Color(0xFF5A20C1);
  static Color get onPrimaryFixed => isDarkMode ? const Color(0xFF280056) : const Color(0xFFFFFFFF);
  
  static Color get secondary => isDarkMode ? const Color(0xFF9BE1FF) : const Color(0xFF0086C9);
  static Color get tertiary => isDarkMode ? const Color(0xFF43D9E9) : const Color(0xFF009CA6);
  
  // Background & Surface
  static Color get background => isDarkMode ? const Color(0xFF131315) : const Color(0xFFF4F5F8);
  static Color get onBackground => isDarkMode ? const Color(0xFFE5E1E4) : const Color(0xFF1C1B1F);
  
  static Color get surface => isDarkMode ? const Color(0xFF131315) : const Color(0xFFF4F5F8);
  static Color get onSurface => isDarkMode ? const Color(0xFFE5E1E4) : const Color(0xFF1C1B1F);
  static Color get surfaceVariant => isDarkMode ? const Color(0xFF353437) : const Color(0xFFE8E9EC);
  static Color get onSurfaceVariant => isDarkMode ? const Color(0xFFCDC2D7) : const Color(0xFF49454F);
  
  static Color get surfaceContainerLowest => isDarkMode ? const Color(0xFF0E0E10) : const Color(0xFFFFFFFF);
  static Color get surfaceContainerLow => isDarkMode ? const Color(0xFF1B1B1D) : const Color(0xFFF8F9FA);
  static Color get surfaceContainer => isDarkMode ? const Color(0xFF201F21) : const Color(0xFFF0F1F3);
  static Color get surfaceContainerHigh => isDarkMode ? const Color(0xFF2A2A2C) : const Color(0xFFE8E9EC);
  static Color get surfaceContainerHighest => isDarkMode ? const Color(0xFF353437) : const Color(0xFFE0E1E4);
  
  // Outline & States
  static Color get outline => isDarkMode ? const Color(0xFF968DA0) : const Color(0xFF79747E);
  static Color get outlineVariant => isDarkMode ? const Color(0xFF4B4454) : const Color(0xFFCAC4D0);
  static Color get error => isDarkMode ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E);
}

class AppTheme {
  static ThemeData get currentTheme {
    final base = AppColors.isDarkMode ? ThemeData.dark() : ThemeData.light();
    
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: (AppColors.isDarkMode ? ColorScheme.dark() : ColorScheme.light()).copyWith(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        onPrimary: AppColors.isDarkMode ? const Color(0xFF430089) : const Color(0xFFFFFFFF),
        onSecondary: AppColors.isDarkMode ? const Color(0xFF003545) : const Color(0xFFFFFFFF),
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: AppColors.error,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w800,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        labelSmall: GoogleFonts.inter(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.normal,
          letterSpacing: 2.0,
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.onSurface,
      ),
    );
  }
}

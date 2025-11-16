import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. --- YOUR NEW "DEEP VIOLET" PALETTE ---
class AppColors {
  // Dark Theme
  static const Color darkBackgroundColor = Color(0xFF121212); // Onyx
  static const Color darkCardColor = Color(0xFF1E1E1E); // Charcoal
  static const Color darkBorderColor = Color(0xFF383838); // Subtle Gray
  static const Color darkBodyText = Color(0xFFA0A0A0); // Light Gray

  // Brand / Accent
  static const Color primaryColor = Color(0xFF7F56D9); // Vibrant Violet
  static const Color accentColor = Color(0xFF007AFF); // Bright Blue

  // Light Theme
  static const Color lightBackgroundColor = Color(0xFFF9F9F9);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightTextColor = Color(0xFF333333);
}

class AppTheme {
  // 2. --- FONT STACK APPLIED TO BOTH THEMES ---
  static TextTheme _buildTextTheme(Color bodyColor) {
    // Base theme is Inter
    var baseTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: bodyColor,
      displayColor: bodyColor,
    );
    // Merge Sora for headings
    return baseTheme.copyWith(
      displayMedium: GoogleFonts.sora(
        fontWeight: FontWeight.bold,
        color: bodyColor,
      ),
      displaySmall: GoogleFonts.sora(
        fontWeight: FontWeight.bold,
        color: bodyColor,
      ),
      headlineMedium: GoogleFonts.sora(
        fontWeight: FontWeight.w600, // SemiBold
        color: bodyColor,
      ),
      headlineSmall: GoogleFonts.sora(
        fontWeight: FontWeight.w600, // SemiBold
        color: bodyColor,
      ),
      // Use Inter for button text as requested
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600, // SemiBold
      ),
    );
  }

  // --- LIGHT THEME (Updated with new fonts/brand colors) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // <-- ENABLE MATERIAL 3
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.lightBackgroundColor,
      cardColor: AppColors.lightCardColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: _buildTextTheme(AppColors.lightTextColor),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryColor,
        inactiveTrackColor: AppColors.primaryColor.withOpacity(0.3),
        thumbColor: AppColors.primaryColor,
        overlayColor: AppColors.primaryColor.withOpacity(0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder( // <-- FIX 1
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder( // <-- FIX 2
            borderRadius: BorderRadius.circular(30),
          ),
          side: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
      ),
    );
  }

  // 4. --- YOUR NEW "DEEP VIOLET" DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true, // <-- ENABLE MATERIAL 3
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      cardColor: AppColors.darkCardColor, // Used for solid cards
      dividerColor: AppColors.darkBorderColor, // For dividers
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: _buildTextTheme(Colors.white), // Headings: White
      primaryTextTheme: _buildTextTheme(AppColors.darkBodyText),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryColor,
        inactiveTrackColor: AppColors.primaryColor.withOpacity(0.3),
        thumbColor: AppColors.primaryColor,
        overlayColor: AppColors.primaryColor.withOpacity(0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder( // <-- FIX 3
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold
            color: Colors.white, // Button text is white
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder( // <-- FIX 4
            borderRadius: BorderRadius.circular(30),
          ),
          side: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
      ),
    );
  }
}
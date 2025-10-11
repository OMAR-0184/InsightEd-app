import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// New, lighter color palette
class AppColors {
  static const Color primaryColor = Color(0xFF4A90E2); // A calm, friendly blue
  static const Color secondaryColor = Color(0xFFB8D8D8); // A light, muted cyan
  static const Color accentColor = Color(0xFFF5A623); // A warm, inviting orange
  static const Color backgroundColor = Color(0xFFF9F9F9); // A very light grey, like paper
  static const Color textColor = Color(0xFF333333); // A dark grey for text, softer than pure black
  static const Color borderColor = Color(0xFF000000); // Bold black for borders
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Using a more playful, sketch-like font
      textTheme: GoogleFonts.patrickHandTextTheme().apply(
        bodyColor: AppColors.textColor,
        displayColor: AppColors.textColor,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryColor,
        inactiveTrackColor: AppColors.primaryColor.withOpacity(0.3),
        thumbColor: AppColors.primaryColor,
        overlayColor: AppColors.primaryColor.withOpacity(0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, 
          foregroundColor: AppColors.textColor, 
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), 
            side: const BorderSide(
              color: AppColors.borderColor, 
              width: 2.5, 
            ),
          ),
          textStyle: GoogleFonts.patrickHand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
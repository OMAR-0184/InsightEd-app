import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Layer 1: The solid background color (Onyx or Light Gray)
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        
        // Layer 2: The "Blob" (Only in Dark Mode)
        if (isDarkMode)
          Positioned(
            top: -150, // Positioned in the corner
            left: -150,
            child: Opacity(
              opacity: 0.15, // Very subtle!
              child: ImageFiltered(
                // This is the Flutter equivalent of `filter: blur(150px)`
                imageFilter: ImageFilter.blur(sigmaX: 150.0, sigmaY: 150.0),
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    // Your Radial Gradient
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.accentColor,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter/material.dart';

class SketchCard extends StatelessWidget {
  final Widget child;
  const SketchCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- "Frosted Glass" implementation for Dark Mode ---
    if (isDarkMode) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.0), // As per CSS
        child: BackdropFilter(
          // `backdrop-filter: blur(25px)`
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              // `background-color: rgba(255, 255, 255, 0.05)`
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16.0),
              // `border: 1px solid rgba(255, 255, 255, 0.1)`
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: child,
          ),
        ),
      );
    }

    // --- Standard Solid Card for Light Mode ---
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Solid white
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}
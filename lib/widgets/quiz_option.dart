import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuizOption extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const QuizOption({
    super.key,
    required this.optionText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    BoxDecoration getDecoration() {
      if (isDarkMode) {
        // --- Dark Mode: "Frosted Glass" ---
        return BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.2) // Selected tint
              : Colors.white.withOpacity(0.05), // Glass
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor // Selected border
                : Colors.white.withOpacity(0.1), // Glass border
            width: isSelected ? 2.0 : 1.5,
          ),
        );
      } else {
        // --- Light Mode: Solid Card ---
        return BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1) // Selected tint
              : Colors.white, // Solid white
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor // Selected border
                : Colors.grey.shade200, // Light border
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        );
      }
    }

    // We use a container and `ClipRRect` to contain the BackdropFilter
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          // Apply blur if dark mode, no-op if light mode
          filter: ImageFilter.blur(
            sigmaX: isDarkMode ? 25.0 : 0.0,
            sigmaY: isDarkMode ? 25.0 : 0.0,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
            margin: const EdgeInsets.only(bottom: 12.0),
            constraints: const BoxConstraints(minHeight: 70.0),
            alignment: Alignment.centerLeft,
            decoration: getDecoration(),
            child: Text(
              optionText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
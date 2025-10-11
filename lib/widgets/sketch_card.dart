import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SketchCard extends StatelessWidget {
  final Widget child;
  const SketchCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: AppColors.borderColor, 
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
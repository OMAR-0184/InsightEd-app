import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class SummaryScreen extends StatelessWidget {
  final String summary;

  const SummaryScreen({super.key, required this.summary});


  TextSpan _buildTextSpans(String text, BuildContext context) {
    final List<TextSpan> children = [];
    final List<String> parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        children.add(TextSpan(text: parts[i]));
      } else {
        children.add(
          TextSpan(
            text: parts[i],
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor),
          ),
        );
      }
    }
    // Apply the base style for the entire paragraph
    return TextSpan(
      children: children,
      style: GoogleFonts.lato(
        fontSize: 18,
        height: 1.6, // Increased line height for readability
        color: AppColors.textColor.withOpacity(0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(15),
                    child: GlassContainer(
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Animated title
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Padding(
                          padding: EdgeInsets.only(left: value * 10),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'Summary',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GlassContainer(
                      child: SingleChildScrollView(
                        child: RichText(
                          text: _buildTextSpans(summary, context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
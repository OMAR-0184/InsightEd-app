import 'package:flutter/material.dart';

import '../widgets/animated_background.dart';
import '../widgets/sketch_card.dart';
import '../theme/app_theme.dart';

class SummaryScreen extends StatelessWidget {
  final String summary;

  const SummaryScreen({super.key, required this.summary});

  TextSpan _buildTextSpans(String text, BuildContext context) {
    final List<TextSpan> children = [];
    final List<String> parts = text.split('**');

    final defaultColor = Theme.of(context).textTheme.bodyLarge?.color;

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        children.add(TextSpan(text: parts[i]));
      } else {
        children.add(
          TextSpan(
            text: parts[i],
            // --- FIX ---
            style: TextStyle(fontWeight: FontWeight.bold, color: defaultColor),
          ),
        );
      }
    }

    return TextSpan(
      children: children,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            height: 1.6,
            // --- FIX ---
            color: defaultColor?.withOpacity(0.85),
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
            minimum: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        // --- FIX ---
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context).iconTheme.color, // Use theme icon color
                          size: 28,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Summary',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SketchCard(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: RichText(
                        text: _buildTextSpans(summary, context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
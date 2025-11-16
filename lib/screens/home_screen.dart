import 'package:flutter/material.dart'; // <-- *** THIS WAS THE MISSING LINE ***
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/app_provider.dart';
import 'summary_screen.dart';
import 'quiz_screen.dart';
import '../widgets/animated_background.dart';
import '../widgets/sketch_card.dart';
import '../theme/app_theme.dart'; // Import AppColors for gradient

// --- Helper Widget for the Gradient Button ---
class GradientButtonWrapper extends StatelessWidget {
  final Widget child;
  const GradientButtonWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // Your gradient from Primary to Accent
        gradient: const LinearGradient(colors: [
          AppColors.primaryColor,
          AppColors.accentColor,
        ]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}
// --- End Helper Widget ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _numQuestions = 5;
  double _quizDurationMinutes = 2;

  Widget _buildSlider(
      String label, double value, double min, double max, int divisions, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          // Use the "Body" text style, which is Light Gray in dark mode
          child: Text(label, style: Theme.of(context).primaryTextTheme.titleMedium),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // --- LOADING OVERLAY WIDGET ---
  Widget _buildLoadingOverlay() {
    return Container(
      // Full screen semi-transparent scrim
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/animations/loading.json', width: 200, height: 200),
            const SizedBox(height: 16),
            Text(
              'Generating...',
              // Use Sora font, colored white
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
  // --- END WIDGET ---

  @override
  Widget build(BuildContext context) {
    // --- MODIFICATION: Removed the Scaffold wrapper ---
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Stack(
          children: [
            const AnimatedBackground(), // Corrected class name
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimationLimiter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          Text(
                            'InsightEd',
                            // "Sora Bold" will be applied from the theme
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your intelligent learning companion.',
                            // "Inter Regular" (via primaryTextTheme)
                            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w300 // Lighter as you wanted
                                ),
                          ),
                          const SizedBox(height: 50),
                          SketchCard(
                            child: Column(
                              children: [
                                // --- GRADIENT BUTTON ---
                                GradientButtonWrapper(
                                  child: ElevatedButton.icon(
                                    onPressed: () => appProvider.pickAndUploadFile(),
                                    icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
                                    label: Text(appProvider.uploadedFilename == null ? 'Upload PDF' : 'Upload New PDF'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 54),
                                    ),
                                  ),
                                ),
                                if (appProvider.uploadedFilename != null) ...[
                                  // --- THIS IS THE UPDATED WIDGET ---
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Builder( // Use Builder to get the theme
                                      builder: (context) {
                                        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? Colors.white.withOpacity(0.1) // Glassy highlight
                                                : AppColors.primaryColor.withOpacity(0.1), // Light mode tint
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: isDarkMode
                                                  ? Colors.white.withOpacity(0.2)
                                                  : Colors.transparent,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.description_outlined,
                                                color: isDarkMode
                                                    ? AppColors.darkBodyText // Light gray icon
                                                    : AppColors.primaryColor, // Blue icon
                                                size: 20.0,
                                              ),
                                              const SizedBox(width: 12.0),
                                              Flexible(
                                                child: Text(
                                                  appProvider.uploadedFilename!,
                                                  textAlign: TextAlign.center,
                                                  style: isDarkMode
                                                      ? Theme.of(context).primaryTextTheme.bodyLarge // Light gray text
                                                      : Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryColor), // Blue text
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // --- END OF UPDATED WIDGET ---
                                  
                                  const Divider(height: 40),

                                  // --- GRADIENT BUTTON ---
                                  GradientButtonWrapper(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        appProvider.fetchSummary((summary) {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryScreen(summary: summary)));
                                        });
                                      },
                                      icon: const Icon(Icons.description_rounded, color: Colors.white),
                                      label: const Text('Generate Summary'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 54),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  _buildSlider(
                                    'Number of Questions: ${_numQuestions.round()}',
                                    _numQuestions, 1, 20, 19,
                                    (value) => setState(() => _numQuestions = value),
                                  ),
                                  _buildSlider(
                                    'Quiz Timer: ${_quizDurationMinutes.round()} minutes',
                                    _quizDurationMinutes, 1, 30, 29,
                                    (value) => setState(() => _quizDurationMinutes = value),
                                  ),
                                  const SizedBox(height: 20),
                                  // --- GRADIENT BUTTON ---
                                  GradientButtonWrapper(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        appProvider.fetchQuiz(_numQuestions.round(), (questions) {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(questions: questions, quizDurationInSeconds: _quizDurationMinutes.round() * 60)));
                                        });
                                      },
                                      icon: const Icon(Icons.quiz_rounded, color: Colors.white),
                                      label: const Text('Start Quiz'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 54),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (appProvider.errorMessage != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  appProvider.errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ), 

            if (appProvider.isLoading) _buildLoadingOverlay(),
          ],
        );
      },
    );
  }
}
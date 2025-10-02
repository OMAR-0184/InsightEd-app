import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/app_provider.dart';
import 'summary_screen.dart';
import 'quiz_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _numQuestions = 5;
  double _quizDurationMinutes = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Stack(
            children: [
              const AnimatedBackground(),
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
                            Text('InsightEd', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text('Your intelligent learning companion.', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 50),
                            GlassContainer(
                              child: Column(
                                children: [
                                  CustomButton(
                                    onPressed: () => appProvider.pickAndUploadFile(),
                                    text: appProvider.uploadedFilename == null ? 'Upload PDF' : 'Upload New PDF',
                                    icon: Icons.upload_file_rounded,
                                  ),
                                  if (appProvider.uploadedFilename != null) ...[
                                    const SizedBox(height: 20),
                                    Text('File: ${appProvider.uploadedFilename}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const Divider(height: 40),
                                    CustomButton(
                                      onPressed: () {
                                        appProvider.fetchSummary((summary) {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryScreen(summary: summary)));
                                        });
                                      },
                                      text: 'Generate Summary',
                                      icon: Icons.description_rounded,
                                    ),
                                    const SizedBox(height: 30),
                                    Text('Number of Questions: ${_numQuestions.round()}', textAlign: TextAlign.center),
                                    Slider(
                                      value: _numQuestions,
                                      min: 1,
                                      max: 20,
                                      divisions: 19,
                                      label: _numQuestions.round().toString(),
                                      onChanged: (double value) => setState(() => _numQuestions = value),
                                    ),
                                    Text('Quiz Timer: ${_quizDurationMinutes.round()} minutes', textAlign: TextAlign.center),
                                    Slider(
                                      value: _quizDurationMinutes,
                                      min: 1,
                                      max: 30,
                                      divisions: 29,
                                      label: '${_quizDurationMinutes.round()} min',
                                      onChanged: (double value) => setState(() => _quizDurationMinutes = value),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        appProvider.fetchQuiz(_numQuestions.round(), (questions) {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(questions: questions, quizDurationInSeconds: _quizDurationMinutes.round() * 60)));
                                        });
                                      },
                                      icon: const Icon(Icons.quiz_rounded),
                                      label: const Text('Generate Quiz'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (appProvider.isLoading)
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Lottie.asset('assets/animations/loading.json', width: 100, height: 100),
                              ),
                            if (appProvider.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(appProvider.errorMessage!, style: const TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
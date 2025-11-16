import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../models/quiz_question.dart';
import '../providers/app_provider.dart'; // Import AppProvider
import '../widgets/charts/results_pie_chart.dart';
import '../widgets/charts/time_per_question_chart.dart';
import '../theme/app_theme.dart';

class QuizResultsScreen extends StatelessWidget {
  final List<QuizQuestion> questions;
  final List<String?> userAnswers;
  final List<int> timePerQuestion;

  const QuizResultsScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.timePerQuestion,
  });

  @override
  Widget build(BuildContext context) {
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].answer == userAnswers[i]) {
        correctAnswers++;
      }
    }

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- NEW: Watch AppProvider for state changes ---
    final appProvider = context.watch<AppProvider>();
    final pdfName = appProvider.uploadedFilename;
    // --- END NEW ---

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results & Analysis'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Your Score: $correctAnswers / ${questions.length}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text('Score Breakdown', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(
              height: 200,
              child: ResultsPieChart(
                correctAnswers: correctAnswers,
                totalQuestions: questions.length,
              ),
            ),
            const SizedBox(height: 40),
            Text('Time Per Question (Seconds)', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: TimePerQuestionChart(timePerQuestion: timePerQuestion),
            ),
            const SizedBox(height: 40),
            Text('Answer Review', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            ...List.generate(questions.length, (index) {
              final question = questions[index];
              final userAnswer = userAnswers[index];
              final isCorrect = question.answer == userAnswer;

              final Color correctBackgroundColor = isDarkMode ? Colors.green.withOpacity(0.15) : Colors.green.shade50;
              final Color incorrectBackgroundColor = isDarkMode ? Colors.red.withOpacity(0.15) : Colors.red.shade50;
              
              final Color correctBorderColor = isDarkMode ? Colors.green.shade700 : Colors.green.shade200;
              final Color incorrectBorderColor = isDarkMode ? Colors.red.shade700 : Colors.red.shade200;

              // --- NEW: Get bookmark status for this specific question ---
              final bool isBookmarked = pdfName != null
                  ? appProvider.isBookmarked(pdfName, question)
                  : false;
              // --- END NEW ---

              return Card(
                color: isCorrect ? correctBackgroundColor : incorrectBackgroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isCorrect ? correctBorderColor : incorrectBorderColor)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- MODIFIED: Wrapped question text in a Row with the icon ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Q${index + 1}: ${question.question}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect ? AppColors.primaryColor : Colors.red,
                                  ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? AppColors.primaryColor : null,
                            ),
                            onPressed: pdfName == null
                                ? null
                                : () {
                                    appProvider.toggleBookmark(pdfName, question);
                                  },
                            tooltip: 'Bookmark question',
                          ),
                        ],
                      ),
                      // --- END MODIFICATION ---
                      
                      const SizedBox(height: 12),
                      Text('Your Answer: ${userAnswer ?? "Not Answered"}',
                          style: Theme.of(context).textTheme.bodyLarge),
                      
                      // Only show "Correct Answer" if they got it wrong
                      if (!isCorrect) ...[
                        const SizedBox(height: 8),
                        Text('Correct Answer: ${question.answer}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ],

                      // ALWAYS show the explanation
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Explanation: ${question.description}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8)
                          )),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
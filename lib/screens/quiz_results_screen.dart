import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../widgets/charts/results_pie_chart.dart';
import '../widgets/charts/time_per_question_chart.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results & Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Your Score: $correctAnswers / ${questions.length}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            const Text('Score Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: ResultsPieChart(
                correctAnswers: correctAnswers,
                totalQuestions: questions.length,
              ),
            ),
            const SizedBox(height: 40),
            const Text('Time Per Question (Seconds)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: TimePerQuestionChart(timePerQuestion: timePerQuestion),
            ),
            const SizedBox(height: 40),
            const Text('Answer Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...List.generate(questions.length, (index) {
              final question = questions[index];
              final userAnswer = userAnswers[index];
              final isCorrect = question.answer == userAnswer;

              return Card(
                color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Q${index + 1}: ${question.question}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Your Answer: ${userAnswer ?? "Not Answered"}'),
                      if (!isCorrect) ...[
                        Text('Correct Answer: ${question.answer}'),
                        const SizedBox(height: 8),
                        Text('Explanation: ${question.description}'),
                      ]
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
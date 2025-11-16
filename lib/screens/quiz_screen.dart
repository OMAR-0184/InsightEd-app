import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/quiz_question.dart';
import 'quiz_results_screen.dart';
import '../widgets/quiz_option.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final int quizDurationInSeconds;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.quizDurationInSeconds,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  Timer? _timer;
  late int _timerValue;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.userAnswers = List.filled(widget.questions.length, null);
    appProvider.timePerQuestion = List.filled(widget.questions.length, 0);
    _timerValue = widget.quizDurationInSeconds;
    _startTimer();
    _stopwatch.start();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timerValue > 0) {
            _timerValue--;
          } else {
            _submitQuiz();
          }
        });
      }
    });
  }

  void _recordTime() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    _stopwatch.stop();
    if (_currentIndex < appProvider.timePerQuestion.length) {
      appProvider.timePerQuestion[_currentIndex] += _stopwatch.elapsed.inSeconds;
    }
    _stopwatch.reset();
    _stopwatch.start();
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      _recordTime();
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      _recordTime();
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _jumpToQuestion(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.questions.length || newIndex == _currentIndex) {
      return;
    }
    _recordTime();
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _submitQuiz() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    _timer?.cancel();
    _recordTime();
    _stopwatch.stop();
    appProvider.calculateScore();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            questions: widget.questions,
            userAnswers: appProvider.userAnswers,
            timePerQuestion: appProvider.timePerQuestion,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildQuestionIndexRow(AppProvider appProvider) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // --- THIS IS THE FIX ---
      // The padding goes on the SingleChildScrollView, not the Row.
      padding: const EdgeInsets.symmetric(horizontal: 20.0), 
      child: Row(
        // Removed the 'padding' property from here
        children: List.generate(widget.questions.length, (index) {
          final bool isCurrent = index == _currentIndex;
          final bool isAnswered = appProvider.userAnswers[index] != null;
          
          Color bgColor = Colors.transparent;
          Color textColor = isDarkMode ? AppColors.darkBodyText : AppColors.lightTextColor;
          BoxBorder? border;

          if (isCurrent) {
            bgColor = AppColors.primaryColor;
            textColor = Colors.white;
          } else if (isAnswered) {
            bgColor = isDarkMode ? AppColors.darkCardColor : Colors.grey.shade200;
            textColor = isDarkMode ? AppColors.darkBodyText : AppColors.lightTextColor;
          } else { 
            border = Border.all(color: isDarkMode ? AppColors.darkBorderColor : Colors.grey.shade300);
            textColor = isDarkMode ? AppColors.darkBodyText.withOpacity(0.5) : Colors.grey.shade500;
          }

          return GestureDetector(
            onTap: () => _jumpToQuestion(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0), 
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                border: border,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: textColor,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
  // --- END FIX ---

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final question = widget.questions[_currentIndex];
    final isLastQuestion = _currentIndex == widget.questions.length - 1;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    // --- NEW: Get bookmark state ---
    final currentPdfName = appProvider.uploadedFilename;
    final bool isBookmarked = currentPdfName != null
        ? appProvider.isBookmarked(currentPdfName, question)
        : false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${widget.questions.length}'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        // --- NEW: Bookmark Action Button ---
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.primaryColor : null,
            ),
            onPressed: currentPdfName == null
                ? null
                : () {
                    appProvider.toggleBookmark(currentPdfName, question);
                  },
            tooltip: 'Bookmark question',
          ),
          const SizedBox(width: 8), // Add a bit of padding
        ],
        // --- END: Bookmark Action Button ---
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: textColor?.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(_timerValue),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor?.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 48,
                lineHeight: 14.0,
                percent: _timerValue / widget.quizDurationInSeconds,
                barRadius: const Radius.circular(8),
                backgroundColor: Colors.grey.shade300,
                progressColor: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildQuestionIndexRow(appProvider),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      question.question,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ...question.options.map((option) => QuizOption(
                          optionText: option,
                          isSelected: appProvider.userAnswers[_currentIndex] == option,
                          onTap: () {
                            appProvider.submitAnswer(_currentIndex, option);
                          },
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _currentIndex == 0 ? null : _previousQuestion,
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: isLastQuestion ? _submitQuiz : _nextQuestion,
                    child: Text(isLastQuestion ? 'Submit' : 'Next'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
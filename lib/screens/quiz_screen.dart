import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/quiz_question.dart';
import 'quiz_results_screen.dart';
import '../widgets/quiz_option.dart';
import '../providers/app_provider.dart';

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
    appProvider.timePerQuestion[_currentIndex] += _stopwatch.elapsed.inSeconds;
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

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final question = widget.questions[_currentIndex];
    final isLastQuestion = _currentIndex == widget.questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - Question ${_currentIndex + 1}/${widget.questions.length}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 48,
              lineHeight: 20.0,
              percent: _timerValue / widget.quizDurationInSeconds,
              center: Text("$_timerValue s"),
              barRadius: const Radius.circular(10),
              progressColor: Colors.green,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      question.question,
                      style: Theme.of(context).textTheme.headlineSmall,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentIndex == 0 ? null : _previousQuestion,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: isLastQuestion ? _submitQuiz : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastQuestion ? Colors.green : Theme.of(context).primaryColor,
                  ),
                  child: Text(isLastQuestion ? 'Submit' : 'Next'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
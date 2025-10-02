import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ResultsPieChart extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const ResultsPieChart({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: correctAnswers.toDouble(),
            title: 'Correct',
            radius: 50,
          ),
          PieChartSectionData(
            color: Colors.red,
            value: (totalQuestions - correctAnswers).toDouble(),
            title: 'Incorrect',
            radius: 50,
          ),
        ],
      ),
    );
  }
}
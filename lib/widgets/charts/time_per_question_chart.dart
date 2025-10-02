import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TimePerQuestionChart extends StatelessWidget {
  final List<int> timePerQuestion;

  const TimePerQuestionChart({
    super.key,
    required this.timePerQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (timePerQuestion.reduce((a, b) => a > b ? a : b) * 1.2)
            .toDouble(), // Add 20% padding to the max height
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey, // Corrected this line
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'Q${group.x.toInt() + 1}\n',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.toY - 1).toStringAsFixed(0) + 's',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text('Q${value.toInt() + 1}',
                    style: const TextStyle(fontSize: 14));
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(timePerQuestion.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: timePerQuestion[index].toDouble() +
                      1, // Add 1 to ensure zero values are visible
                  color: Colors.lightBlueAccent,
                  width: 22,
                  borderRadius: BorderRadius.circular(4))
            ],
          );
        }),
      ),
    );
  }
}
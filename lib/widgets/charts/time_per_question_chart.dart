// --- FIX 1: Corrected package import ---
import 'package:fl_chart/fl_chart.dart'; 
import 'package:flutter/material.dart';
// --- FIX 2: Corrected relative path (two levels up) ---
import '../../theme/app_theme.dart'; 

class TimePerQuestionChart extends StatelessWidget {
  final List<int> timePerQuestion;

  const TimePerQuestionChart({
    super.key,
    required this.timePerQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color gridColor = isDarkMode ? Colors.white24 : Colors.black12;
    final Color titleColor = isDarkMode ? Colors.white70 : Colors.black54;

    final double maxTime = (timePerQuestion.isEmpty
            ? 0.0
            : timePerQuestion.reduce((a, b) => a > b ? a : b).toDouble());

    final double calculatedMaxY = (maxTime + 1) * 1.2;
    final double finalMaxY = calculatedMaxY < 5.0 ? 5.0 : calculatedMaxY;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: finalMaxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
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
                return Text(
                  'Q${value.toInt() + 1}',
                  style: TextStyle(fontSize: 14, color: titleColor),
                );
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: finalMaxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: gridColor,
              strokeWidth: 1,
              dashArray: [3, 3],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(timePerQuestion.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: timePerQuestion[index].toDouble() +
                      1, 
                  color: AppColors.primaryColor.withOpacity(0.8),
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ))
            ],
          );
        }),
      ),
    );
  }
}
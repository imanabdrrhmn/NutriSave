import 'package:flutter/material.dart';
import '../models/daily_calories.dart';
import 'package:fl_chart/fl_chart.dart';

class CaloriesChart extends StatelessWidget {
  final List<DailyCalories> dailyCalories;

  CaloriesChart({required this.dailyCalories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true),
            bottomTitles: SideTitles(showTitles: true),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: dailyCalories
                  .asMap()
                  .entries
                  .map((entry) =>
                  FlSpot(entry.key.toDouble(), entry.value.totalCalories.toDouble()))
                  .toList(),
              isCurved: true,
              colors: [Colors.teal],
              barWidth: 4,
              belowBarData: BarAreaData(show: true, colors: [
                Colors.teal.withOpacity(0.3),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

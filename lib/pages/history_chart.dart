import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HistoryChart extends StatelessWidget {
  HistoryChart({super.key});

  final box = Hive.box('history');

  @override
  Widget build(BuildContext context) {

    final data = box.values.toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(data.length, (i) {
                return FlSpot(i.toDouble(), i * 1000);
              }),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
            )
          ],
        ),
      ),
    );
  }
}
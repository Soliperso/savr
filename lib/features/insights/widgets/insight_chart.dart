import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InsightChart extends StatelessWidget {
  final List<double> data;
  final Color lineColor;

  const InsightChart({super.key, required this.data, required this.lineColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: data.reduce((curr, next) => curr < next ? curr : next),
          maxY: data.reduce((curr, next) => curr > next ? curr : next),
          lineBarsData: [
            LineChartBarData(
              spots:
                  data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value);
                  }).toList(),
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

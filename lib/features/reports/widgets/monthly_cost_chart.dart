// Widget to display monthly maintenance costs chart
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MonthlyCostChart extends StatelessWidget {
  final Map<String, double> monthlyCosts;
  final double maxY;

  const MonthlyCostChart({
    super.key,
    required this.monthlyCosts,
    this.maxY = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyCosts.isEmpty) {
      return const Center(
        child: Text('No cost data available'),
      );
    }

    final sortedEntries = monthlyCosts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = <FlSpot>[];
    for (var i = 0; i < sortedEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedEntries[i].value));
    }

    final calculatedMaxY = maxY > 0
        ? maxY
        : (sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2);

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: calculatedMaxY / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withValues(alpha: 0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= sortedEntries.length) {
                      return const Text('');
                    }
                    final monthKey = sortedEntries[value.toInt()].key;
                    final parts = monthKey.split('-');
                    final month = int.parse(parts[1]);
                    final monthName = DateFormat('MMM').format(DateTime(2000, month));
                    return Text(
                      monthName,
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: calculatedMaxY / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            minX: 0,
            maxX: (sortedEntries.length - 1).toDouble(),
            minY: 0,
            maxY: calculatedMaxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Theme.of(context).primaryColor,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

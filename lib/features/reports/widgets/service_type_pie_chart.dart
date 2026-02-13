// Widget to display service type distribution pie chart
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ServiceTypePieChart extends StatelessWidget {
  final Map<String, double> costsByType;

  const ServiceTypePieChart({
    super.key,
    required this.costsByType,
  });

  @override
  Widget build(BuildContext context) {
    if (costsByType.isEmpty) {
      return const Center(
        child: Text('No service data available'),
      );
    }

    final sortedEntries = costsByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 and group rest as "Other"
    final topEntries = sortedEntries.take(5).toList();
    final otherSum = sortedEntries.skip(5).fold(0.0, (sum, e) => sum + e.value);
    
    if (otherSum > 0) {
      topEntries.add(MapEntry('Other', otherSum));
    }

    final total = topEntries.fold(0.0, (sum, e) => sum + e.value);

    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sections: topEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final percentage = (data.value / total * 100).toStringAsFixed(1);

            return PieChartSectionData(
              color: _getColor(index),
              value: data.value,
              title: '$percentage%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  Color _getColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.grey,
    ];
    return colors[index % colors.length];
  }
}

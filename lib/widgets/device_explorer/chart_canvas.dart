import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../providers/explorer_provider.dart';

class ChartCanvas extends StatelessWidget {
  const ChartCanvas({
    super.key,
    required this.series,
    required this.logScale,
    required this.onTouchX,
  });

  final List<ExplorerSeries> series;
  final bool logScale;
  final ValueChanged<double?> onTouchX;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return const Center(child: Text('No curves for current selection.'));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchCallback: (event, response) {
            onTouchX(response?.lineBarSpots?.first.x);
          },
        ),
        lineBarsData: [
          for (var i = 0; i < series.length; i++)
            LineChartBarData(
              spots: [
                for (var j = 0; j < series[i].xs.length; j++)
                  FlSpot(
                    series[i].xs[j],
                    logScale ? _safeLog(series[i].ys[j]) : series[i].ys[j],
                  ),
              ],
              isCurved: false,
              barWidth: 2,
              color: _colorForIndex(i),
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );
  }

  double _safeLog(double y) {
    final clamped = y < 1e-15 ? 1e-15 : y;
    return clamped.log();
  }

  Color _colorForIndex(int i) {
    const palette = [
      Color(0xFF4FC3F7),
      Color(0xFFFFB74D),
      Color(0xFF81C784),
      Color(0xFFBA68C8),
      Color(0xFFE57373),
      Color(0xFFA1887F),
    ];
    return palette[i % palette.length];
  }
}

extension on double {
  double log() => math.log(this);
}

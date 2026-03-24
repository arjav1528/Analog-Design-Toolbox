import 'package:flutter/material.dart';

class CurveLegend extends StatelessWidget {
  const CurveLegend({
    super.key,
    required this.labels,
    required this.colorForIndex,
  });

  final List<String> labels;
  final Color Function(int) colorForIndex;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colorForIndex(i),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(labels[i]),
            ],
          ),
      ],
    );
  }
}

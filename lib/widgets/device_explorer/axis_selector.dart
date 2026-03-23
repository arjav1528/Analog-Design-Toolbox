import 'package:flutter/material.dart';

class AxisSelector extends StatelessWidget {
  const AxisSelector({
    super.key,
    required this.columns,
    required this.xAxis,
    required this.yAxis,
    required this.onXAxisChanged,
    required this.onYAxisChanged,
  });

  final List<String> columns;
  final String xAxis;
  final String yAxis;
  final ValueChanged<String> onXAxisChanged;
  final ValueChanged<String> onYAxisChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Axes', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: xAxis,
          decoration: const InputDecoration(
            labelText: 'X Axis',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: columns
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              onXAxisChanged(v);
            }
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: yAxis,
          decoration: const InputDecoration(
            labelText: 'Y Axis',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: columns
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              onYAxisChanged(v);
            }
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ConstantPanel extends StatelessWidget {
  const ConstantPanel({
    super.key,
    required this.vsb,
    required this.vds,
    required this.availableLengths,
    required this.selectedLengths,
    required this.onVsbChanged,
    required this.onVdsChanged,
    required this.onToggleLength,
  });

  final double vsb;
  final double vds;
  final List<double> availableLengths;
  final Set<double> selectedLengths;
  final ValueChanged<double> onVsbChanged;
  final ValueChanged<double> onVdsChanged;
  final ValueChanged<double> onToggleLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fix Constants', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: vsb.toStringAsFixed(3),
          decoration: const InputDecoration(
            labelText: 'Vsb (V)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) {
            final parsed = double.tryParse(v.trim());
            if (parsed != null) {
              onVsbChanged(parsed);
            }
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: vds.toStringAsFixed(3),
          decoration: const InputDecoration(
            labelText: 'Vds (V)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) {
            final parsed = double.tryParse(v.trim());
            if (parsed != null) {
              onVdsChanged(parsed);
            }
          },
        ),
        const SizedBox(height: 12),
        Text('L (multi-select)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        SizedBox(
          height: 180,
          child: ListView.builder(
            itemCount: availableLengths.length,
            itemBuilder: (context, index) {
              final l = availableLengths[index];
              final checked = selectedLengths.contains(l);
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: checked,
                onChanged: (_) => onToggleLength(l),
                title: Text(_formatLength(l)),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatLength(double lMeters) {
    if (lMeters >= 1e-6) {
      return '${(lMeters * 1e6).toStringAsFixed(2)}um';
    }
    return '${(lMeters * 1e9).toStringAsFixed(0)}nm';
  }
}

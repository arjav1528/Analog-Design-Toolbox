import 'package:flutter/material.dart';

class UnitInputField extends StatelessWidget {
  const UnitInputField({
    super.key,
    required this.initialValue,
    required this.unit,
    required this.onChanged,
  });

  final String initialValue;
  final String unit;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        suffixText: unit,
      ),
    );
  }
}

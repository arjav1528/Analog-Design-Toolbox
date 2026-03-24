import 'package:flutter/material.dart';

import '../../models/formula_param.dart';
import 'param_input_row.dart';

class FormulaTableWidget extends StatelessWidget {
  const FormulaTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const _HeaderRow(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: ParamId.values.length,
                itemBuilder: (context, index) {
                  return ParamInputRow(paramId: ParamId.values[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    return Row(
      children: [
        Expanded(flex: 3, child: Text('Parameter', style: style)),
        Expanded(flex: 2, child: Text('Symbol', style: style)),
        Expanded(flex: 4, child: Text('Value', style: style)),
        const SizedBox(width: 12),
        Expanded(flex: 5, child: Text('Source', style: style)),
      ],
    );
  }
}

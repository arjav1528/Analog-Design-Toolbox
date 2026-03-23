import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/formula_provider.dart';
import '../widgets/formula_table/auto_plot_panel.dart';
import '../widgets/formula_table/formula_table_widget.dart';

class FormulaTableScreen extends ConsumerStatefulWidget {
  const FormulaTableScreen({super.key});

  @override
  ConsumerState<FormulaTableScreen> createState() => _FormulaTableScreenState();
}

class _FormulaTableScreenState extends ConsumerState<FormulaTableScreen> {
  bool _showGraphs = false;

  @override
  Widget build(BuildContext context) {
    final plotCount = ref.watch(formulaProvider).result.plots.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Formula Table',
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: plotCount == 0
                    ? null
                    : () => setState(() => _showGraphs = !_showGraphs),
                child: Text(_showGraphs ? 'Hide Graphs' : 'Show Graphs'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  ref.read(formulaProvider.notifier).clear();
                  setState(() => _showGraphs = false);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Expanded(flex: 5, child: FormulaTableWidget()),
          if (_showGraphs) ...[
            const SizedBox(height: 12),
            const Expanded(
              flex: 4,
              child: SingleChildScrollView(child: AutoPlotPanel()),
            ),
          ],
        ],
      ),
    );
  }
}

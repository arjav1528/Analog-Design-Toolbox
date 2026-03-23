import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/formula_param.dart';
import '../../providers/formula_provider.dart';
import '../shared/engineering_notation.dart';
import '../shared/unit_input_field.dart';

class ParamInputRow extends ConsumerWidget {
  const ParamInputRow({super.key, required this.paramId});

  final ParamId paramId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(formulaProvider);
    final notifier = ref.read(formulaProvider.notifier);
    final meta = paramId.meta;

    final userSi = state.userInputs[paramId];
    final derivedSi = state.result.known[paramId];
    final hasUserValue = userSi != null;
    final hasDerivedValue = derivedSi != null;
    final isEditable = hasUserValue || !hasDerivedValue;

    final source = hasUserValue
        ? 'user input'
        : state.result.derivedVia[paramId] != null
            ? 'derived: ${state.result.derivedVia[paramId]}'
            : 'missing';

    final valueText = hasDerivedValue
        ? formatEngineering(derivedSi, meta.toSiFactor)
        : 'AUTO-PLOT';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(meta.name)),
          Expanded(flex: 2, child: Text(meta.symbol)),
          Expanded(
            flex: 4,
            child: isEditable
                ? UnitInputField(
                    key: ValueKey('${paramId.name}-${userSi ?? 'null'}'),
                    initialValue: hasUserValue
                        ? formatEngineering(userSi, meta.toSiFactor)
                        : '',
                    unit: meta.unit,
                    onChanged: (raw) {
                      final parsed = double.tryParse(raw.trim());
                      notifier.setParam(paramId, parsed);
                    },
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: hasDerivedValue
                        ? Tooltip(
                            message: state.result.derivedVia[paramId] ?? '',
                            child: Text('$valueText ${meta.unit}'),
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Chip(
                              label: Text(valueText),
                              backgroundColor: Colors.orange.withValues(
                                alpha: 0.20,
                              ),
                              side: const BorderSide(color: Colors.orange),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              source,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

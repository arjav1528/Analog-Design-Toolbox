import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../providers/explorer_provider.dart';
import '../providers/lut_provider.dart';
import '../widgets/device_explorer/axis_selector.dart';
import '../widgets/device_explorer/chart_canvas.dart';
import '../widgets/device_explorer/constant_panel.dart';
import '../widgets/device_explorer/curve_legend.dart';

class DeviceExplorerScreen extends ConsumerWidget {
  const DeviceExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lutState = ref.watch(lutProvider);
    final explorer = ref.watch(explorerProvider);
    final explorerNotifier = ref.read(explorerProvider.notifier);

    final lut = lutState.data;
    if (lut == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Device Explorer',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                FilledButton(
                  onPressed: lutState.loading
                      ? null
                      : () => ref.read(lutProvider.notifier).pickAndLoadCsv(),
                  child: Text(lutState.loading ? 'Loading...' : 'Load CSV LUT'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Load a CSV LUT to get started.'),
                    if (lutState.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        lutState.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (explorer.selectedLengths.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        explorerNotifier.initializeFromLut(lut);
      });
    }

    final columns = lut.columns;
    final allowedAxes = columns
        .where((c) => c != 'L' && c != 'W' && c != 'vds' && c != 'vsb')
        .toList();

    final series = explorerNotifier.seriesFor(lut);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Device Explorer',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              FilledButton(
                onPressed: lutState.loading
                    ? null
                    : () => ref.read(lutProvider.notifier).pickAndLoadCsv(),
                child: Text(lutState.loading ? 'Loading...' : 'Load CSV LUT'),
              ),
              const SizedBox(width: 8),
              Text(
                lutState.filePath?.split('/').last ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (lutState.error != null) ...[
            const SizedBox(height: 8),
            Text(
              lutState.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: MultiSplitView(
              initialAreas: [
                Area(size: 320, min: 280),
                Area(),
              ],
              builder: (context, area) {
                if (area.index == 0) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AxisSelector(
                          columns: allowedAxes,
                          xAxis: allowedAxes.contains(explorer.xAxis)
                              ? explorer.xAxis
                              : allowedAxes.first,
                          yAxis: allowedAxes.contains(explorer.yAxis)
                              ? explorer.yAxis
                              : allowedAxes[allowedAxes.length > 1 ? 1 : 0],
                          onXAxisChanged: (v) =>
                              explorerNotifier.setAxis(xAxis: v),
                          onYAxisChanged: (v) =>
                              explorerNotifier.setAxis(yAxis: v),
                        ),
                        const SizedBox(height: 12),
                        ConstantPanel(
                          vsb: explorer.fixedVsb,
                          vds: explorer.fixedVds,
                          availableLengths: lut.uniqueValues('L'),
                          selectedLengths: explorer.selectedLengths,
                          onVsbChanged: (v) =>
                              explorerNotifier.setFixed(vsb: v),
                          onVdsChanged: (v) =>
                              explorerNotifier.setFixed(vds: v),
                          onToggleLength: explorerNotifier.toggleLength,
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: explorer.logScale,
                          onChanged: explorerNotifier.setLogScale,
                          title: const Text('Log Y'),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ChartCanvas(
                          series: series,
                          logScale: explorer.logScale,
                          onTouchX: explorerNotifier.setTouchX,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CurveLegend(
                        labels: series.map((s) => s.label).toList(),
                        colorForIndex: _colorForIndex,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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

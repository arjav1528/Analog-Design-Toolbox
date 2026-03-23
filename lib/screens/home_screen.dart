import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'formula_table_screen.dart';

enum AppSection { formulaTable, deviceExplorer }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppSection _section = AppSection.formulaTable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.all,
            selectedIndex: _section.index,
            onDestinationSelected: (index) {
              setState(() => _section = AppSection.values[index]);
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.table_chart_outlined),
                selectedIcon: Icon(Icons.table_chart),
                label: Text('Formula Table'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.show_chart_outlined),
                selectedIcon: Icon(Icons.show_chart),
                label: Text('Device Explorer'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: MultiSplitView(
              axis: Axis.horizontal,
              initialAreas: [
                Area(size: 320, min: 280),
                Area(),
              ],
              builder: (context, area) {
                if (area.index == 0) {
                  return _buildLeftPanel(context);
                }
                return _buildMainPanel(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _section == AppSection.formulaTable
                ? 'Formula Table Controls'
                : 'Device Explorer Controls',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Step 1 scaffold placeholder',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMainPanel(BuildContext context) {
    if (_section == AppSection.formulaTable) {
      return const FormulaTableScreen();
    }

    return const Padding(
      padding: EdgeInsets.all(20),
      child: _SectionPlaceholder(
        title: 'Device Explorer',
        subtitle: 'LUT loading and charting will be added in Step 6.',
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

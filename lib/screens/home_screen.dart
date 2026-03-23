import 'package:flutter/material.dart';

import 'device_explorer_screen.dart';
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
          Expanded(child: _buildMainPanel(context)),
        ],
      ),
    );
  }

  Widget _buildMainPanel(BuildContext context) {
    if (_section == AppSection.formulaTable) {
      return const FormulaTableScreen();
    }

    return const DeviceExplorerScreen();
  }
}

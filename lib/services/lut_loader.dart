import 'dart:io';
import 'dart:math' as math;

import '../models/lut_data.dart';

class LutLoader {
  const LutLoader();

  static const List<String> rawColumns = [
    'L',
    'W',
    'vgs',
    'vds',
    'vsb',
    'gm',
    'gmb',
    'gds',
    'ron',
    'vdsat',
    'vth',
    'vearly',
    'id',
    'cgg',
    'cgs',
    'cgb',
    'cgd',
    'cds',
    'beff',
  ];

  static const List<String> derivedColumns = [
    'gmid',
    'jd',
    'ft',
    'intrinsic',
    'fom_noise',
    'fom_bw',
    'rds',
  ];

  Future<LutData> loadFromFilePath(String path) async {
    final content = await File(path).readAsString();
    return parseFromString(content);
  }

  LutData parseFromString(String content) {
    final rows = <Map<String, double>>[];
    final lines = content.split(RegExp(r'\r?\n'));

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < rawColumns.length) {
        continue;
      }

      final maybeFirst = double.tryParse(parts.first);
      if (maybeFirst == null) {
        // Skip header/non-numeric rows.
        continue;
      }

      final row = <String, double>{};
      var parseFailed = false;
      for (var i = 0; i < rawColumns.length; i++) {
        final value = double.tryParse(parts[i]);
        if (value == null || value.isNaN || value.isInfinite) {
          parseFailed = true;
          break;
        }
        row[rawColumns[i]] = value;
      }
      if (parseFailed) {
        continue;
      }

      _addDerivedColumns(row);
      rows.add(row);
    }

    final allColumns = <String>[...rawColumns, ...derivedColumns];
    final uniqueAxisValues = _buildUniqueAxisValues(rows, allColumns);

    return LutData(
      rows: rows,
      columns: allColumns,
      uniqueAxisValues: uniqueAxisValues,
    );
  }

  Map<String, List<double>> _buildUniqueAxisValues(
    List<Map<String, double>> rows,
    List<String> columns,
  ) {
    final maps = <String, Set<double>>{
      for (final c in columns) c: <double>{},
    };
    for (final row in rows) {
      for (final c in columns) {
        final val = row[c];
        if (val != null && !val.isNaN && !val.isInfinite) {
          maps[c]!.add(val);
        }
      }
    }
    return {
      for (final entry in maps.entries)
        entry.key: (entry.value.toList()..sort((a, b) => a.compareTo(b))),
    };
  }

  void _addDerivedColumns(Map<String, double> row) {
    final gm = row['gm']!;
    final id = row['id']!;
    final w = row['W']!;
    final cgg = row['cgg']!;
    final gds = row['gds']!;

    row['gmid'] = _safeDiv(gm, id);
    row['jd'] = _safeDiv(id, w);
    row['ft'] = _safeDiv(gm, (2 * math.pi * cgg));
    row['intrinsic'] = _safeDiv(gm, gds);
    row['fom_noise'] = row['ft']! * row['gmid']!;
    row['fom_bw'] = row['ft']! * row['intrinsic']!;
    row['rds'] = _safeDiv(1.0, gds);
  }

  double _safeDiv(double a, double b) {
    if (b.abs() < 1e-30) {
      return 0.0;
    }
    final v = a / b;
    if (v.isNaN || v.isInfinite) {
      return 0.0;
    }
    return v;
  }
}

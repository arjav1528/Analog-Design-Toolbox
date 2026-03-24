import '../models/lut_data.dart';

class LutQuery {
  const LutQuery();

  List<double> uniqueValues(LutData lut, String param) {
    return List<double>.from(lut.uniqueValues(param));
  }

  double snapToClosest(List<double> uniques, double value) {
    if (uniques.isEmpty) {
      return value;
    }
    var best = uniques.first;
    var bestDist = (best - value).abs();
    for (final v in uniques.skip(1)) {
      final d = (v - value).abs();
      if (d < bestDist) {
        best = v;
        bestDist = d;
      }
    }
    return best;
  }

  List<Map<String, double>> filterRows(
    LutData lut,
    Map<String, double> fixedParams,
  ) {
    return lut.rows.where((row) {
      for (final entry in fixedParams.entries) {
        final rowValue = row[entry.key];
        if (rowValue == null) {
          return false;
        }
        if ((rowValue - entry.value).abs() > 1e-12) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  (List<double> xs, List<double> ys) extractSeries(
    List<Map<String, double>> filtered,
    String xCol,
    String yCol,
  ) {
    final pairs = <(double x, double y)>[];
    for (final row in filtered) {
      final x = row[xCol];
      final y = row[yCol];
      if (x == null || y == null || x.isNaN || y.isNaN) {
        continue;
      }
      if (x.isInfinite || y.isInfinite) {
        continue;
      }
      pairs.add((x, y));
    }
    pairs.sort((a, b) => a.$1.compareTo(b.$1));
    return (
      pairs.map((p) => p.$1).toList(),
      pairs.map((p) => p.$2).toList(),
    );
  }
}

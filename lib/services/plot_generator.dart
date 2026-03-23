import '../models/formula_param.dart';
import '../models/formula_rule.dart';
import '../models/solver_result.dart';

class PlotGenerator {
  const PlotGenerator();

  static const int pointCount = 200;

  PlotData? generateSingleMissingInputPlot({
    required ParamId targetParam,
    required FormulaRule rule,
    required ParamId missingInput,
    required Map<ParamId, double> known,
  }) {
    final range = _defaultSweepRange(missingInput);
    if (range == null) {
      return null;
    }

    final xs = <double>[];
    final ys = <double>[];

    for (final x in _linspace(range.$1, range.$2, pointCount)) {
      final trial = Map<ParamId, double>.from(known);
      trial[missingInput] = x;
      final y = rule.compute(trial);
      if (y == null || y.isNaN || y.isInfinite) {
        continue;
      }
      xs.add(x);
      ys.add(y);
    }

    if (xs.isEmpty || ys.isEmpty) {
      return null;
    }

    final targetMeta = targetParam.meta;
    final missingMeta = missingInput.meta;
    return PlotData(
      xParam: missingInput,
      yParam: targetParam,
      xs: xs,
      ys: ys,
      title: '${targetMeta.symbol} vs ${missingMeta.symbol}',
      subtitle: 'Auto-plot from ${rule.expression}',
    );
  }

  List<double> _linspace(double min, double max, int count) {
    if (count <= 1) {
      return <double>[min];
    }
    final step = (max - min) / (count - 1);
    return List<double>.generate(count, (i) => min + step * i);
  }

  (double, double)? _defaultSweepRange(ParamId param) {
    switch (param) {
      case ParamId.id:
        return (1e-7, 1e-2);
      case ParamId.vgs:
      case ParamId.vth:
      case ParamId.vov:
        return (1e-3, 2.0);
      case ParamId.gm:
        return (1e-7, 0.1);
      case ParamId.gmId:
        return (1.0, 40.0);
      case ParamId.wl:
        return (0.1, 1000.0);
      case ParamId.uCox:
        return (1e-7, 1e-2);
      case ParamId.ro:
        return (10.0, 1e9);
      case ParamId.lambda:
        return (1e-4, 1.0);
      case ParamId.av0:
        return (1.0, 1e5);
      case ParamId.cgs:
        return (1e-16, 1e-10);
      case ParamId.ft:
        return (1e5, 1e12);
    }
  }
}

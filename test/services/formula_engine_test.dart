import 'package:adt/models/formula_param.dart';
import 'package:adt/services/formula_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormulaEngine', () {
    test('derives VOV, gm, gm/ID from VGS, VTH, ID', () {
      final engine = FormulaEngine();
      final result = engine.solve({
        ParamId.vgs: 0.8,
        ParamId.vth: 0.4,
        ParamId.id: 10e-6,
      });

      expect(result.known[ParamId.vov], closeTo(0.4, 1e-12));
      expect(result.known[ParamId.gm], closeTo(50e-6, 1e-12));
      expect(result.known[ParamId.gmId], closeTo(5.0, 1e-12));
    });

    test('handles divide-by-zero guard by not deriving invalid values', () {
      final engine = FormulaEngine();
      final result = engine.solve({
        ParamId.vov: 0.0,
        ParamId.id: 10e-6,
      });

      expect(result.known.containsKey(ParamId.gm), isFalse);
      expect(result.known.containsKey(ParamId.gmId), isFalse);
    });

    test('generates auto plots when exactly one input missing', () {
      final engine = FormulaEngine();
      final result = engine.solve({
        ParamId.id: 10e-6,
      });

      expect(result.plots, isNotEmpty);
      expect(
        result.plots.any((p) => p.yParam == ParamId.ro || p.yParam == ParamId.gm),
        isTrue,
      );
    });
  });
}

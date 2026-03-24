import 'package:adt/services/lut_loader.dart';
import 'package:adt/services/lut_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LUT services', () {
    test('parses LUT rows and derives required columns', () {
      const sample = '''
L W vgs vds vsb gm gmb gds ron vdsat vth vearly id cgg cgs cgb cgd cds beff
1e-6 2e-6 0.5 0.9 0.0 1e-4 0 2e-6 0 0 0.4 0 1e-5 1e-13 2e-14 0 0 0 0
1e-6 2e-6 0.6 0.9 0.0 1.2e-4 0 3e-6 0 0 0.4 0 1.5e-5 1.1e-13 2.1e-14 0 0 0 0
''';
      final loader = LutLoader();
      final data = loader.parseFromString(sample);

      expect(data.rowCount, 2);
      expect(data.columns.contains('gmid'), isTrue);
      expect(data.columns.contains('jd'), isTrue);
      expect(data.columns.contains('ft'), isTrue);
      expect(data.columns.contains('rds'), isTrue);
      expect(data.uniqueValues('L'), isNotEmpty);
      expect(data.rows.first['gmid'], closeTo(10.0, 1e-9));
    });

    test('query filters, snaps and extracts sorted series', () {
      const sample = '''
L W vgs vds vsb gm gmb gds ron vdsat vth vearly id cgg cgs cgb cgd cds beff
1e-6 2e-6 0.6 0.9 0.0 1.2e-4 0 3e-6 0 0 0.4 0 1.5e-5 1.1e-13 2.1e-14 0 0 0 0
1e-6 2e-6 0.5 0.9 0.0 1e-4 0 2e-6 0 0 0.4 0 1e-5 1e-13 2e-14 0 0 0 0
2e-6 2e-6 0.5 0.9 0.0 8e-5 0 2e-6 0 0 0.4 0 0.8e-5 1e-13 2e-14 0 0 0 0
''';
      final loader = LutLoader();
      final query = LutQuery();
      final data = loader.parseFromString(sample);

      final snapped = query.snapToClosest(data.uniqueValues('L'), 1.2e-6);
      expect(snapped, closeTo(1e-6, 1e-12));

      final filtered = query.filterRows(data, {
        'L': 1e-6,
        'vds': 0.9,
        'vsb': 0.0,
      });
      expect(filtered.length, 2);

      final (xs, ys) = query.extractSeries(filtered, 'vgs', 'gmid');
      expect(xs.length, 2);
      expect(xs.first <= xs.last, isTrue);
      expect(ys, isNotEmpty);
    });
  });
}

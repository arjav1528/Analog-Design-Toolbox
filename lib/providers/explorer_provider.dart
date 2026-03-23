import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lut_data.dart';
import '../services/lut_query.dart';

class ExplorerSeries {
  const ExplorerSeries({
    required this.label,
    required this.xs,
    required this.ys,
  });

  final String label;
  final List<double> xs;
  final List<double> ys;
}

class ExplorerState {
  const ExplorerState({
    required this.xAxis,
    required this.yAxis,
    required this.fixedVsb,
    required this.fixedVds,
    required this.selectedLengths,
    required this.logScale,
    required this.touchX,
  });

  final String xAxis;
  final String yAxis;
  final double fixedVsb;
  final double fixedVds;
  final Set<double> selectedLengths;
  final bool logScale;
  final double? touchX;

  ExplorerState copyWith({
    String? xAxis,
    String? yAxis,
    double? fixedVsb,
    double? fixedVds,
    Set<double>? selectedLengths,
    bool? logScale,
    double? touchX,
    bool clearTouchX = false,
  }) {
    return ExplorerState(
      xAxis: xAxis ?? this.xAxis,
      yAxis: yAxis ?? this.yAxis,
      fixedVsb: fixedVsb ?? this.fixedVsb,
      fixedVds: fixedVds ?? this.fixedVds,
      selectedLengths: selectedLengths ?? this.selectedLengths,
      logScale: logScale ?? this.logScale,
      touchX: clearTouchX ? null : (touchX ?? this.touchX),
    );
  }
}

class ExplorerNotifier extends StateNotifier<ExplorerState> {
  ExplorerNotifier(this._query)
      : super(
          const ExplorerState(
            xAxis: 'gmid',
            yAxis: 'jd',
            fixedVsb: 0.0,
            fixedVds: 0.9,
            selectedLengths: {},
            logScale: false,
            touchX: null,
          ),
        );

  final LutQuery _query;

  void initializeFromLut(LutData lut) {
    final lengths = lut.uniqueValues('L');
    final vsb = lut.uniqueValues('vsb');
    final vds = lut.uniqueValues('vds');

    state = state.copyWith(
      selectedLengths: lengths.toSet(),
      fixedVsb: vsb.isNotEmpty ? vsb.first : state.fixedVsb,
      fixedVds: vds.isNotEmpty ? vds.first : state.fixedVds,
      clearTouchX: true,
    );
  }

  void setAxis({String? xAxis, String? yAxis}) {
    state = state.copyWith(
      xAxis: xAxis,
      yAxis: yAxis,
      clearTouchX: true,
    );
  }

  void setFixed({double? vsb, double? vds}) {
    state = state.copyWith(
      fixedVsb: vsb,
      fixedVds: vds,
      clearTouchX: true,
    );
  }

  void toggleLength(double length) {
    final next = Set<double>.from(state.selectedLengths);
    if (next.contains(length)) {
      next.remove(length);
    } else {
      next.add(length);
    }
    state = state.copyWith(selectedLengths: next, clearTouchX: true);
  }

  void setLogScale(bool value) {
    state = state.copyWith(logScale: value);
  }

  void setTouchX(double? x) {
    state = state.copyWith(touchX: x);
  }

  List<ExplorerSeries> seriesFor(LutData lut) {
    final lengths = state.selectedLengths.isEmpty
        ? lut.uniqueValues('L').toSet()
        : state.selectedLengths;
    final snappedVsb =
        _query.snapToClosest(lut.uniqueValues('vsb'), state.fixedVsb);
    final snappedVds =
        _query.snapToClosest(lut.uniqueValues('vds'), state.fixedVds);

    final out = <ExplorerSeries>[];
    for (final l in lengths) {
      final snappedL = _query.snapToClosest(lut.uniqueValues('L'), l);
      final filtered = _query.filterRows(lut, {
        'vsb': snappedVsb,
        'vds': snappedVds,
        'L': snappedL,
      });
      final (xs, ys) = _query.extractSeries(filtered, state.xAxis, state.yAxis);
      if (xs.isEmpty || ys.isEmpty) {
        continue;
      }
      out.add(
        ExplorerSeries(
          label: 'L=${_formatLength(snappedL)}',
          xs: xs,
          ys: ys,
        ),
      );
    }
    return out;
  }

  String _formatLength(double lMeters) {
    if (lMeters >= 1e-6) {
      return '${(lMeters * 1e6).toStringAsFixed(2)}um';
    }
    return '${(lMeters * 1e9).toStringAsFixed(0)}nm';
  }
}

final explorerProvider =
    StateNotifierProvider<ExplorerNotifier, ExplorerState>(
  (ref) => ExplorerNotifier(const LutQuery()),
);

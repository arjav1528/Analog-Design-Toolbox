import 'formula_param.dart';

class PlotData {
  const PlotData({
    required this.xParam,
    required this.yParam,
    required this.xs,
    required this.ys,
    required this.title,
    this.subtitle,
  });

  final ParamId xParam;
  final ParamId yParam;
  final List<double> xs;
  final List<double> ys;
  final String title;
  final String? subtitle;
}

class SolverResult {
  const SolverResult({
    required this.known,
    required this.derivedVia,
    required this.plots,
  });

  final Map<ParamId, double> known;
  final Map<ParamId, String> derivedVia;
  final List<PlotData> plots;

  bool hasValue(ParamId id) => known.containsKey(id);
}

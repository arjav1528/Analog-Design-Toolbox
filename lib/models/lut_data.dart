class LutData {
  const LutData({
    required this.rows,
    required this.columns,
    required this.uniqueAxisValues,
  });

  final List<Map<String, double>> rows;
  final List<String> columns;
  final Map<String, List<double>> uniqueAxisValues;

  bool get isEmpty => rows.isEmpty;
  int get rowCount => rows.length;

  List<double> uniqueValues(String axis) =>
      uniqueAxisValues[axis] ?? const <double>[];
}

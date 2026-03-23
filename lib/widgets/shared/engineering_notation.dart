String formatEngineering(double siValue, double toSiFactor) {
  if (siValue.isNaN || siValue.isInfinite) {
    return '-';
  }
  final display = siValue / toSiFactor;
  final abs = display.abs();
  if (abs == 0) {
    return '0';
  }
  if (abs >= 1000 || abs < 0.001) {
    return display.toStringAsExponential(3);
  }
  if (abs >= 100) {
    return display.toStringAsFixed(2);
  }
  if (abs >= 10) {
    return display.toStringAsFixed(3);
  }
  return display.toStringAsFixed(4);
}

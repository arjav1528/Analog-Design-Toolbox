import 'formula_param.dart';

typedef RuleCompute = double? Function(Map<ParamId, double> known);

class FormulaRule {
  const FormulaRule({
    required this.inputs,
    required this.output,
    required this.expression,
    required this.compute,
  });

  final List<ParamId> inputs;
  final ParamId output;
  final String expression;
  final RuleCompute compute;
}

import 'dart:math' as math;

import '../models/formula_param.dart';
import '../models/formula_rule.dart';
import '../models/solver_result.dart';
import 'plot_generator.dart';

class FormulaEngine {
  FormulaEngine({PlotGenerator? plotGenerator})
      : _plotGenerator = plotGenerator ?? const PlotGenerator();

  final PlotGenerator _plotGenerator;

  static const double _eps = 1e-30;

  static final List<FormulaRule> rules = [
    FormulaRule(
      inputs: [ParamId.vgs, ParamId.vth],
      output: ParamId.vov,
      expression: 'VOV = VGS - VTH',
      compute: (known) => known[ParamId.vgs]! - known[ParamId.vth]!,
    ),
    FormulaRule(
      inputs: [ParamId.vov, ParamId.vth],
      output: ParamId.vgs,
      expression: 'VGS = VOV + VTH',
      compute: (known) => known[ParamId.vov]! + known[ParamId.vth]!,
    ),
    FormulaRule(
      inputs: [ParamId.vgs, ParamId.vov],
      output: ParamId.vth,
      expression: 'VTH = VGS - VOV',
      compute: (known) => known[ParamId.vgs]! - known[ParamId.vov]!,
    ),
    FormulaRule(
      inputs: [ParamId.id, ParamId.vov],
      output: ParamId.gm,
      expression: 'gm = 2*ID/VOV',
      compute: (known) {
        final vov = known[ParamId.vov]!;
        if (vov.abs() < _eps) {
          return null;
        }
        return (2 * known[ParamId.id]!) / vov;
      },
    ),
    FormulaRule(
      inputs: [ParamId.vov],
      output: ParamId.gmId,
      expression: 'gm/ID = 2/VOV',
      compute: (known) {
        final vov = known[ParamId.vov]!;
        if (vov.abs() < _eps) {
          return null;
        }
        return 2 / vov;
      },
    ),
    FormulaRule(
      inputs: [ParamId.gm, ParamId.id],
      output: ParamId.gmId,
      expression: 'gm/ID = gm/ID',
      compute: (known) {
        final id = known[ParamId.id]!;
        if (id.abs() < _eps) {
          return null;
        }
        return known[ParamId.gm]! / id;
      },
    ),
    FormulaRule(
      inputs: [ParamId.gmId, ParamId.id],
      output: ParamId.gm,
      expression: 'gm = (gm/ID)*ID',
      compute: (known) => known[ParamId.gmId]! * known[ParamId.id]!,
    ),
    FormulaRule(
      inputs: [ParamId.gm, ParamId.gmId],
      output: ParamId.id,
      expression: 'ID = gm/(gm/ID)',
      compute: (known) {
        final gmId = known[ParamId.gmId]!;
        if (gmId.abs() < _eps) {
          return null;
        }
        return known[ParamId.gm]! / gmId;
      },
    ),
    FormulaRule(
      inputs: [ParamId.uCox, ParamId.wl, ParamId.vov],
      output: ParamId.id,
      expression: 'ID = 0.5*uCox*(W/L)*VOV^2',
      compute: (known) =>
          0.5 *
          known[ParamId.uCox]! *
          known[ParamId.wl]! *
          math.pow(known[ParamId.vov]!, 2),
    ),
    FormulaRule(
      inputs: [ParamId.uCox, ParamId.wl, ParamId.vov],
      output: ParamId.gm,
      expression: 'gm = uCox*(W/L)*VOV',
      compute: (known) =>
          known[ParamId.uCox]! * known[ParamId.wl]! * known[ParamId.vov]!,
    ),
    FormulaRule(
      inputs: [ParamId.id, ParamId.uCox, ParamId.vov],
      output: ParamId.wl,
      expression: 'W/L = (2*ID)/(uCox*VOV^2)',
      compute: (known) {
        final denom =
            known[ParamId.uCox]! * math.pow(known[ParamId.vov]!, 2).toDouble();
        if (denom.abs() < _eps) {
          return null;
        }
        return (2 * known[ParamId.id]!) / denom;
      },
    ),
    FormulaRule(
      inputs: [ParamId.lambda, ParamId.id],
      output: ParamId.ro,
      expression: 'ro = 1/(lambda*ID)',
      compute: (known) {
        final denom = known[ParamId.lambda]! * known[ParamId.id]!;
        if (denom.abs() < _eps) {
          return null;
        }
        return 1 / denom;
      },
    ),
    FormulaRule(
      inputs: [ParamId.ro, ParamId.id],
      output: ParamId.lambda,
      expression: 'lambda = 1/(ro*ID)',
      compute: (known) {
        final denom = known[ParamId.ro]! * known[ParamId.id]!;
        if (denom.abs() < _eps) {
          return null;
        }
        return 1 / denom;
      },
    ),
    FormulaRule(
      inputs: [ParamId.gm, ParamId.ro],
      output: ParamId.av0,
      expression: 'Av0 = gm*ro',
      compute: (known) => known[ParamId.gm]! * known[ParamId.ro]!,
    ),
    FormulaRule(
      inputs: [ParamId.gm, ParamId.cgs],
      output: ParamId.ft,
      expression: 'fT = gm/(2*pi*Cgs)',
      compute: (known) {
        final denom = 2 * math.pi * known[ParamId.cgs]!;
        if (denom.abs() < _eps) {
          return null;
        }
        return known[ParamId.gm]! / denom;
      },
    ),
  ];

  SolverResult solve(Map<ParamId, double?> userInputs) {
    final known = <ParamId, double>{};
    for (final entry in userInputs.entries) {
      final value = entry.value;
      if (value == null || value.isNaN || value.isInfinite) {
        continue;
      }
      known[entry.key] = value;
    }

    final derivedVia = <ParamId, String>{};
    bool changed;
    do {
      changed = false;
      for (final rule in rules) {
        if (known.containsKey(rule.output)) {
          continue;
        }
        if (!rule.inputs.every(known.containsKey)) {
          continue;
        }

        final computed = rule.compute(known);
        if (computed == null || computed.isNaN || computed.isInfinite) {
          continue;
        }

        known[rule.output] = computed;
        derivedVia[rule.output] = rule.expression;
        changed = true;
      }
    } while (changed);

    final plots = _buildAutoPlots(known);

    return SolverResult(
      known: known,
      derivedVia: derivedVia,
      plots: plots,
    );
  }

  List<PlotData> _buildAutoPlots(Map<ParamId, double> known) {
    final plots = <PlotData>[];
    for (final target in ParamId.values) {
      if (known.containsKey(target)) {
        continue;
      }

      final candidateRules = rules.where((rule) => rule.output == target);
      for (final rule in candidateRules) {
        final missingInputs =
            rule.inputs.where((input) => !known.containsKey(input)).toList();
        if (missingInputs.length != 1) {
          continue;
        }

        final plot = _plotGenerator.generateSingleMissingInputPlot(
          targetParam: target,
          rule: rule,
          missingInput: missingInputs.first,
          known: known,
        );
        if (plot != null) {
          plots.add(plot);
          break;
        }
      }
    }
    return plots;
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/formula_param.dart';
import '../models/solver_result.dart';
import '../services/formula_engine.dart';

class FormulaState {
  const FormulaState({
    required this.userInputs,
    required this.result,
  });

  final Map<ParamId, double?> userInputs;
  final SolverResult result;

  FormulaState copyWith({
    Map<ParamId, double?>? userInputs,
    SolverResult? result,
  }) {
    return FormulaState(
      userInputs: userInputs ?? this.userInputs,
      result: result ?? this.result,
    );
  }
}

class FormulaNotifier extends StateNotifier<FormulaState> {
  FormulaNotifier(this._engine)
      : super(
          FormulaState(
            userInputs: {
              for (final id in ParamId.values) id: null,
            },
            result: const SolverResult(known: {}, derivedVia: {}, plots: []),
          ),
        ) {
    _solveNow();
  }

  final FormulaEngine _engine;
  Timer? _debounce;

  void setParam(ParamId param, double? valueInDisplayUnit) {
    final factor = param.meta.toSiFactor;
    final valueInSi =
        valueInDisplayUnit == null ? null : valueInDisplayUnit * factor;
    final updated = Map<ParamId, double?>.from(state.userInputs)
      ..[param] = valueInSi;
    state = state.copyWith(userInputs: updated);
    _scheduleSolve();
  }

  void clear() {
    _debounce?.cancel();
    state = state.copyWith(
      userInputs: {
        for (final id in ParamId.values) id: null,
      },
    );
    _solveNow();
  }

  void _scheduleSolve() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _solveNow);
  }

  void _solveNow() {
    final result = _engine.solve(state.userInputs);
    state = state.copyWith(result: result);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final formulaProvider = StateNotifierProvider<FormulaNotifier, FormulaState>(
  (ref) => FormulaNotifier(FormulaEngine()),
);

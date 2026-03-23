import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lut_data.dart';
import '../services/lut_loader.dart';

class LutState {
  const LutState({
    required this.data,
    required this.loading,
    required this.filePath,
    required this.error,
  });

  final LutData? data;
  final bool loading;
  final String? filePath;
  final String? error;

  LutState copyWith({
    LutData? data,
    bool? loading,
    String? filePath,
    String? error,
    bool clearError = false,
  }) {
    return LutState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      filePath: filePath ?? this.filePath,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LutNotifier extends StateNotifier<LutState> {
  LutNotifier(this._loader)
      : super(
          const LutState(
            data: null,
            loading: false,
            filePath: null,
            error: null,
          ),
        );

  final LutLoader _loader;

  Future<void> pickAndLoadCsv() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select LUT CSV',
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt', 'dat'],
        withData: false,
      );
      final path = result?.files.single.path;
      if (path == null) {
        state = state.copyWith(loading: false);
        return;
      }
      await loadFromFile(path);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Failed to pick LUT file: $e',
      );
    }
  }

  Future<void> loadFromFile(String path) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final data = await _loader.loadFromFilePath(path);
      state = state.copyWith(
        data: data,
        filePath: path,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Failed to load LUT: $e',
      );
    }
  }

  void clearLut() {
    state = const LutState(
      data: null,
      loading: false,
      filePath: null,
      error: null,
    );
  }
}

final lutProvider = StateNotifierProvider<LutNotifier, LutState>(
  (ref) => LutNotifier(const LutLoader()),
);

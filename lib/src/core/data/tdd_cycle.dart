import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../domain/tdd_state.dart';

final class TddCycle {
  TddCycle({required String projectDir}) : _projectDir = projectDir;

  final String _projectDir;

  Future<TddState> savedTddState() async {
    try {
      return await _tryLoadSavedState();
    } catch (_) {
      return TddState.idle();
    }
  }

  Future<TddState> _tryLoadSavedState() async {
    final file = _tddStateFile;

    return !await file.exists()
        ? TddState.idle()
        : await _savedJsonTddState(file);
  }

  Future<TddState> _savedJsonTddState(File file) async {
    final content = await file.readAsString();

    final json = jsonDecode(content) as Map<String, dynamic>;

    return TddState.fromJson(json);
  }

  Future<void> save(TddState state) async {
    await _tddStateFile.writeAsString(jsonEncode(state.toJson()));
  }

  Future<void> reset() async {
    final file = _tddStateFile;

    if (await file.exists()) await file.delete();
  }

  File get _tddStateFile => File(p.join(_projectDir, TddState.stateFileName));
}

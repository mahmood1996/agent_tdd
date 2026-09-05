import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'harness_state.dart';
import 'state_store.dart';

/// A JSON file-backed implementation of [StateStore].
final class FileStateStore implements StateStore {
  final String projectDir;
  final String stateFileName;

  FileStateStore({
    required this.projectDir,
    this.stateFileName = '.agent_tdd_state.json',
  });

  File get _stateFile => File(p.join(projectDir, stateFileName));

  @override
  Future<HarnessState> harnessState() async {
    try {
      final file = _stateFile;
      if (!await file.exists()) {
        return const HarnessState(
          phase: 'IDLE',
          editablePatterns: [],
          readOnlyPatterns: [],
          nextCommand: 'agent-tdd next',
          allowedCommands: [
            'agent-tdd next',
            'agent-tdd specs',
            'agent-tdd status',
            'agent-tdd reset',
          ],
        );
      }
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return HarnessState.fromJson(json);
    } catch (_) {
      return const HarnessState(
        phase: 'IDLE',
        editablePatterns: [],
        readOnlyPatterns: [],
        nextCommand: 'agent-tdd next',
        allowedCommands: [
          'agent-tdd next',
          'agent-tdd specs',
          'agent-tdd status',
          'agent-tdd reset',
        ],
      );
    }
  }

  @override
  Future<void> saveState(HarnessState state) async {
    final file = _stateFile;
    await file.writeAsString(jsonEncode(state.toJson()));
  }

  @override
  Future<void> resetState() async {
    final file = _stateFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}

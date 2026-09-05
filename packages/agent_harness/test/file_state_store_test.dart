import 'dart:io';
import 'package:agent_harness/agent_harness.dart';
import 'package:test/test.dart';

void main() {
  group('FileStateStore Solitary Unit Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('file_state_store_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Initial state is IDLE', () async {
      final store = FileStateStore(projectDir: tempDir.path);
      final state = await store.harnessState();
      expect(state.phase, equals('IDLE'));
    });

    test('Save and reload state', () async {
      final store = FileStateStore(projectDir: tempDir.path);
      final state = const HarnessState(
        phase: 'RED',
        editablePatterns: ['test/**/*_test.dart'],
        readOnlyPatterns: ['lib/**/*.dart'],
        nextCommand: 'agent-tdd verify-red',
        allowedCommands: [
          'agent-tdd verify-red',
          'agent-tdd status',
          'agent-tdd reset'
        ],
        metadata: {
          'active_spec_id': 42,
          'active_spec_title': 'Fix login bug',
        },
      );
      await store.saveState(state);

      final reloaded = await store.harnessState();
      expect(reloaded.phase, equals('RED'));
      expect(reloaded.editablePatterns, equals(['test/**/*_test.dart']));
      expect(reloaded.readOnlyPatterns, equals(['lib/**/*.dart']));
      expect(reloaded.nextCommand, equals('agent-tdd verify-red'));
      expect(reloaded.metadata['active_spec_id'], equals(42));
      expect(reloaded.metadata['active_spec_title'], equals('Fix login bug'));
    });

    test('Reset state removes file and returns IDLE state', () async {
      final store = FileStateStore(projectDir: tempDir.path);
      final state = const HarnessState(
        phase: 'GREEN',
        editablePatterns: ['lib/**/*.dart'],
        readOnlyPatterns: ['test/**/*_test.dart'],
        metadata: {
          'active_spec_id': 7,
          'active_spec_title': 'Feature',
        },
      );
      await store.saveState(state);

      await store.resetState();
      final resetState = await store.harnessState();
      expect(resetState.phase, equals('IDLE'));
    });
  });
}

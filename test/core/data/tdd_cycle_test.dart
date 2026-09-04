import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('tdd_cycle_test_');

  group('TddCycle State Solitary Unit Tests', () {
    test('Initial state is idle', () async {
      final cycle = TddCycle(projectDir: harness.tempDir.path);
      final state = await cycle.savedTddState();
      expect(state.phase, equals(TddPhase.idle));
    });

    test('Save and reload state with copyWith', () async {
      final cycle = TddCycle(projectDir: harness.tempDir.path);
      final state = TddState(
        phase: TddPhase.red,
        activeSpecId: 42,
        activeSpecTitle: 'Fix login bug',
        startedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      await cycle.save(state);

      final reloaded = await cycle.savedTddState();
      expect(reloaded.phase, equals(TddPhase.red));
      expect(reloaded.activeSpecId, equals(42));
      expect(reloaded.activeSpecTitle, equals('Fix login bug'));
    });
  });
}

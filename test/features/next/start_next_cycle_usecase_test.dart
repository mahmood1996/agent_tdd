import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('start_next_cycle_usecase_test_');

  group('StartNextCycleUseCase Behavioral Solitary Unit Tests', () {
    test('execute fails when no pending specs exist in backlog', () async {
      final useCase = StartNextCycleUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.success, isFalse);
      expect(res.message, contains('No pending specs found'));
      expect(res.currentState.phase, equals(TddPhase.idle));
    });

    test('execute succeeds, picks next pending spec, and transitions to RED phase', () async {
      final specStore = SpecStore(projectDir: harness.tempDir.path);
      await specStore.addSpec('Build User Profile');

      final useCase = StartNextCycleUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.success, isTrue);
      expect(res.currentState.phase, equals(TddPhase.red));
      expect(res.activeSpec?.id, equals(1));
      expect(res.activeSpec?.title, equals('Build User Profile'));
    });

    test('execute fails if cycle is already in progress', () async {
      final specStore = SpecStore(projectDir: harness.tempDir.path);
      await specStore.addSpec('Spec 1');
      await specStore.addSpec('Spec 2');

      final useCase = StartNextCycleUseCase(projectDir: harness.tempDir.path);
      await useCase.execute(); // now in RED

      final res2 = await useCase.execute();
      expect(res2.success, isFalse);
      expect(res2.message, contains('while another cycle is in progress'));
    });
  });
}

import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';
import '../../helpers/fake_spec.dart';

void main() {
  final harness = BaseTest()..setUpBase('reset_cycle_usecase_test_');

  group('ResetCycleUseCase Behavioral Solitary Unit Tests', () {
    test('execute resets cycle state from active phase back to IDLE', () async {
      final store = TddStateStore(projectDir: harness.tempDir.path);
      await store.save(
        TddState.green(const FakeSpec(id: 5, title: 'Broken feature')),
      );

      final useCase = ResetCycleUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.success, isTrue);

      final state = await store.currentState();
      expect(state.phase, equals(TddPhase.idle));
      expect(state.activeSpecId, isNull);
    });
  });
}

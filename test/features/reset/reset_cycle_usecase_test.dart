import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('reset_cycle_usecase_test_');

  group('ResetCycleUseCase Behavioral Solitary Unit Tests', () {
    test('execute resets cycle state from active phase back to IDLE', () async {
      final store = FileStateStore(projectDir: harness.tempDir.path);
      await store.saveState(TddHarnessState.green(
        activeSpecId: 5,
        activeSpecTitle: 'Broken feature',
      ));

      final useCase = ResetCycleUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.success, isTrue);

      final state = await store.harnessState();
      expect(state.isIdle, isTrue);
      expect(state.activeSpecId, isNull);
    });
  });
}

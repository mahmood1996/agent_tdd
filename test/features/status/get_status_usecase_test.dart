import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('get_status_usecase_test_');

  group('GetStatusUseCase Behavioral Solitary Unit Tests', () {
    test('execute returns idle state and empty summary when clean', () async {
      final useCase = GetStatusUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.state.phase, equals(TddPhase.idle));
      expect(res.summary['active_spec'], isNull);
      expect(res.summary['total'], equals(0));
    });

    test('execute returns active phase, bound active spec, and backlog summary', () async {
      final specStore = SpecStore(projectDir: harness.tempDir.path);
      await specStore.addSpec('Spec 1');
      await specStore.updateSpecStatus(1, 'red');

      final cycle = TddCycle(projectDir: harness.tempDir.path);
      await cycle.save(TddState(
        phase: TddPhase.red,
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
        startedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      ));

      final useCase = GetStatusUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.state.phase, equals(TddPhase.red));
      expect(res.summary['active_spec']['id'], equals(1));
      expect(res.summary['active_spec']['title'], equals('Spec 1'));
      expect(res.summary['total'], equals(1));
    });
  });
}

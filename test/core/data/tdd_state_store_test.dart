import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';
import '../../helpers/fake_spec.dart';

void main() {
  final harness = BaseTest()..setUpBase('tdd_state_store_test_');

  group('TddStateStore Solitary Unit Tests', () {
    test('Initial state is idle when no state file exists', () async {
      final store = TddStateStore(projectDir: harness.tempDir.path);
      final state = await store.currentState();
      expect(state.phase, equals(TddPhase.idle));
      expect(state.activeSpecId, isNull);
      expect(state.activeSpecTitle, isNull);
    });

    test('Save and reload state with minimal factories and transitions', () async {
      final store = TddStateStore(projectDir: harness.tempDir.path);
      const spec = FakeSpec(id: 42, title: 'Fix login bug');

      final redState = TddState.red(spec);
      expect(redState.phase, equals(TddPhase.red));
      expect(redState.activeSpecId, equals(42));
      expect(redState.activeSpecTitle, equals('Fix login bug'));

      await store.save(redState);

      final reloaded = await store.currentState();
      expect(reloaded.phase, equals(TddPhase.red));
      expect(reloaded.activeSpecId, equals(42));
      expect(reloaded.activeSpecTitle, equals('Fix login bug'));

      final greenState = reloaded.toGreen();
      expect(greenState.phase, equals(TddPhase.green));
      expect(greenState.activeSpecId, equals(42));
      await store.save(greenState);

      final reloadedGreen = await store.currentState();
      expect(reloadedGreen.phase, equals(TddPhase.green));

      final refactorState = reloadedGreen.toRefactor();
      expect(refactorState.phase, equals(TddPhase.refactor));
      await store.save(refactorState);

      final reloadedRefactor = await store.currentState();
      expect(reloadedRefactor.phase, equals(TddPhase.refactor));

      await store.reset();
      final resetState = await store.currentState();
      expect(resetState.phase, equals(TddPhase.idle));
    });

    test('TddState minimal factories: alreadyPassed and green', () {
      const spec = FakeSpec(id: 7, title: 'Speed up cache');
      final alreadyPassed = TddState.alreadyPassed(spec);
      expect(alreadyPassed.phase, equals(TddPhase.alreadyPassed));
      expect(alreadyPassed.activeSpecId, equals(7));

      final green = TddState.green(spec);
      expect(green.phase, equals(TddPhase.green));
      expect(green.activeSpecId, equals(7));

      final refactor = TddState.refactor(spec);
      expect(refactor.phase, equals(TddPhase.refactor));
      expect(refactor.activeSpecId, equals(7));
    });
  });
}
